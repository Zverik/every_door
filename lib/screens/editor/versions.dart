import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:every_door/models/amenity.dart';
import 'package:every_door/providers/osm_api.dart';
import 'package:every_door/providers/auth.dart';
import 'package:flutter/material.dart';
import 'package:every_door/generated/l10n/app_localizations.dart' show AppLocalizations;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class TagChange {
  final String? oldValue;
  final String? newValue;
  bool get noChange => oldValue == newValue;
  bool get removed => newValue == null;
  bool get added => oldValue == null;
  bool get updated => !added && !removed && oldValue != newValue;

  const TagChange(this.oldValue, this.newValue);

  Color? getColor() {
    if (noChange) return null;
    if (added) return Colors.green.shade100;
    if (updated) return Colors.amber.shade200;
    if (removed) return Colors.red.shade100;

    // should never be reached
    return null;
  }

  @override
  String toString() {
    return 'TagChange(oldValue: $oldValue, newValue: $newValue)';
  }
}

class Version {
  final int number;
  final String user;
  final DateTime timestamp;
  final int changeset; // used to fetch changeset comment
  final Map<String, String> tags;
  final bool isLocal;
  String? comment; // fetched separately

  /// stores the tag changes between this version and the previous version.
  /// uses a `SplayTreeMap` so that keys are sorted alphabetically
  Map<String, TagChange> tagChanges = SplayTreeMap();

  // don't need to show diff when no tags have changed
  bool get noTagChange => tagChanges.entries.every((e) => e.value.noChange);

  Version({
    required this.number,
    required this.user,
    required this.timestamp,
    required this.tags,
    required this.changeset,
    this.isLocal = false,
  });

  factory Version.fromJson(Map<String, dynamic> data) {
    final number = data['version'] as int;
    // some old changesets were created anonymously
    final user = (data['user'] ?? 'anonymous') as String;
    final timestamp = DateTime.parse(data['timestamp'] as String);
    final changeset = data['changeset'] as int;
    final tags =
        (data['tags'] ?? {}).cast<String, String>() as Map<String, String>;

    return Version(
      number: number,
      user: user,
      timestamp: timestamp,
      changeset: changeset,
      tags: tags,
    );
  }

  @override
  String toString() {
    return 'Version(number: $number, user: $user, timestamp: $timestamp, changeset: $changeset, tags: $tags, isLocal: $isLocal, comment: $comment, tagChanges: $tagChanges)';
  }
}

class History {
  String endpoint;
  String fullRef;
  late List<Version> versions;

  History(this.endpoint, this.fullRef);

  /// load history for this element reference
  /// must be called before other methods of this class
  Future<void> loadHistory() async {
    final resp = await http.get(
      Uri.https(endpoint, '/api/0.6/$fullRef/history'),
      headers: {"Accept": "application/json"},
    );
    if (resp.statusCode == 404) {
      throw OsmApiError(
          resp.statusCode, 'Could not find history for $fullRef: ${resp.body}');
    }
    if (resp.statusCode != 200) {
      throw OsmApiError(
          resp.statusCode, 'Failed to fetch history: ${resp.body}');
    }

    final elements = jsonDecode(resp.body)['elements'];
    versions = elements.map<Version>((e) => Version.fromJson(e)).toList();
  }

  /// get comments for changesets that edited this element
  /// limited to 100 most recent
  Future<void> loadComments() async {
    final changesetIDs = versions.map((v) => v.changeset).join(",");
    final resp = await http.get(
      // TODO: avoid urlencoding
      // OSM API expects something like [...]/changesets?changesets=1,2,3
      // this sends the commas URL-encoded as %2C, but it still works
      Uri.https(
        endpoint,
        '/api/0.6/changesets',
        {'changesets': changesetIDs},
      ),
      headers: {"Accept": "application/json"},
    );
    if (resp.statusCode != 200) {
      throw OsmApiError(
          resp.statusCode, 'Failed to fetch changeset details: ${resp.body}');
    }

    final changesets = jsonDecode(resp.body)["changesets"];

    for (var changeset in changesets) {
      // some (old) changesets do not always have tags or comments
      versions
          .firstWhere((element) => element.changeset == changeset["id"])
          .comment = changeset?["tags"]?["comment"];
    }
  }

  void createDiffs(Map<String, String?> localChanges) {
    if (localChanges.isNotEmpty) {
      // merge in local changes to the latest remote version, so we can diff local changes
      var mergedLocalVersion =
      Map.from(versions.last.tags).cast<String, String?>();
      mergedLocalVersion.addAll(localChanges);

      for (var tag in Map
          .from(mergedLocalVersion)
          .entries) {
        // null values are removed tags
        if (tag.value == null) {
          mergedLocalVersion.remove(tag.key);
        }
      }
      versions.add(
        Version(
          tags: mergedLocalVersion.cast<String, String>(),
          number: -1,
          user: '',
          changeset: -1,
          timestamp: DateTime.now(),
          isLocal: true,
        ),
      );
    }

    // version 0 with no tags to diff version 1 against
    var previousVersion = Version(
      tags: {},
      number: -1,
      user: '',
      timestamp: DateTime.now(),
      changeset: -1,
    );

    for (var version in versions) {
      // handle added/same/updated tags
      for (var tag in version.tags.entries) {
        version.tagChanges[tag.key] =
            TagChange(previousVersion.tags[tag.key], tag.value);
      }

      // handle removed tags
      for (var key in previousVersion.tags.keys) {
        if (version.tagChanges[key] == null) {
          version.tagChanges[key] = TagChange(previousVersion.tags[key], null);
        }
      }

      previousVersion = version;
    }
  }
}

class VersionsPage extends ConsumerStatefulWidget {
  final OsmChange amenity;

  const VersionsPage(this.amenity);

  @override
  ConsumerState<VersionsPage> createState() => _VersionsPageState();
}

class _VersionsPageState extends ConsumerState<VersionsPage> {
  History? history;
  Exception? error;

  Future<void> getHistory() async {
    try {
      final auth = ref.read(authProvider)['osm']!;
      final newHistory = History(auth.endpoint, widget.amenity.id.fullRef);
      await newHistory.loadHistory();
      await newHistory.loadComments();

      newHistory.createDiffs(widget.amenity.newTags);

      setState(() => history = newHistory);
    } on Exception catch (e) {
      setState(() => error = e);
    }
  }

  @override
  void initState() {
    super.initState();
    getHistory();
  }

  Center _buildLoader() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          CircularProgressIndicator(
            value: null,
            color: Colors.blueGrey,
          ),
        ],
      ),
    );
  }

  Center _buildError(AppLocalizations loc) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 15, left: 15, right: 15),
            child: Text(
              error.runtimeType == SocketException
                  ? loc.versionsEnableInternet
                  : '${loc.versionsFetchError}: $error',
              style: TextStyle(fontSize: 16),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // clear out error to show loader
              setState(() => error = null);
              getHistory();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 16.0,
                horizontal: 12.0,
              ),
              child: Text(
                loc.versionsRetryFetch,
                style: TextStyle(fontSize: 16.0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Table _buildTable(Version version) {
    return Table(
      border: TableBorder.all(
        width: 1,
        color: Colors.grey,
        borderRadius: BorderRadius.all(Radius.circular(3)),
      ),
      children: [
        for (final tag in version.tagChanges.entries)
          TableRow(
            // TODO: these BoxDecorations slightly clip outside of the table BorderRadius
            decoration: BoxDecoration(
              color: tag.value.getColor(),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(6),
                child: Text(
                  tag.key,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(6),
                child:
                    Text(!tag.value.noChange ? tag.value.oldValue ?? '' : ''),
              ),
              Padding(
                padding: const EdgeInsets.all(6),
                child: Text(tag.value.newValue ?? ''),
              )
            ],
          ),
      ],
    );
  }

  Card _buildCard(Version version, AppLocalizations loc) {
    return Card(
      margin: EdgeInsets.only(top: 12, right: 12, left: 12),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                version.isLocal
                    ? loc.versionsLocalChanges
                    : loc.versionsVersionNumber(version.number),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            if (!version.isLocal)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  loc.versionsVersionMeta(
                    version.user,
                    DateFormat.yMMMMd().add_Hm().format(version.timestamp),
                  ),
                ),
              ),
            if (version.comment != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  version.comment!,
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            version.noTagChange
                ? Text(loc.versionsNoTagChanges)
                : _buildTable(version),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.versionsTitle(widget.amenity.id.fullRef)),
      ),
      body: Builder(
        builder: (BuildContext context) {
          if (error != null) {
            return _buildError(loc);
          }
          if (history == null) {
            return _buildLoader();
          }

          return ListView(
            children: [
              for (var version in history!.versions.reversed)
                _buildCard(version, loc),
              SizedBox(height: 12), // bottom padding
            ],
          );
        },
      ),
    );
  }
}

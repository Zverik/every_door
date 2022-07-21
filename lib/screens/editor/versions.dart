import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:every_door/private.dart';
import 'package:every_door/providers/osm_api.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

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
    return "was: $oldValue, now: $newValue";
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

  /// stores the tags changes between previous versions and this versions.
  /// uses a `SplayTreeMap` so that keys are sorted alphabetically
  Map<String, TagChange> tagChanges = SplayTreeMap();

  // don't need to show diff when no tags have changed
  bool get noTagChange => tagChanges.entries.every((e) => e.value.noChange);

  factory Version.fromJson(Map<String, dynamic> data) {
    final number = data['version'] as int;
    final user = data['user'] as String;
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
    return 'v$number: user: $user, timestamp: $timestamp, changeset: $changeset, comment: $comment, tags: $tags updated: $tagChanges';
  }

  Version({
    required this.number,
    required this.user,
    required this.timestamp,
    required this.tags,
    required this.changeset,
    this.isLocal = false,
  });
}

class History {
  List<Version> versions;

  /// get comments for changesets that edited this element
  /// limited to 100 most recent
  Future<void> getComments() async {
    final changesetIDs = versions.map((v) => v.changeset).join(",");
    final resp = await http.get(
        // TODO: avoid urlencoding
        // OSM API expects something like [...]/changesets?changesets=1,2,3
        // this sends the commas URL-encoded as %2C, but it still works
        Uri.https(
            kOsmEndpoint, '/api/0.6/changesets', {'changesets': changesetIDs}),
        headers: {"Accept": "application/json"});
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

  createDiffs(Map<String, String?> localChanges) {
    // merge in the local changes to the remote ones, based from the latest remote versions
    var mergedLocalVersion =
        Map.from(versions.last.tags).cast<String, String?>();
    mergedLocalVersion.addAll(localChanges);

    for (var tag in Map.from(mergedLocalVersion).entries) {
      // null values are removed tags
      if (tag.value == null) {
        mergedLocalVersion.remove(tag.key);
      }
    }
    versions.add(Version(
        tags: mergedLocalVersion.cast<String, String>(),
        number: -1,
        user: 'You',
        changeset: -1,
        timestamp: DateTime.now(),
        isLocal: true));

    // version 0 with no tags to diff version 1 against
    var previousVersion = Version(
      tags: {},
      number: -1,
      user: '',
      timestamp: DateTime.now(),
      changeset: -1,
    );

    for (var i = 0; i < versions.length; i++) {
      var currentVersion = versions[i];

      // handle added/same/updated tags
      for (var tag in currentVersion.tags.entries) {
        currentVersion.tagChanges[tag.key] =
            TagChange(previousVersion.tags[tag.key], tag.value);
      }

      // handle removed tags
      for (var key in previousVersion.tags.keys) {
        if (currentVersion.tagChanges[key] == null) {
          currentVersion.tagChanges[key] =
              TagChange(previousVersion.tags[key], null);
        }
      }

      previousVersion = currentVersion;
    }
  }

  factory History.fromJson(Map<String, dynamic> data) {
    final elements = data['elements'];
    final versions = elements.map<Version>((e) => Version.fromJson(e)).toList();

    return History(versions);
  }

  History(this.versions);
}

class VersionsPage extends StatefulWidget {
  final String fullRef;
  final Uri historyUrl;
  final Map<String, String?> localChanges;

  const VersionsPage({
    required this.fullRef,
    required this.historyUrl,
    required this.localChanges,
  });

  @override
  State<VersionsPage> createState() => _VersionsPageState();
}

class _VersionsPageState extends State<VersionsPage> {
  History? history;
  Exception? error;

  Future<dynamic> loadHistoryJson() async {
    final resp = await http.get(
        Uri.https(kOsmEndpoint, '/api/0.6/${widget.fullRef}/history'),
        headers: {"Accept": "application/json"});
    if (resp.statusCode == 404) {
      throw OsmApiError(resp.statusCode,
          'Could not find history for ${widget.fullRef}: ${resp.body}');
    }
    if (resp.statusCode != 200) {
      throw OsmApiError(
          resp.statusCode, 'Failed to fetch history: ${resp.body}');
    }
    return jsonDecode(resp.body);
  }

  findHistory() async {
    try {
      var json = await loadHistoryJson();
      final newHistory = History.fromJson(json);

      await newHistory.getComments();
      newHistory.createDiffs(widget.localChanges);

      setState(() => history = newHistory);
    } on SocketException catch (e) {
      setState(() => error = e);
    } on OsmApiError catch (e) {
      setState(() => error = e);
    }
  }

  @override
  void initState() {
    super.initState();
    findHistory();
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

  Center _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Text(
              error.runtimeType == SocketException
                  ? 'Connect to the internet to fetch version history'
                  : 'Error fetching version history: $error',
              style: TextStyle(fontSize: 16),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => error = null);
              findHistory();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 16.0,
                horizontal: 12.0,
              ),
              child: Text(
                "Retry",
                style: TextStyle(
                  fontSize: 16.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _buildTable(Version version) {
    return Table(
      border: TableBorder.all(
        width: 1,
        color: Colors.grey,
        borderRadius: BorderRadius.all(
          Radius.circular(3),
        ),
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
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(6),
                child:
                    Text(!tag.value.noChange ? tag.value.oldValue ?? "" : ""),
              ),
              Padding(
                padding: const EdgeInsets.all(6),
                child: Text(tag.value.newValue ?? ""),
              )
            ],
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.fullRef} history"),
        actions: [
          IconButton(
            icon: Icon(Icons.open_in_browser),
            onPressed: () async => await launchUrl(widget.historyUrl,
                mode: LaunchMode.externalApplication),
          ),
        ],
      ),
      body: Builder(
        builder: (BuildContext context) {
          if (error != null) {
            return _buildError();
          }
          if (history == null) {
            return _buildLoader();
          }

          return ListView(
            children: [
              for (var i = history!.versions.length - 1; i >= 0; i--)
                Builder(builder: (context) {
                  final version = history!.versions[i];

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
                                  ? 'Local changes'
                                  : 'Version #${version.number}',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                          if (!version.isLocal)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                'by ${version.user} at ${DateFormat.yMMMMd().add_Hm().format(version.timestamp)}',
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
                              ? Text("No tag changes")
                              : _buildTable(version),
                        ],
                      ),
                    ),
                  );
                }),
              // bottom padding
              Container(height: 12)
            ],
          );
        },
      ),
    );
  }
}

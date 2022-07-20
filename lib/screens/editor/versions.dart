import 'package:every_door/private.dart';
import 'package:every_door/providers/osm_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:xml/xml.dart';

class TagChange {
  final String oldValue;
  final String newValue;

  const TagChange(this.oldValue, this.newValue);

  @override
  String toString() {
    return "was: $oldValue, now: $newValue";
  }
}

class Version {
  final String user;
  final DateTime timestamp;
  final Map<String, String> tags;

  Version(this.user, this.timestamp, this.tags);
}

class ElementVersion {
  final int version;
  final String user;
  final DateTime timestamp;
  final Map<String, String> tags;
  // tags added since previous version
  final Set<String> addedTags;
  // tags removed since previous version. also store removed values to show in diff
  final Map<String, String> removedTags;
  // tags that have same keys but different value since previous version
  final Map<String, TagChange> updatedTags;

  // don't need to show diff when no tags have changed
  bool get noTagChange =>
      addedTags.isEmpty && removedTags.isEmpty && updatedTags.isEmpty;

  const ElementVersion(this.version, this.tags, this.addedTags,
      this.removedTags, this.updatedTags, this.user, this.timestamp);

  @override
  String toString() {
    return "$version: added: $addedTags, removed: $removedTags, changed: $updatedTags. current: $tags";
  }
}

class VersionsPage extends ConsumerStatefulWidget {
  final String fullRef;
  final Uri historyUrl;
  final Map<String, String?> localChanges;

  const VersionsPage(this.fullRef, this.historyUrl, this.localChanges);

  @override
  ConsumerState<VersionsPage> createState() => _VersionsPageState();
}

class _VersionsPageState extends ConsumerState<VersionsPage> {
  List<ElementVersion> versions = [];

  Future<List<Version>> getHistory(String fullRef) async {
    final resp = await http.get(
        Uri.https(kOsmEndpoint, '/api/0.6/$fullRef/history'),
        headers: {"Accept": "application/json"}
    );
    if (resp.statusCode == 404) {
      throw OsmApiError(
          resp.statusCode, 'Could not find history for $fullRef: ${resp.body}');
    }
    if (resp.statusCode != 200) {
      throw OsmApiError(
          resp.statusCode, 'Failed to fetch history: ${resp.body}');
    }

    print(resp.body);

    // FIXME: this may not handle large histories well
    final doc = XmlDocument.parse(resp.body);
    final versionNodes = doc.getElement("osm")!.children;

    // FIXME: this is pretty crap. doing something like https://stackoverflow.com/a/63332937
    // would probably be better
    final versions = versionNodes
    // for some reason there are various empty text nodes. maybe this can be fixed in the parser
        .where(
          (t) => t.nodeType == XmlNodeType.ELEMENT,
    )
        .map(
          (t) => Version(
        t.getAttribute("user")!,
        DateTime.parse(t.getAttribute("timestamp")!),
        t
            .findElements("tag")
            .map((tag) => {tag.getAttribute("k")!: tag.getAttribute("v")!})
            .reduce(
              (value, element) {
            value.addAll(element);
            return value;
          },
        ),
      ),
    );

    return versions.toList();
  }

  _doVersionsStuff() async {
    final plainVersions =
        await getHistory(widget.fullRef);

    // merge in the local changes to the remote ones, based from the latest remote versions
    var mergedLocalVersion =
        Map.from(plainVersions.last.tags).cast<String, String?>();
    mergedLocalVersion.addAll(widget.localChanges);

    for (var tag in Map.from(mergedLocalVersion).entries) {
      // null values are removed tags
      if (tag.value == null) {
        mergedLocalVersion.remove(tag.key);
      }
    }
    plainVersions.add(Version(
        "you", DateTime.now(), mergedLocalVersion.cast<String, String>()));

    var diffedVersions = <ElementVersion>[];
    var previousVersion = <String, String>{};

    for (var i = 0; i < plainVersions.length; i++) {
      var currentVersion = plainVersions[i];
      var updatedTagKeys = currentVersion.tags.keys
          .toSet()
          .intersection(previousVersion.keys.toSet());

      var updatedTags = <String, TagChange>{};
      for (var key in updatedTagKeys) {
        if (previousVersion[key] != currentVersion.tags[key]) {
          updatedTags.addAll({
            key: TagChange(previousVersion[key]!, currentVersion.tags[key]!)
          });
        }
      }

      var removedTagKeys = previousVersion.keys
          .toSet()
          .difference(currentVersion.tags.keys.toSet());
      var removedTags = <String, String>{};
      for (var key in removedTagKeys) {
        removedTags[key] = previousVersion[key]!;
      }

      diffedVersions.add(ElementVersion(
          plainVersions.length - i,
          currentVersion.tags,
          currentVersion.tags.keys
              .toSet()
              .difference(previousVersion.keys.toSet()),
          removedTags,
          updatedTags,
          currentVersion.user,
          currentVersion.timestamp));
      previousVersion = currentVersion.tags;
    }

    setState(() => {versions = diffedVersions});
  }

  @override
  void initState() {
    super.initState();
    _doVersionsStuff();
  }

  _buildLoader() {
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
      body: versions.isEmpty
          ? _buildLoader()
          // FIXME: way too much nesting here
          : ListView(
              children: [
                for (var i = versions.length - 1; i >= 0; i--)
                  Card(
                    margin: EdgeInsets.only(top: 12, right: 12, left: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              i != versions.length - 1
                                  ? 'Version #${(i + 1).toString()}'
                                  : 'Local changes', // TODO: doesn't make much sense to show local changes when there aren't any
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                          if (i != versions.length - 1)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                'by ${versions[i].user} at ${DateFormat.yMMMMd().add_Hm().format(versions[i].timestamp)}',
                              ),
                            ),
                          // FIXME: these are pretty gross. should probably extract stuff here...
                          if (versions[i].noTagChange) ...[
                            Text("No tag changes")
                          ] else ...[
                            Table(
                              border: TableBorder.all(
                                width: 1,
                                color: Colors.grey,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(3),
                                ),
                              ),
                              children: [
                                for (final tag in versions[i].tags.entries)
                                  if (versions[i]
                                      .addedTags
                                      .contains(tag.key)) ...[
                                    TableRow(
                                      // FIXME: these BoxDecorations clip outside of the BorderRadius
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade100,
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
                                        Container(),
                                        Padding(
                                          padding: const EdgeInsets.all(6),
                                          child: Text(tag.value),
                                        )
                                      ],
                                    ),
                                  ] else ...[
                                    TableRow(
                                      decoration: BoxDecoration(
                                        color:
                                            versions[i].updatedTags[tag.key] !=
                                                    null
                                                ? Colors.amber.shade200
                                                : null,
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
                                          child: Text(versions[i]
                                                  .updatedTags[tag.key]
                                                  ?.oldValue ??
                                              ""),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(6),
                                          child: Text(tag.value),
                                        ),
                                      ],
                                    ),
                                  ],
                                // TODO: would be nice if deleted tags were interlaced alphabetically with the others
                                for (final tag
                                    in versions[i].removedTags.entries)
                                  TableRow(
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade100,
                                    ),
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(6),
                                        child: Text(
                                          tag.key,
                                          style: TextStyle(
                                            decoration:
                                                TextDecoration.lineThrough,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(6),
                                        child: Text(
                                          tag.value,
                                          style: TextStyle(
                                            decoration:
                                                TextDecoration.lineThrough,
                                          ),
                                        ),
                                      ),
                                      Container()
                                    ],
                                  )
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                // bottom padding
                Container(height: 10)
              ],
            ),
    );
  }
}

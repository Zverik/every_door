import 'package:every_door/constants.dart';
import 'package:every_door/screens/settings/log.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends ConsumerStatefulWidget {
  const AboutPage();

  @override
  ConsumerState<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends ConsumerState<AboutPage> {
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      // FIXME: internationalise this title
      appBar: AppBar(
        title: Text('About $kAppTitle v$kAppVersion'),
      ),
      body: SettingsList(
        contentPadding: EdgeInsets.symmetric(vertical: 10.0),
        sections: [
          SettingsSection(
            // FIXME: internationalise
            title: Text("Help improve $kAppTitle"),
            tiles: [
              SettingsTile(
                // FIXME: all these translations should be `about- instead of settings-`
                title: Text(loc.settingsReportIssue),
                trailing: Icon(Icons.exit_to_app),
                description: Text(loc.settingsOnGitHub),
                onPressed: (context) {
                  launchUrl(
                      Uri.https("github.com", "/Zverik/every_door/issues"),
                      mode: LaunchMode.externalApplication);
                },
              ),
              SettingsTile(
                title: Text(loc.settingsHelpTranslate),
                trailing: Icon(Icons.exit_to_app),
                description: Text(loc.settingsOnWeblate),
                onPressed: (context) {
                  launchUrl(
                      Uri.https(
                          "hosted.weblate.org", "/projects/every-door/app/"),
                      mode: LaunchMode.externalApplication);
                },
              ),
              SettingsTile(
                title: Text(loc.settingsViewLog),
                trailing: Icon(Icons.navigate_next),
                onPressed: (context) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LogDisplayPage()),
                  );
                },
              ),
            ],
          ),
          SettingsSection(
            // FIXME: internationalise
            title: Text("Links"),
            tiles: [
              SettingsTile(
                title: Text(loc.settingsVersionHistory),
                description: Text(loc.settingsInstalledVersion(kAppVersion)),
                trailing: Icon(Icons.exit_to_app),
                onPressed: (context) {
                  launchUrl(
                      Uri.https("github.com", "/Zverik/every_door/releases"),
                      mode: LaunchMode.externalApplication);
                },
              ),
              SettingsTile(
                title: Text(loc.settingsProjectWebsite),
                trailing: Icon(Icons.exit_to_app),
                onPressed: (context) {
                  launchUrl(Uri.https("every-door.app", "/"),
                      mode: LaunchMode.externalApplication);
                },
              ),
              SettingsTile(
                title: Text(loc.settingsSourceCode),
                trailing: Icon(Icons.exit_to_app),
                description: Text(loc.settingsOnGitHub),
                onPressed: (context) {
                  launchUrl(Uri.https("github.com", "/Zverik/every_door/"),
                      mode: LaunchMode.externalApplication);
                },
              ),
              SettingsTile(
                title: Text(loc.settingsLicense),
                trailing: Icon(Icons.exit_to_app),
                description: Text("ISC"),
                onPressed: (context) {
                  launchUrl(
                      Uri.https(
                          "github.com", "/Zverik/every_door/blob/main/LICENSE"),
                      mode: LaunchMode.externalApplication);
                },
              ),
            ],
          ),
          SettingsSection(
            // FIXME: internationalise
            title: Text("FAQs"),
            tiles: [
              CustomSettingsTile(
                child: Padding(
                    padding: EdgeInsets.only(
                        left: 23, top: 10, right: 25, bottom: 10),
                    // FIXME: hacky way of including FAQs
                    child: MarkdownBody(
                      onTapLink: (text, href, title) {
                        launchUrl(Uri.parse(href!),
                            mode: LaunchMode.externalApplication);
                      },
                      data: """## Why the map is so tiny?

Because it's not the point. You only check your positioning on the map,
and pan it to adjust. Watch the amenity list below, sorted by distance
from you.

The map gets bigger when you edit amenities far from your location.
Although the app was made to edit things you see with your eyes.

## What are the checkmarks for?

These are marks that amenity data was confirmed. They add the
`check_date` tag with the current date.

The idea behind the checkmarks is that, say, you surveyed half
the city the first time. Then after a month you came back and
went to survey again. You need to somehow mark that you see
the amenity, but nothing has changed about it. That's the checkmark:
you tap it and continue.

The mark stays checked for two weeks. After that you may survey
the amenities again.

## Why the app is in German?

If you expect English, try going to the phone Settings. There find
"System", and "Languages". Try adding the English language to the list
and restarting the editor.

There'll be a language switcher in the app later.

## How to add a building entrance?

At the top right there's a button for switching editing modes.
It changes modes between amenities, micromapping, and entrances.

In the entrance mode, tap or drag the door button in the bottom
right corner onto the map.

## Can I type letters into an apartment number?

If your numeric keyboard cannot be switched to a full one, check
the app settings. They are behind the button at the top left corner.
Switch on the "extended numeric keyboard" there.

## Are floors "3" and "/3" the same?

No. The first one has `addr:floor=3` tag filled. That's the floor
as it is printed on navigation and commonly used. The second one
does not have this tag, but has `level=3`. That number is a sequential
floor number from zero to `building:levels - 1`. That is, in a
three-storey building `addr:floor` value depends on a country,
but `level` is always 0, 1, or 2.

Here is how the notation in the editor related to these tags:

* `2`: `addr:floor=2` and non-empty `level=*`.
* `4/`: `addr:floor=4`, but there's no `level` tag.
* `/1`: `level=1`, but there's no `addr:floor` tag.
* `1/0`: `addr:floor=1` + `level=0` (and there's an object nearby
  with the same `addr:floor`, but different `level`, or vice-versa).

## All tagging questions

Why an object is missing in the editor? When these white dots are
displayed in the micromapping mode? How objects are sorted?

Answers to all these questions are in
[good_tags.dart](https://github.com/Zverik/every_door/blob/main/lib/helpers/good_tags.dart).
Here's what you can look at:

* The key order for the main tag — list `kMainKeys`.
* Which objects are downloaded — function `isGoodTags`.
* What is considered an amenity — function `isAmenityTags`.
* Which points are snapped to what ways — function `detectSnap`.
* When a micromapping object is incomplete — function `needsMoreInfo`.

## How to change or translate preset fields?

The editor relies on iD editor presets. To modify these, submit
a pull request to [this repo](https://github.com/openstreetmap/id-tagging-schema).

The presets are translated at [Transifex](https://www.transifex.com/openstreetmap/id-editor/translate/#ru/presets/).

To translate value options, first make a pull request to the repo
adding desired options, [like here](https://github.com/openstreetmap/id-tagging-schema/blob/main/data/fields/camera/type.json).
Then, when the translation source on Transifex is updated, there
will be strings to translate.
[Like here](https://www.transifex.com/openstreetmap/id-editor/translate/#ru/presets/101711314?q=key%3Apresets.fields.camera%2Ftype).
""",
                    )),
              ),
            ],
          )
        ],
      ),
    );
  }
}

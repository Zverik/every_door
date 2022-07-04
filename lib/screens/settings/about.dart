import 'package:every_door/constants.dart';
import 'package:every_door/screens/settings/log.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class FAQ {
  final String question;
  final String answer;
  const FAQ(this.question, this.answer);

  Widget toTile() {
    return ExpansionTile(
      title: Text(question),
      childrenPadding: EdgeInsets.only(bottom: 22, left: 22, right: 22),
      tilePadding: EdgeInsets.symmetric(horizontal: 22),
      children: <Widget>[
        MarkdownBody(
            onTapLink: (text, href, title) => launchUrl(Uri.parse(href!),
                mode: LaunchMode.externalApplication),
            data: answer)
      ],
    );
  }
}

const faqs = <FAQ>[
  FAQ("Why the map is so tiny?",
      """Because it's not the point. You only check your positioning on the map,
and pan it to adjust. Watch the amenity list below, sorted by distance
from you.

The map gets bigger when you edit amenities far from your location.
Although the app was made to edit things you see with your eyes."""),
  FAQ("What are the checkmarks for?",
      """These are marks that amenity data was confirmed. They add the
`check_date` tag with the current date.

The idea behind the checkmarks is that, say, you surveyed half
the city the first time. Then after a month you came back and
went to survey again. You need to somehow mark that you see
the amenity, but nothing has changed about it. That's the checkmark:
you tap it and continue.

The mark stays checked for two weeks. After that you may survey
the amenities again."""),
  FAQ("How to add a building entrance?",
      """At the top right there's a button for switching editing modes.
It changes modes between amenities, micromapping, and entrances.

In the entrance mode, tap or drag the door button in the bottom
right corner onto the map."""),
  FAQ("Can I type letters into an apartment number?",
      """If your numeric keyboard cannot be switched to a full one, check
the app settings. They are behind the button at the top left corner.
Switch on the "extended numeric keyboard" there."""),
  FAQ("Are floors '3' and '/3' the same?",
      """No. The first one has `addr:floor=3` tag filled. That's the floor
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
"""),
  FAQ("All tagging questions",
      """Why an object is missing in the editor? When these white dots are
displayed in the micromapping mode? How objects are sorted?

Answers to all these questions are in
[good_tags.dart](https://github.com/Zverik/every_door/blob/main/lib/helpers/good_tags.dart).
Here's what you can look at:

* The key order for the main tag — list `kMainKeys`.
* Which objects are downloaded — function `isGoodTags`.
* What is considered an amenity — function `isAmenityTags`.
* Which points are snapped to what ways — function `detectSnap`.
* When a micromapping object is incomplete — function `needsMoreInfo`.""")
];

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
      appBar: AppBar(
        title: Text(loc.aboutVersion(kAppTitle, kAppVersion)),
      ),
      body: SettingsList(
        contentPadding: EdgeInsets.symmetric(vertical: 10.0),
        sections: [
          SettingsSection(
            title: Text(loc.aboutHelpImprove(kAppTitle)),
            tiles: [
              SettingsTile(
                title: Text(loc.aboutReportIssue),
                trailing: Icon(Icons.exit_to_app),
                description: Text(loc.aboutOnGitHub),
                onPressed: (context) {
                  launchUrl(
                      Uri.https("github.com", "/Zverik/every_door/issues"),
                      mode: LaunchMode.externalApplication);
                },
              ),
              SettingsTile(
                title: Text(loc.aboutHelpTranslate),
                trailing: Icon(Icons.exit_to_app),
                description: Text(loc.aboutOnWeblate),
                onPressed: (context) {
                  launchUrl(
                      Uri.https(
                          "hosted.weblate.org", "/projects/every-door/app/"),
                      mode: LaunchMode.externalApplication);
                },
              ),
              SettingsTile(
                title: Text(loc.aboutViewLog),
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
            title: Text(loc.aboutLinks),
            tiles: [
              SettingsTile(
                title: Text(loc.aboutVersionHistory),
                description: Text(loc.aboutInstalledVersion(kAppVersion)),
                trailing: Icon(Icons.exit_to_app),
                onPressed: (context) {
                  launchUrl(
                      Uri.https("github.com", "/Zverik/every_door/releases"),
                      mode: LaunchMode.externalApplication);
                },
              ),
              SettingsTile(
                title: Text(loc.aboutProjectWebsite),
                trailing: Icon(Icons.exit_to_app),
                onPressed: (context) {
                  launchUrl(Uri.https("every-door.app", "/"),
                      mode: LaunchMode.externalApplication);
                },
              ),
              SettingsTile(
                title: Text(loc.aboutSourceCode),
                trailing: Icon(Icons.exit_to_app),
                description: Text(loc.aboutOnGitHub),
                onPressed: (context) {
                  launchUrl(Uri.https("github.com", "/Zverik/every_door/"),
                      mode: LaunchMode.externalApplication);
                },
              ),
              SettingsTile(
                title: Text(loc.aboutLicense),
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
            title: Text(loc.aboutFAQs),
            tiles: [
              CustomSettingsTile(
                child: Padding(
                  padding: EdgeInsets.only(top: 5),
                  child: Column(
                    children: <Widget>[for (var faq in faqs) faq.toTile()],
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

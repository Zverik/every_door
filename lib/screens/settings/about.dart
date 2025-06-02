import 'package:every_door/constants.dart';
import 'package:every_door/screens/settings/log.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class FAQ {
  final String question;
  final String answer;

  const FAQ(this.question, this.answer);
}

class AboutPage extends StatelessWidget {
  const AboutPage();

  List<FAQ> buildFaq(AppLocalizations loc) {
    return <FAQ>[
      FAQ(loc.faqMapTiny, loc.faqMapTinyContent),
      FAQ(loc.faqCheckmarks, loc.faqCheckmarksContent),
      FAQ(loc.faqEntrance, loc.faqEntranceContent),
      FAQ(loc.faqYellow, loc.faqYellowContent),
      FAQ(loc.faqLetters, loc.faqLettersContent),
      FAQ(loc.faqFloors, loc.faqFloorsContent),
      FAQ(loc.faqChangeType, loc.faqChangeTypeContent),
      FAQ(loc.faqTagging, loc.faqTaggingContent),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text('${loc.settingsAbout} $kAppTitle $kAppVersion'),
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
                description: Text('${loc.aboutInstalledVersion}: $kAppVersion'),
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
            title: Text(loc.aboutFAQ),
            tiles: [
              for (final faq in buildFaq(loc))
                CustomSettingsTile(
                    child: ExpansionTile(
                  title: Text(faq.question, style: TextStyle(fontSize: 18.0)),
                  childrenPadding:
                      EdgeInsets.only(bottom: 22, left: 24, right: 24),
                  tilePadding: EdgeInsets.symmetric(horizontal: 24),
                  children: <Widget>[
                    MarkdownBlock(
                        config: MarkdownConfig(
                          configs: [
                            LinkConfig(
                              onTap: (href) => launchUrl(Uri.parse(href),
                                  mode: LaunchMode.externalApplication),
                            ),
                          ],
                        ),
                        data: faq.answer)
                  ],
                )),
            ],
          )
        ],
      ),
    );
  }
}

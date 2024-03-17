import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:every_door/providers/osm_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class OsmAccountPage extends ConsumerStatefulWidget {
  const OsmAccountPage({super.key});

  @override
  ConsumerState<OsmAccountPage> createState() => _OsmAccountPageState();
}

class _OsmAccountPageState extends ConsumerState<OsmAccountPage> {
  bool canUseOAuth = true;
  OsmUserDetails? details;

  @override
  void initState() {
    super.initState();
    updateOAuth();
    updateDetails();
  }

  updateOAuth() async {
    bool newCanUseOAuth =
        await ref.read(authProvider.notifier).supportsOAuthLogin();
    setState(() {
      canUseOAuth = newCanUseOAuth;
    });
  }

  Future updateDetails() async {
    final auth = ref.read(authProvider.notifier);
    final newDetails = auth.authorized ? await auth.loadUserDetails() : null;
    setState(() {
      details = newDetails;
    });
  }

  showLoginDialog(BuildContext context) async {
    final loc = AppLocalizations.of(context)!;
    final isOk = await showOkCancelAlertDialog(
      context: context,
      title: loc.accountPasswordWarningTitle,
      message: loc.accountPasswordWarningMessage,
      okLabel: loc.accountPasswordWarningButton,
    );
    if (isOk != OkCancelResult.ok) return;

    bool done = false;
    List<String>? result;
    while (!done) {
      if (!mounted) return;
      result = await showTextInputDialog(
        context: context,
        title: loc.accountPasswordTitle,
        textFields: [
          DialogTextField(
            hintText: loc.accountFieldLogin,
            initialText:
                result?[0] ?? ref.watch(authProvider)?.displayName ?? '',
          ),
          DialogTextField(
            hintText: loc.accountFieldPassword,
            keyboardType: TextInputType.visiblePassword,
            obscureText: true,
          ),
        ],
      );
      if (result != null) {
        final auth = ref.read(authProvider.notifier);
        try {
          await auth.storeLoginPassword(result[0], result[1]);
          done = true;
          updateDetails();
        } on ArgumentError {
          // Wrong login
          if (mounted) {
            await showAlertDialog(
              context: context,
              title: loc.accountAuthErrorTitle,
              message: loc.accountAuthErrorMessage,
            );
          }
        }
      } else {
        done = true;
      }
    }
  }

  loginWithOAuth() async {
    try {
      await ref.read(authProvider.notifier).loginWithOAuth(context);
      updateDetails();
    } on Exception catch (e) {
      if (!mounted) return;
      final loc = AppLocalizations.of(context)!;
      await showAlertDialog(
        context: context,
        message: e.toString(),
        title: loc.accountOAuthError,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final login = ref.watch(authProvider)?.displayName;
    Widget content;
    if (login == null) {
      // not logged in
      content = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
              onPressed: !canUseOAuth ? null : loginWithOAuth,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 30.0,
                  horizontal: 15.0,
                ),
                child: Text(
                  loc.accountLoginOAuth,
                  style: TextStyle(fontSize: 30.0),
                ),
              )),
          SizedBox(height: 20.0),
          ElevatedButton(
              onPressed: () {
                showLoginDialog(context);
              },
              // style: ButtonStyle(backgroundColor: Colors.grey.shade100),
              child: Text(
                loc.accountLoginPassword,
                style: TextStyle(fontSize: 18.0),
              )),
        ],
      );
    } else {
      content = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (details?.avatar != null)
            CachedNetworkImage(imageUrl: details!.avatar!),
          SizedBox(height: 20.0),
          Text(login),
          SizedBox(height: 20.0),
          if (details != null) ...[
            Text('${loc.accountChangesets}: ${details!.changesets}'),
            Text('${loc.accountUnreadMail}: ${details!.unreadMessages}'),
            SizedBox(height: 20.0),
          ],
          ElevatedButton(
              onPressed: () async {
                if (await showOkCancelAlertDialog(
                      context: context,
                      title: loc.accountLogout + '?',
                      okLabel: loc.accountLogout.toUpperCase(),
                      isDestructiveAction: true,
                    ) ==
                    OkCancelResult.ok) {
                  // logout
                  ref.read(authProvider.notifier).logout();
                  setState(() {
                    details = null;
                  });
                }
              },
              child: Text(loc.accountLogout)),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.accountTitle),
      ),
      body: Center(child: content),
    );
  }
}

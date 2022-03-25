import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:every_door/providers/osm_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OsmAccountPage extends ConsumerStatefulWidget {
  const OsmAccountPage({Key? key}) : super(key: key);

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

  updateDetails() async {
    final auth = ref.read(authProvider.notifier);
    final newDetails = auth.authorized ? await auth.loadUserDetails() : null;
    setState(() {
      details = newDetails;
    });
  }

  showLoginDialog(BuildContext context) async {
    final isOk = await showOkCancelAlertDialog(
      context: context,
      title: 'Warning',
      message:
          'Your password will be stored on the device. Only choose this when OAuth fails.',
      okLabel: 'Understood',
    );
    if (isOk != OkCancelResult.ok) return;

    bool done = false;
    List<String>? result;
    while (!done) {
      result = await showTextInputDialog(
        context: context,
        title: 'OSM Login and Password',
        textFields: [
          DialogTextField(
            hintText: 'Login',
            initialText: result?[0] ?? ref.watch(authProvider),
          ),
          DialogTextField(
            hintText: 'Password',
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
          await showAlertDialog(
            context: context,
            title: 'Auth Error',
            message: 'Wrong login or password.',
          );
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
      await showAlertDialog(
        context: context,
        message: e.toString(),
        title: 'OAuth Error',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final login = ref.watch(authProvider);
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
                  'Login With OAuth',
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
                'Login with password',
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
          Text(login),
          SizedBox(height: 20.0),
          if (details != null) ...[
            Text('Changesets: ${details!.changesets}'),
            Text('Unread mail: ${details!.unreadMessages}'),
            SizedBox(height: 20.0),
          ],
          ElevatedButton(
              onPressed: () async {
                if (await showOkCancelAlertDialog(
                      context: context,
                      title: 'Log out',
                      okLabel: 'Logout',
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
              child: Text('Log out')),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('OpenStreetMap Account'),
      ),
      body: Center(child: content),
    );
  }
}

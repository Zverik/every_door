import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:every_door/providers/osm_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:every_door/generated/l10n/app_localizations.dart' show AppLocalizations;

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
    updateDetails();
  }

  Future updateDetails() async {
    final auth = ref.read(authProvider.notifier);
    final newDetails = auth.authorized ? await auth.loadUserDetails() : null;
    setState(() {
      details = newDetails;
    });
  }

  Future<void> showLoginDialog(BuildContext context) async {
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
      if (!context.mounted) return;
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
          // await auth.storeLoginPassword(result[0], result[1]);
          done = true;
          updateDetails();
        } on ArgumentError {
          // Wrong login
          if (context.mounted) {
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

  Future<void> loginWithOAuth() async {
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
    final theme = Theme.of(context);

    Widget content;
    if (login == null) {
      // not logged in - keep original UI
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
        ],
      );
    } else {
      // logged in - updated UI
      content = SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Conditional avatar: network image or icon
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: details?.avatar != null
                      ? CircleAvatar(
                          radius: 60,
                          backgroundImage:
                              CachedNetworkImageProvider(details!.avatar!),
                        )
                      : CircleAvatar(
                          radius: 60,
                          backgroundColor: theme.colorScheme.primaryContainer,
                          child: Icon(
                            Icons.person,
                            size: 60,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                ),
                const SizedBox(height: 20),
                Text(
                  login,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 20),
                if (details != null) ...[
                  Container(
                    constraints: BoxConstraints(maxWidth: 400.0),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            _buildStatRow(
                              loc.accountChangesets,
                              details!.changesets.toString(),
                              theme,
                            ),
                            const SizedBox(height: 10),
                            _buildStatRow(
                              loc.accountUnreadMail,
                              details!.unreadMessages.toString(),
                              theme,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.error,
                    foregroundColor: theme.colorScheme.onError,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12.0,
                      horizontal: 40.0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    loc.accountLogout,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onError,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.accountTitle),
      ),
      body: Center(child: content),
    );
  }

  Widget _buildStatRow(String label, String value, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }
}

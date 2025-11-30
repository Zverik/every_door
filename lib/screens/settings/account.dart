import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:every_door/helpers/auth/osm.dart';
import 'package:every_door/providers/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:every_door/generated/l10n/app_localizations.dart'
    show AppLocalizations;

class AccountPage extends ConsumerStatefulWidget {
  final String provider;

  const AccountPage(this.provider, {super.key});

  @override
  ConsumerState<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends ConsumerState<AccountPage> {
  Future<void> login() async {
    try {
      await ref.read(authProvider)[widget.provider]!.login(context);
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
    final details = ref.watch(authProvider)[widget.provider]!.value;
    final theme = Theme.of(context);

    Widget content;
    if (details == null) {
      // not logged in - keep original UI
      content = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
              onPressed: login,
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
                if (details is OsmUserDetails) ...[
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
                    child: details.avatar != null
                        ? CircleAvatar(
                            radius: 60,
                            backgroundImage:
                                CachedNetworkImageProvider(details.avatar!),
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
                ],
                Text(
                  details.displayName,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 20),
                if (details is OsmUserDetails) ...[
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
                              details.changesets.toString(),
                              theme,
                            ),
                            const SizedBox(height: 10),
                            _buildStatRow(
                              loc.accountUnreadMail,
                              details.unreadMessages.toString(),
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
                      await ref.read(authProvider)[widget.provider]!.logout();
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

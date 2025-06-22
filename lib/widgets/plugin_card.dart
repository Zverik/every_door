import 'package:every_door/models/plugin.dart';
import 'package:flutter/material.dart';
import 'package:every_door/generated/l10n/app_localizations.dart'
    show AppLocalizations;

class PluginCard extends StatelessWidget {
  final PluginData plugin;
  final bool active;
  final String? actionText;
  final Function()? onAction;
  final Function()? onMore;

  const PluginCard(
      {super.key,
      required this.plugin,
      this.active = true,
      this.onAction,
      this.onMore,
      this.actionText});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    String description = plugin.description
        .replaceAll('\n\n', '#NL#')
        .replaceAll('\n', ' ')
        .replaceAll('#NL#', '\n\n');
    return Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(plugin.name),
            subtitle: Text('v${plugin.version}' +
                (plugin.author == null ? '' : ' by ${plugin.author}')),
            leading: plugin.icon?.getWidget(icon: false, size: 30),
            enabled: active,
            onTap: onMore,
          ),
          if (description.isNotEmpty)
            Padding(
              padding:
                  const EdgeInsets.only(left: 16.0, right: 24.0, bottom: 16.0),
              child: Text(
                description,
                style: theme.listTileTheme.subtitleTextStyle ??
                    theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodySmall?.color,
                    ),
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (actionText != null && onAction != null)
                TextButton(
                  child: Text(actionText ?? 'ACTION'),
                  onPressed: onAction,
                ),
              if (onMore != null)
                TextButton(
                  child: Text(loc.pluginsMore.toUpperCase()),
                  onPressed: onMore,
                ),
              const SizedBox(width: 8.0),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:every_door/providers/editor_mode.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:settings_ui/settings_ui.dart';

class ModeSection extends AbstractSettingsSection {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: ModeButton(
            icon: Icon(Icons.shopping_cart),
            title: 'POI',
            mode: EditorMode.poi,
          ),
        ),
        Expanded(
          child: ModeButton(
            icon: Icon(Icons.park),
            title: 'Micromapping',
            mode: EditorMode.micromapping,
          ),
        ),
        Expanded(
          child: ModeButton(
            icon: Icon(Icons.home),
            title: 'Entrances',
            mode: EditorMode.entrances,
          ),
        ),
      ],
    );
  }
}

class ModeButton extends ConsumerWidget {
  final Widget icon;
  final String title;
  final EditorMode mode;

  const ModeButton({
    required this.icon,
    required this.title,
    required this.mode,
  }) : super();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.read(editorModeProvider);

    return GestureDetector(
      child: Card(
        color: current != mode ? null : Colors.green,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Column(
            children: [
              IconTheme.merge(
                  child: icon,
                  data: IconThemeData(
                    color: current != mode ? null : Colors.white,
                  )),
              SizedBox(height: 10.0),
              Text(
                title,
                style: current != mode
                    ? null
                    : TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
              ),
            ],
          ),
        ),
      ),
      onTap: () {
        ref.read(editorModeProvider.notifier).set(mode);
        Navigator.pop(context);
      },
    );
  }
}

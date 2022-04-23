import 'package:every_door/providers/imagery.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ImageryPage extends ConsumerWidget {
  const ImageryPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imagery = ref.watch(imageryProvider);
    final imageryList = ref.watch(imageryListProvider);
    final loc = AppLocalizations.of(context)!;

    final imageryListWidget = imageryList.when(
      data: (list) => ListView.separated(
        itemBuilder: (context, index) => ListTile(
          title: Text(list[index].name),
          trailing: list[index].id == imagery.id ? Icon(Icons.check) : null,
          leading: list[index].icon == null
              ? null
              : Image(
                  image: NetworkImage(list[index].icon!),
                  height: 30.0,
                  width: 30.0,
                ),
          onTap: () {
            ref.read(imageryProvider.notifier).setImagery(list[index]);
            Navigator.pop(context);
          },
        ),
        separatorBuilder: (context, index) => Divider(),
        itemCount: list.length,
      ),
      error: (obj, st) => Center(
        child: Text('Could not load imagery list\n$obj'),
      ),
      loading: () => Center(
        child: CircularProgressIndicator(),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.settingsBackground),
      ),
      body: imageryListWidget,
    );
  }
}

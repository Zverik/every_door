import 'package:every_door/models/imagery.dart';
import 'package:every_door/providers/imagery.dart';
import 'package:every_door/providers/location.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:every_door/generated/l10n/app_localizations.dart' show AppLocalizations;

class ImageryPage extends ConsumerStatefulWidget {
  const ImageryPage();

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => ImageryPageState();
}

class ImageryPageState extends ConsumerState {
  late Future<List<Imagery>> imageryList;

  @override
  void initState() {
    super.initState();
    imageryList = ref
        .read(imageryProvider.notifier)
        .getImageryListForLocation(ref.read(effectiveLocationProvider));
  }

  @override
  Widget build(BuildContext context) {
    final imagery = ref.watch(imageryProvider);
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.settingsBackground),
      ),
      body: FutureBuilder(
        future: imageryList,
        builder: (context, AsyncSnapshot<List<Imagery>> snapshot) {
          if (snapshot.hasData) {
            final list = snapshot.data!;
            return ListView.separated(
              itemBuilder: (context, index) => ListTile(
                title: Text(list[index].name ?? list[index].id),
                trailing:
                    list[index].id == imagery.id ? Icon(Icons.check) : null,
                leading: list[index].icon?.getWidget(size: 30.0, icon: false),
                onTap: () {
                  ref.read(imageryProvider.notifier).setImagery(list[index]);
                  Navigator.of(context).popUntil((r) => r.isFirst);
                },
              ),
              separatorBuilder: (context, index) => Divider(),
              itemCount: list.length,
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Could not load imagery list\n${snapshot.error}'),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}

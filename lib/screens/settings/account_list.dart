// Copyright 2022-2025 Ilya Zverev
// This file is a part of Every Door, distributed under GPL v3 or later version.
// Refer to LICENSE file and https://www.gnu.org/licenses/gpl-3.0.html for details.
import 'package:every_door/providers/auth.dart';
import 'package:every_door/screens/settings/account.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AccountListPage extends ConsumerWidget {
  const AccountListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Accounts"), // TODO
      ),
      body: ListView(
        children: [
          for (final account in ref.watch(authProvider).values)
            ListTile(
              title: Text(account.provider.title ?? account.name),
              subtitle: account.value == null
                  ? null
                  : Text(account.value?.displayName ?? ''),
              leading: account.provider.icon?.getWidget(
                context: context,
                icon: true,
                size: 30.0,
              ),
              trailing: Icon(Icons.navigate_next),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => AccountPage(account.name),
                ));
              },
            ),
        ],
      ),
    );
  }
}

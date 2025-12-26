// Copyright 2022-2025 Ilya Zverev
// This file is a part of Every Door, distributed under GPL v3 or later version.
// Refer to LICENSE file and https://www.gnu.org/licenses/gpl-3.0.html for details.
import 'package:every_door/constants.dart';
import 'package:every_door/helpers/geometry/equirectangular.dart';
import 'package:every_door/models/payment_local.dart';
import 'package:every_door/providers/database.dart';
import 'package:every_door/providers/editor_settings.dart';
import 'package:every_door/providers/osm_data.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:proximity_hash/proximity_hash.dart';
import 'package:sqflite/utils/utils.dart';

final paymentProvider = Provider((ref) => PaymentProvider(ref));

class PaymentOptions {
  final LocalPayment? local;
  final Set<String> global;
  final Set<String> around;

  static const initial =
      PaymentOptions(global: {'payment:debit_cards', 'payment:credit_cards'});

  const PaymentOptions(
      {this.local, required this.global, this.around = const {}});

  Set<String> get merged => local?.options ?? global;
  bool get aroundDiffers => around.isNotEmpty && !setEquals(around, merged);
}

class PaymentProvider {
  final Ref _ref;

  PaymentProvider(this._ref);

  Future<LocalPayment?> getPaymentForLocation(LatLng location) async {
    // Read the closest payment options from the database and sort by distance.
    final database = await _ref.read(databaseProvider).database;
    final hashes = createGeohashes(location.latitude, location.longitude,
        kLocalPaymentRadius.toDouble(), LocalPayment.kGeohashPrecision);
    final placeholders = List.generate(hashes.length, (index) => "?").join(",");
    final rows = await database.query(
      LocalPayment.kTableName,
      where: "geohash in ($placeholders)",
      whereArgs: hashes,
    );
    final localOptions = rows.map((row) => LocalPayment.fromJson(row)).toList();
    const distance = DistanceEquirectangular();
    localOptions.sort((a, b) =>
        distance(location, a.center).compareTo(distance(location, b.center)));

    // If we got the local option, return it.
    if (localOptions.isEmpty ||
        distance(location, localOptions.first.center) > kLocalPaymentRadius) {
      return null;
    }
    return localOptions.first;
  }

  /// Convenience method to query all three data sources.
  Future<PaymentOptions> getAllPaymentOptions(LatLng location) async {
    final defaultPayment = _ref.read(editorSettingsProvider).defaultPayment;
    final localPayment = await getPaymentForLocation(location);
    // Note that it returns the default payment in case we haven't found any.
    final paymentAround =
        await _ref.read(osmDataProvider).getCardPaymentOptions(location);
    return PaymentOptions(
      global: defaultPayment.map((k) => 'payment:$k').toSet(),
      local: localPayment,
      around: paymentAround,
    );
  }

  Future saveLocalPayment(Iterable<String> options, LatLng location) async {
    final database = await _ref.read(databaseProvider).database;
    final maxId = firstIntValue(await database.query(
      LocalPayment.kTableName,
      columns: ['max(id)'],
    ));
    final id = maxId == null ? 1 : maxId + 1;
    await database.insert(
      LocalPayment.kTableName,
      LocalPayment(id: id, center: location, options: options.toSet()).toJson(),
    );
  }

  Future deleteLocalPayment(LocalPayment payment) async {
    final database = await _ref.read(databaseProvider).database;
    await database.delete(
      LocalPayment.kTableName,
      where: 'id = ?',
      whereArgs: [payment.id],
    );
  }

  Future updateLocalPayment(LocalPayment payment) async {
    final database = await _ref.read(databaseProvider).database;
    await database.update(
      LocalPayment.kTableName,
      payment.toJson(),
      where: 'id = ?',
      whereArgs: [payment.id],
    );
  }
}

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final editorSettingsProvider =
    StateNotifierProvider<EditorSettingsProvider, EditorSettings>(
        (_) => EditorSettingsProvider());

enum ChangesetReview { never, withTags, always }

class EditorSettings {
  static const kDefaultPayment = ['debit_cards', 'credit_cards'];

  final bool preferContact;
  final bool fixNumKeyboard;
  final bool leftHand;
  final List<String> defaultPayment;
  final ChangesetReview changesetReview;

  const EditorSettings({
    this.preferContact = false,
    this.fixNumKeyboard = true,
    this.leftHand = false,
    this.defaultPayment = kDefaultPayment,
    this.changesetReview = ChangesetReview.never,
  });

  EditorSettings copyWith({
    bool? preferContact,
    bool? fixNumKeyboard,
    bool? leftHand,
    List<String>? defaultPayment,
    ChangesetReview? changesetReview,
  }) {
    return EditorSettings(
      preferContact: preferContact ?? this.preferContact,
      fixNumKeyboard: fixNumKeyboard ?? this.fixNumKeyboard,
      leftHand: leftHand ?? this.leftHand,
      defaultPayment: defaultPayment ?? this.defaultPayment,
      changesetReview: changesetReview ?? this.changesetReview,
    );
  }

  factory EditorSettings.fromStrings(List<String>? data) {
    if (data == null || data.length < 3) return EditorSettings();
    return EditorSettings(
      preferContact: data[0] == '1',
      fixNumKeyboard: data[1] == '1',
      defaultPayment: data[2].length < 2
          ? kDefaultPayment
          : data[2].split(';').map((s) => s.trim()).toList(),
      leftHand: data.length >= 4 && data[3] == '1',
      changesetReview: data.length < 5 ? ChangesetReview.never : ChangesetReview.values[int.parse(data[4])],
    );
  }

  List<String> toStrings() {
    return [
      preferContact ? '1' : '0',
      fixNumKeyboard ? '1' : '0',
      defaultPayment.join(';'),
      leftHand ? '1' : '0',
      ChangesetReview.values.indexOf(changesetReview).toString(),
    ];
  }

  TextInputType get keyboardType => fixNumKeyboard
      ? TextInputType.visiblePassword
      : TextInputType.numberWithOptions(signed: true, decimal: true);
}

class EditorSettingsProvider extends StateNotifier<EditorSettings> {
  static const kSettingsKey = 'editor_settings';

  EditorSettingsProvider() : super(EditorSettings()) {
    load();
  }

  load() async {
    final prefs = await SharedPreferences.getInstance();
    state = EditorSettings.fromStrings(prefs.getStringList(kSettingsKey));
  }

  store() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(kSettingsKey, state.toStrings());
  }

  setPreferContact(bool value) {
    state = state.copyWith(preferContact: value);
    store();
  }

  setFixNumKeyboard(bool value) {
    state = state.copyWith(fixNumKeyboard: value);
    store();
  }

  setLeftHand(bool value) {
    state = state.copyWith(leftHand: value);
    store();
  }

  setDefaultPayment(List<String> values) {
    if (values.isNotEmpty) {
      state = state.copyWith(defaultPayment: values);
      store();
    }
  }

  setChangesetReview(ChangesetReview value) {
    state = state.copyWith(changesetReview: value);
    store();
  }
}

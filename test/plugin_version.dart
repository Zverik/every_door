import 'package:every_door/models/plugin.dart';
import 'package:test/test.dart';

void main() {
  test('Parses and prints version correctly', () {
    expect(PluginVersion('0').toString(), equals('0'));
    expect(PluginVersion('0.1').toString(), equals('0.1'));
    expect(PluginVersion('1.0').toString(), equals('1.0'));
    expect(PluginVersion('123123.12543').toString(), equals('123123.12543'));
  });

  test('Throws an exception on wrong sources', () {
    expect(() => PluginVersion(''), throwsFormatException);
    expect(() => PluginVersion('.'), throwsFormatException);
    expect(() => PluginVersion('.0'), throwsFormatException);
    expect(() => PluginVersion('1.'), throwsFormatException);
    expect(() => PluginVersion('huh'), throwsFormatException);
  });

  test('Operator ==', () {
    expect(PluginVersion('0'), equals(PluginVersion.zero));
    expect(PluginVersion('1'), equals(PluginVersion('1')));
    expect(PluginVersion('1'), isNot(PluginVersion('1.0')));
    expect(PluginVersion('1'), isNot(PluginVersion('0.1')));
    expect(PluginVersion('1.1'), equals(PluginVersion('1.1')));
  });

  test('Operator <', () {
    expect(PluginVersion('0') < PluginVersion('1'), isTrue);
    expect(PluginVersion('0') < PluginVersion('0'), isFalse);
    expect(PluginVersion('0') < PluginVersion('0.0'), isTrue);
    expect(PluginVersion('0.1') < PluginVersion('1.0'), isTrue);
    expect(PluginVersion('1.0') < PluginVersion('0.1'), isFalse);
    expect(PluginVersion('10') < PluginVersion('0.1'), isTrue);
    expect(PluginVersion('1.0') < PluginVersion('10'), isFalse);
  });

  test('Operator >', () {
    expect(PluginVersion('0') > PluginVersion('1'), isFalse);
    expect(PluginVersion('1') > PluginVersion('0'), isTrue);
    expect(PluginVersion('0') > PluginVersion('0'), isFalse);
    expect(PluginVersion('0') > PluginVersion('0.0'), isFalse);
    expect(PluginVersion('0.1') > PluginVersion('1.0'), isFalse);
    expect(PluginVersion('1.0') > PluginVersion('0.1'), isTrue);
    expect(PluginVersion('10') > PluginVersion('0.1'), isFalse);
    expect(PluginVersion('1.0') > PluginVersion('10'), isTrue);
  });
}

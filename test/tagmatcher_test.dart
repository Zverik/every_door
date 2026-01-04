import 'package:every_door/helpers/tags/tag_matcher.dart';
import 'package:every_door/models/amenity.dart';
import 'package:latlong2/latlong.dart';
import 'package:test/test.dart';

String tagsToString(Map<String, String> tags) {
  if (tags.isEmpty) return '<empty>';
  return tags.entries.map((kv) => '${kv.key}=${kv.value}').join(', ');
}

void vmatch(
    ValueMatcher vm, String value, Map<String, String> tags, dynamic matcher) {
  final reason =
      tags.isEmpty ? '"$value"' : '"$value", tags: ${tagsToString(tags)}';

  expect(vm.matches(value, tags), matcher, reason: '[tags] $reason');
  expect(
    vm.matchesChange(value,
        OsmChange.create(tags: tags, location: LatLng(0, 0), source: 'osm')),
    matcher,
    reason: '[change] $reason',
  );
}

void tmatch(
    TagMatcher tm, Map<String, String> tags, String? mainKey, dynamic matcher) {
  final reason = tagsToString(tags);
  expect(tm.matches(tags, mainKey), matcher, reason: '[tags] $reason');
  expect(
    tm.matchesChange(
        OsmChange.create(tags: tags, location: LatLng(0, 0), source: 'osm'),
        mainKey),
    matcher,
    reason: '[change] $reason',
  );
}

void main() {
  group('ValueMatcher', () {
    test('Empty matches anything', () {
      final v = ValueMatcher();
      vmatch(v, '', {}, isTrue);
      vmatch(v, 'whatever', {'other': 'nope'}, isTrue);
    });

    test('Only required tags', () {
      final v = ValueMatcher(only: {'first', 'second'});
      vmatch(v, '', {}, isFalse);
      vmatch(v, 'first', {}, isTrue);
      vmatch(v, 'second', {}, isTrue);
      vmatch(v, 'third', {}, isFalse);
    });

    test('Except tags', () {
      final v = ValueMatcher(except: {'first', 'second'});
      vmatch(v, '', {}, isTrue);
      vmatch(v, 'first', {}, isFalse);
      vmatch(v, 'second', {}, isFalse);
      vmatch(v, 'third', {}, isTrue);
    });

    test('Only + second', () {
      final v = ValueMatcher(only: {'first'}, except: {'second'});
      vmatch(v, '', {}, isFalse);
      vmatch(v, 'first', {}, isTrue);
      vmatch(v, 'second', {}, isFalse);
      vmatch(v, 'third', {}, isFalse);
    });

    test('When conditions', () {
      final v = ValueMatcher(when: {'first': TagMatcher.empty});
      vmatch(v, '', {}, isFalse);
      vmatch(v, 'first', {}, isTrue);
      vmatch(v, 'third', {}, isFalse);
    });

    test('Complex when condition', () {
      final v = ValueMatcher(when: {
        'first': TagMatcher({
          'second': ValueMatcher(only: {'yes'}),
        }),
      });
      vmatch(v, '', {}, isFalse);
      vmatch(v, 'first', {}, isFalse);
      vmatch(v, 'second', {}, isFalse);
      vmatch(v, 'second', {'first': 'some'}, isFalse);
      vmatch(v, 'first', {'first': 'some', 'second': 'other'}, isFalse);
      vmatch(v, 'first', {'first': 'some', 'second': 'yes'}, isTrue);
      vmatch(v, 'first', {'second': 'yes'}, isTrue);
    });

    test('When + only', () {
      final v = ValueMatcher(
        only: {'second'},
        when: {'first': TagMatcher.empty},
      );
      vmatch(v, '', {}, isFalse);
      vmatch(v, 'first', {}, isTrue);
      vmatch(v, 'second', {}, isTrue);
      vmatch(v, 'third', {}, isFalse);
    });

    test('When + except', () {
      final v = ValueMatcher(
        except: {'second'},
        when: {'first': TagMatcher.empty},
      );
      vmatch(v, '', {}, isTrue);
      vmatch(v, 'first', {}, isTrue);
      vmatch(v, 'second', {}, isFalse);
      vmatch(v, 'third', {}, isTrue);
    });

    test('Except has priority on when', () {
      final v = ValueMatcher(
        except: {'first'},
        when: {'first': TagMatcher.empty},
      );
      // Should be no way of getting "true".
      vmatch(v, '', {}, isTrue);
      vmatch(v, 'first', {}, isFalse);
      vmatch(v, 'third', {}, isTrue);
    });

    test('Replacing matcher', () {
      final v = ValueMatcher(
        only: {'second'},
        when: {'first': TagMatcher.empty},
      );
      final v2 = ValueMatcher(
        except: {'second'},
        when: {'third': TagMatcher.empty},
      );
      final m = v.mergeWith(v2);
      expect(m.only, isEmpty);
      expect(m.except, equals({'second'}));
      expect(m.when, isNot(contains('first')));
      expect(m.when, contains('third'));
    });

    test('Merging in a matcher', () {
      final v = ValueMatcher(
        only: {'second'},
        when: {'first': TagMatcher.empty},
      );
      final v2 = ValueMatcher(
        except: {'second'},
        when: {'third': TagMatcher.empty},
        replace: false,
      );
      final m = v.mergeWith(v2);
      expect(m.only, isEmpty);
      expect(m.except, equals({'second'}));
      expect(m.when, contains('first'));
      expect(m.when, contains('third'));
    });
  });

  group('TagMatcher', () {
    test('Empty returns true always', () {
      expect(TagMatcher.empty.isEmpty, isTrue);
      expect(TagMatcher({}).isEmpty, isTrue);
      tmatch(TagMatcher.empty, {}, null, isTrue);
      tmatch(TagMatcher.empty, {'shop': 'toy', 'open': 'no'}, null, isTrue);
    });

    test('Good is checked', () {
      final t = TagMatcher({}, good: {'first'});
      tmatch(t, {'first': 'other'}, null, isFalse);
      tmatch(t, {'first': 'other'}, 'first', isTrue);
      tmatch(t, {'first': 'other', 'other': 'what'}, 'other', isFalse);
    });

    test('Good is checked w/o rules', () {
      final t = TagMatcher({'other': ValueMatcher()}, good: {'first'});
      tmatch(t, {}, null, isFalse);
      tmatch(t, {'first': 'other'}, null, isFalse);
      tmatch(t, {'first': 'other'}, 'first', isTrue);
    });

    test('Good has priority over everything', () {
      final t = TagMatcher({
        'first': ValueMatcher(except: {'value'})
      }, good: {
        'first',
        'second',
      });
      tmatch(t, {'first': 'other'}, null, isTrue);
      tmatch(t, {'first': 'value'}, null, isFalse);
      tmatch(t, {'first': 'value'}, 'first', isTrue);
      tmatch(t, {'first': 'value', 'second': 'what'}, 'second', isTrue);
    });

    test('Good accounts for prefixes', () {
      final t = TagMatcher({'other': ValueMatcher()}, good: {'first'});
      tmatch(t, {}, null, isFalse);
      tmatch(t, {'was:first': 'other'}, null, isFalse);
      tmatch(t, {'was:first': 'other'}, 'was:first', isTrue);
    });

    test('Missing', () {
      final t = TagMatcher({}, missing: {'one', 'two'});
      tmatch(t, {}, null, isTrue);
      tmatch(t, {'one': 'two'}, null, isTrue);
      tmatch(t, {'one': 'one', 'two': 'two'}, null, isFalse);
    });

    test('Returns true if any of the rules match', () {
      final t = TagMatcher({
        'first': ValueMatcher(only: {'value'}),
        'second': ValueMatcher(only: {'value2'}),
      });
      tmatch(t, {}, null, isFalse);
      tmatch(t, {'first': 'nope'}, null, isFalse);
      tmatch(t, {'first': 'value'}, null, isTrue);
      tmatch(t, {'second': 'value2'}, null, isTrue);
      tmatch(t, {'first': 'value', 'second': 'value2'}, null, isTrue);
    });

    test('Uses a single rule when onlyKey is supplied', () {
      final t = TagMatcher({
        'first': ValueMatcher(only: {'value'}),
        'second': ValueMatcher(only: {'value2'}),
      });
      tmatch(t, {'first': 'value', 'second': 'value2'}, null, isTrue);
      tmatch(t, {'first': 'value', 'second': 'value2'}, 'first', isTrue);
      tmatch(t, {'first': 'nope', 'second': 'value2'}, null, isTrue);
      tmatch(t, {'first': 'nope', 'second': 'value2'}, 'first', isFalse);
      tmatch(t, {'first': 'nope', 'second': 'value2'}, 'second', isTrue);
      tmatch(
          t, {'was:first': 'value', 'second': 'value2'}, 'was:first', isTrue);
    });
  });
}

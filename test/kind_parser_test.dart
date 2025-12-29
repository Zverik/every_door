import 'package:collection/collection.dart';
import 'package:every_door/helpers/tags/element_kind.dart';
import 'package:every_door/helpers/tags/tag_matcher.dart';
import 'package:test/test.dart';

void main() {
  test('Empty matcher', () {
    expect(
        ElementKindImpl.fromList('test', []),
        equals(ElementKindImpl(
          name: 'test',
          matcher: TagMatcher.empty,
          onMainKey: true,
          replace: true,
        )));

    expect(
        ElementKindImpl.fromList('test', [
          {'update': []}
        ]),
        equals(ElementKindImpl(
          name: 'test',
          matcher: TagMatcher.empty,
          onMainKey: true,
          replace: false,
        )));

    expect(
        ElementKindImpl.fromList('test', ['on all keys']),
        equals(ElementKindImpl(
          name: 'test',
          matcher: TagMatcher.empty,
          onMainKey: false,
          replace: true,
        )));
  });

  test('Flat lists', () {
    expect(
        ElementKindImpl.fromList('test', ['amenity=school', 'amenity=other']),
        equals(ElementKindImpl(
          name: 'test',
          matcher: TagMatcher({
            'amenity': ValueMatcher(only: {'school', 'other'}, replace: true),
          }),
          replace: true,
        )));

    expect(
        ElementKindImpl.fromList('test', ['amenity=*', 'no office=other']),
        equals(ElementKindImpl(
          name: 'test',
          matcher: TagMatcher(good: {
            'amenity'
          }, {
            'office': ValueMatcher(except: {'other'}, replace: true),
          }),
          replace: true,
        )));

    expect(
        ElementKindImpl.fromList(
            'test', ['amenity=*', 'office=other', 'on all keys']),
        equals(ElementKindImpl(
          name: 'test',
          matcher: TagMatcher(good: {
            'amenity'
          }, {
            'office': ValueMatcher(only: {'other'}, replace: true),
          }),
          replace: true,
          onMainKey: false,
        )));
  });

  test('Equality test', () {
    final v1 = ValueMatcher(only: {'school', 'other'});
    final v2 = ValueMatcher(only: {'school', 'other'});
    expect(v1, equals(v2));

    final tg1 = TagMatcher({}, good: {'office'});
    final tg2 = TagMatcher({}, good: {'office'});
    expect(tg1, equals(tg2));

    expect(DefaultEquality().equals(v1, v2), isTrue, reason: "DefaultEquality");
    expect(MapEquality().equals({'amenity': v1}, {'amenity': v2}), isTrue,
        reason: "MapEquality");

    final t1 = TagMatcher({'amenity': v1}, good: {'office'});
    final t2 = TagMatcher({'amenity': v2}, good: {'office'});
    expect(t1, equals(t2));

    final t3 = TagMatcher({
      'amenity': ValueMatcher(when: {
        'post_office': TagMatcher({
          'open': ValueMatcher(only: {'yes'})
        })
      })
    });
    final t4 = TagMatcher({
      'amenity': ValueMatcher(when: {
        'post_office': TagMatcher({
          'open': ValueMatcher(only: {'yes'})
        })
      })
    });
    expect(t3, equals(t4));
  });

  test('Sublists and conditions', () {
    expect(
        ElementKindImpl.fromList('test', [
          {
            'amenity except': ['parking', 'grass']
          },
          {'office only': 'it'}
        ]),
        equals(ElementKindImpl(
          name: 'test',
          matcher: TagMatcher({
            'amenity':
                ValueMatcher(except: {'parking', 'grass'}, replace: true),
            'office': ValueMatcher(only: {'it'}, replace: true),
          }),
          replace: true,
        )));

    expect(
        ElementKindImpl.fromList('test', [
          'amenity=*',
          'amenity=school',
          {
            'amenity=post': ['post=office', 'poi=*']
          }
        ]),
        equals(ElementKindImpl(
          name: 'test',
          matcher: TagMatcher(good: {
            'amenity'
          }, {
            'amenity': ValueMatcher(
              only: {'school'},
              when: {
                'post': TagMatcher(good: {
                  'poi'
                }, {
                  'post': ValueMatcher(only: {'office'})
                })
              },
              replace: true,
            ),
          }),
          replace: true,
        )));
  });

  test('Updates', () {
    expect(
        ElementKindImpl.fromList('test', [
          {
            'update': ['amenity=parking', 'poi=*']
          },
          'office=it'
        ]),
        equals(ElementKindImpl(
          name: 'test',
          matcher: TagMatcher(
            good: {'poi'},
            {
              'amenity': ValueMatcher(only: {'parking'}, replace: false),
              'office': ValueMatcher(only: {'it'}, replace: true),
            },
            replace: false,
          ),
          replace: false,
        )));
  });
}

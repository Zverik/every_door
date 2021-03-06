import 'package:every_door/helpers/good_tags.dart';

const kTagEmoji = <String, String>{
  'amenity=post_office': 'đ¯',
  'amenity=post_box': 'âī¸',
  'amenity=school': 'đ',
  'amenity=kindergarten': 'đ§¸',
  'amenity=university': 'đ',
  'amenity=pharmacy': 'đ',
  'amenity=cafe': 'â',
  'amenity=restaurant': 'đ´',
  'amenity=bar': 'đģ',
  'amenity=biergarten': 'đģ',
  'amenity=fast_food': 'đ',
  'amenity=casino': 'đ°',
  'amenity=bank': 'đĻ',
  'amenity=atm': 'đ§',
  'amenity=bench': 'đĒ',
  'amenity=place_of_worship': 'âĒ',
  'amenity=fuel': 'âŊ',
  'amenity=toilets': 'đģ',
  'amenity=waste_basket': 'đī¸',
  'amenity=waste_disposal': 'âģī¸',
  'amenity=recycling': 'âģī¸',
  'amenity=hospital': 'đĨ',
  'amenity=doctors': 'đŠē',
  'amenity=clinic': 'đŠē',
  'amenity=dentist': 'đĻˇ',
  'amenity=bus_station': 'đ',
  'amenity=police': 'đ',
  'amenity=bureau_de_change': 'đą',

  'shop=convenience': 'đ',
  'shop=supermarket': 'đ',
  'shop=gift': 'đ',
  'shop=toys': 'đ§¸',
  'shop=pet': 'đ',
  'shop=kiosk': 'đĒ',
  'shop=florist': 'đ',
  'shop=computer': 'đĨī¸',
  'shop=hairdresser': 'đ',
  'shop=beauty': 'đ',
  'shop=electronics': 'đˇ',
  'shop=alcohol': 'đˇ',
  'shop=clothes': 'đ',
  'shop=shoes': 'đ',
  'shop=car_repair': 'đ',
  'shop=car_parts': 'đ',
  'shop=bakery': 'đĨ¨',
  'shop=pastry': 'đ°',
  'shop=butcher': 'đĨŠ',
  'shop=furniture': 'đī¸',
  'shop=mobile_phone': 'đą',
  'shop=tobacco': 'đŦ',
  'shop=jewelry': 'đ',
  'shop=fashion_accessories': 'đŋ',
  'shop=cosmetics': 'đ',
  'shop=sports': 'âŊ',
  'shop=optician': 'đ',
  'shop=mall': 'đī¸',
  'shop=ice_cream': 'đ¨',

  'craft=electronics_repair': 'đ',

  'tourism=information': 'âšī¸',
  'tourism=hotel': 'đ¨',
  'tourism=motel': 'đī¸',
  'tourism=hostel': 'đī¸',
  'tourism=guest_house': 'đĄ',
  'tourism=attraction': 'đ¸',
  'tourism=museum': 'đī¸',
  'tourism=gallery': 'đŧī¸',

  'leisure=playground': 'đĒ',
};

String? getEmojiForTags(Map<String, String> tags) {
  final List<String> emoji = [];
  final mainKey = getMainKey(tags);
  if (mainKey != null) {
    final kv = kTagEmoji['$mainKey=${tags[mainKey]}'];
    if (kv != null && kv.isNotEmpty)
      emoji.add(kv);
  }
  tags.forEach((key, value) {
    var kv = kTagEmoji['$key=$value'];
    if (kv != null && kv.isNotEmpty) {
      if (!emoji.contains(kv)) emoji.add(kv);
    }
  });
  return emoji.isEmpty ? null : emoji.join();
}
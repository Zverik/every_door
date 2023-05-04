import 'package:every_door/helpers/good_tags.dart';

const kTagEmoji = <String, String>{
  'amenity=post_office': '📯',
  'amenity=post_box': '✉️',
  'amenity=school': '📚',
  'amenity=kindergarten': '🧸',
  'amenity=university': '🎓',
  'amenity=pharmacy': '💊',
  'amenity=cafe': '☕',
  'amenity=restaurant': '🍴',
  'amenity=bar': '🍻',
  'amenity=biergarten': '🍻',
  'amenity=fast_food': '🍔',
  'amenity=casino': '🎰',
  'amenity=bank': '🏦',
  'amenity=atm': '🏧',
  'amenity=bench': '🪑',
  'amenity=place_of_worship': '⛪',
  'amenity=fuel': '⛽',
  'amenity=toilets': '🚻',
  'amenity=waste_basket': '🗑️',
  'amenity=waste_disposal': '♻️',
  'amenity=recycling': '♻️',
  'amenity=hospital': '🏥',
  'amenity=doctors': '🩺',
  'amenity=clinic': '🩺',
  'amenity=dentist': '🦷',
  'amenity=bus_station': '🚏',
  'amenity=police': '🚓',
  'amenity=ice_cream': '🍨',
  'amenity=toilets': '🚻',
  'amenity=gambling': '🎰',
  'amenity=cinema': '🍿',
  'amenity=bicycle_rental': '🚲',
  'amenity=bureau_de_change': '💱',

  'shop=convenience': '🛒',
  'shop=supermarket': '🛒',
  'shop=gift': '🎁',
  'shop=toys': '🧸',
  'shop=pet': '🐈',
  'shop=kiosk': '🏪',
  'shop=florist': '💐',
  'shop=computer': '🖥️',
  'shop=hairdresser': '💈',
  'shop=beauty': '💅',
  'shop=electronics': '📷',
  'shop=alcohol': '🍷',
  'shop=clothes': '👚',
  'shop=shoes': '👞',
  'shop=car_repair': '🚗',
  'shop=car_parts': '🚗',
  'shop=bakery': '🥨',
  'shop=pastry': '🍰',
  'shop=butcher': '🥩',
  'shop=furniture': '🛋️',
  'shop=mobile_phone': '📱',
  'shop=tobacco': '🚬',
  'shop=jewelry': '💎',
  'shop=fashion_accessories': '📿',
  'shop=cosmetics': '💄',
  'shop=sports': '⚽',
  'shop=optician': '👓',
  'shop=mall': '🛍️',
  'shop=ice_cream': '🍨',
  'shop=books': '📚',
  'shop=stationery': '✏️',
  'shop=coffee': '☕️',
  'shop=wine': '🍷',
  'shop=greengrocer': '🥦',
  'shop=vacant': '🚫',
  'shop=bicycle': '🚲',
  
  'craft=electronics_repair': '🔌',
  'craft=watchmaker': '⌚️',

  'tourism=information': 'ℹ️',
  'tourism=hotel': '🏨',
  'tourism=motel': '🛏️',
  'tourism=hostel': '🛏️',
  'tourism=guest_house': '🏡',
  'tourism=attraction': '📸',
  'tourism=museum': '🏛️',
  'tourism=gallery': '🖼️',

  'leisure=playground': '🪜',
  'leisure=adult_gaming_centre': '🎰',
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

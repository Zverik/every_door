// Copyright 2022-2025 Ilya Zverev
// This file is a part of Every Door, distributed under GPL v3 or later version.
// Refer to LICENSE file and https://www.gnu.org/licenses/gpl-3.0.html for details.
class LanguageItem implements Comparable {
  final String isoCode;
  final String nameEn;
  final String nameLoc;
  final String key;
  final int keyCount;

  LanguageItem({
    required this.isoCode,
    required this.nameEn,
    required this.nameLoc,
    required this.keyCount,
  }) : key = 'name:$isoCode';

  factory LanguageItem.fromRow(String row) {
    final data = row.split('|');
    return LanguageItem(
      isoCode: data[0],
      nameEn: data[1],
      nameLoc: data[2],
      keyCount: int.parse(data[3]),
    );
  }

  @override
  int compareTo(other) {
    if (other is! LanguageItem) throw ArgumentError('Expected a LanguageItem');
    return other.keyCount.compareTo(keyCount);
  }
}

class LanguageData {
  static final _data = <String, LanguageItem>{};
  static final _codes = <String>[];
  static final _countries = <String, List<LanguageItem>>{};

  LanguageData() {
    if (_data.isEmpty) {
      final List<LanguageItem> items = _kLanguageData
          .split('\n')
          .map((row) => LanguageItem.fromRow(row))
          .toList();
      items.sort();
      _codes.addAll(items.map((i) => i.isoCode));
      _data.addAll({for (final i in items) i.isoCode: i});

      _countries.addAll({
        for (final entry in _kCountryData.entries)
          entry.key: entry.value.map((e) => _data[e]!).toList()
      });
    }
  }

  List<String> get codes => _codes;
  Iterable<LanguageItem> get languages => _codes.map((c) => _data[c]!);
  LanguageItem dataForCode(String code) => _data[code]!;
  LanguageItem? dataForKey(String key) =>
      _data[key.substring(key.indexOf(':') + 1)];
  List<LanguageItem> dataForCountry(String code) =>
      _countries[code] ?? const [];
}

/// Map of country_coder_id => list of ISO 639-1 language codes.
const _kCountryData = {
  "AD": ["ca"],
  "AE": ["ar"],
  "AF": ["ps"],
  "AG": ["en"],
  "AI": ["en"],
  "AL": ["sq"],
  "AM": ["hy"],
  "AO": ["pt"],
  "AR": ["es"],
  "AT": ["de"],
  "AU": ["en"],
  "AZ": ["az"],
  "BA": ["bs", "sr", "sr-Latn", "hr"],
  "BB": ["en"],
  "BD": ["bn"],
  "BE": ["fr", "de", "nl"],
  "BF": ["fr"],
  "BG": ["bg"],
  "BH": ["ar"],
  "BI": ["fr", "rn"],
  "BJ": ["fr"],
  "BM": ["en"],
  "BN": ["ms"],
  "BO": ["es", "ay", "qu", "gn"],
  "BR": ["pt"],
  "BS": ["en"],
  "BT": ["dz"],
  "BW": ["en", "tn"],
  "BY": ["be", "ru"],
  "BZ": ["en"],
  "CA": ["fr", "en"],
  "CF": ["fr", "sg"],
  "CH": ["fr", "de", "it", "rm"],
  "CK": ["en"],
  "CL": ["es"],
  "CM": ["fr", "en"],
  "CN": ["zh"],
  "CO": ["es"],
  "CR": ["es"],
  "CU": ["es"],
  "CV": ["pt"],
  "DE": ["de"],
  "DJ": ["fr", "ar"],
  "DM": ["en"],
  "DO": ["es"],
  "DZ": ["ar"],
  "EC": ["es"],
  "EE": ["et"],
  "EG": ["ar"],
  "ER": ["en", "ar", "ti"],
  "ES": ["es"],
  "ET": ["am"],
  "FI": ["fi", "sv"],
  "FJ": ["en", "fj"],
  "FO": ["da", "fo"],
  "FR": ["fr"],
  "GA": ["fr"],
  "GB": ["en"],
  "GD": ["en"],
  "GE": ["ka"],
  "GH": ["en"],
  "GI": ["en"],
  "GL": ["kl"],
  "GM": ["en"],
  "GN": ["fr"],
  "GR": ["el"],
  "GS": ["en"],
  "GT": ["es"],
  "GW": ["pt"],
  "GY": ["en"],
  "HK": ["zh", "en"],
  "HN": ["es"],
  "HR": ["hr"],
  "HT": ["fr", "ht"],
  "HU": ["hu"],
  "ID": ["id"],
  "IL": ["he"],
  "IM": ["en", "gv"],
  // "IN": ["hi", "mr", "en", "gu", "ta", "te", "bn", "as", "ml", "pa"],
  "IN": ["hi", "mr", "en"],
  "IQ": ["ar", "ku"],
  "IR": ["fa"],
  "IS": ["is"],
  "IT": ["it"],
  "JM": ["en"],
  "JO": ["ar"],
  "JP": ["ja"],
  "KE": ["en", "sw"],
  "KG": ["ru", "ky"],
  "KH": ["km"],
  "KI": ["en"],
  "KM": ["fr", "ar"],
  "KP": ["ko"],
  "KR": ["ko"],
  "KW": ["ar"],
  "KY": ["en"],
  "KZ": ["kk", "ru"],
  "LA": ["lo"],
  "LB": ["ar"],
  "LI": ["de"],
  "LK": ["ta", "si"],
  "LR": ["en"],
  "LT": ["lt"],
  "LU": ["lb", "fr", "de"],
  "LV": ["lv"],
  "LY": ["ar"],
  "MA": ["ar"],
  "MC": ["fr"],
  "MD": ["ro"],
  "MH": ["en", "mh"],
  "ML": ["fr"],
  "MM": ["my"],
  "MN": ["mn"],
  "MO": ["zh", "pt"],
  "MS": ["en"],
  "MT": ["en", "mt"],
  "MV": ["dv"],
  "MW": ["en", "ny"],
  "MX": ["es"],
  "MY": ["en"],
  "MZ": ["pt"],
  "NA": ["en"],
  "NE": ["fr"],
  "NG": ["en"],
  "NI": ["es"],
  "NO": ["no"],
  "NP": ["ne"],
  "NR": ["na"],
  "NU": ["en"],
  "NZ": ["en", "mi"],
  "OM": ["ar"],
  "PA": ["es"],
  "PE": ["es"],
  "PF": ["fr"],
  "PG": ["en", "ho"],
  "PH": ["en", "tl"],
  "PK": ["ur", "en"],
  "PL": ["pl"],
  "PS": ["ar"],
  "PT": ["pt"],
  "PW": ["en"],
  "PY": ["es", "gn"],
  "Q22890": ["en", "ga"],
  "Q3311985": ["fr", "en"],
  "Q35": ["da"],
  "Q55": ["nl"],
  "Q644636": ["el", "tr"],
  "Q7835": ["ru"],
  "QA": ["ar"],
  "RO": ["ro"],
  "RS": ["sr", "sr-Latn"],
  "RU": ["ru"],
  "RW": ["fr", "en", "rw"],
  "SA": ["ar"],
  "SB": ["en"],
  "SC": ["fr", "en"],
  "SD": ["en", "ar"],
  "SE": ["fi", "yi", "sv"],
  "SG": ["en", "zh", "ta", "ms"],
  "SI": ["sl"],
  "SK": ["sk"],
  "SL": ["en"],
  "SM": ["it"],
  "SN": ["fr"],
  "SO": ["so", "ar"],
  "SR": ["nl"],
  "SS": ["en"],
  "SV": ["es"],
  "SY": ["ar"],
  "SZ": ["en", "ss"],
  "TD": ["fr", "ar"],
  "TG": ["fr"],
  "TH": ["th"],
  "TJ": ["ru", "tg"],
  "TK": ["en", "mi"],
  "TL": ["pt"],
  "TM": ["tk"],
  "TN": ["ar"],
  "TO": ["en", "to"],
  "TR": ["tr"],
  "TT": ["en"],
  "TV": ["en"],
  "TW": ["zh"],
  "TZ": ["en", "sw"],
  "UA": ["uk"],
  "UG": ["en", "sw"],
  "US": ["en"],
  "UY": ["es"],
  "UZ": ["uz", "ru"],
  "VE": ["es"],
  "VI": ["en"],
  "VN": ["vi"],
  "VU": ["fr", "en", "bi"],
  "WF": ["fr"],
  "WS": ["en", "sm"],
  "YE": ["ar"],
  // "ZA": ["en", "zu", "xh", "af", "ve", "ss", "tn", "ts", "st", "nr"],
  "ZA": ["en", "af", "zu"],
  "ZM": ["en"],
  "ZW": ["en", "sn", "nd"],
};

const _kLanguageData =
    'aar|Afaraf|aa|0\nab|Abkhazian|аҧсуа бызшәа|1655\nae|Avestan|avesta|6\naf|Afrikaans|Afrikaans|20158\nak|Akan|Akan|324\nam|Amharic|አማርኛ|9288\nan|Aragonese|aragonés|4078\nar|Arabic|العربية|1095698\nas|Assamese|অসমীয়া|5420\nav|Avaric|авар мацӀ|413\nay|Aymara|aymar aru|527\naz|Azerbaijani|azərbaycan dili|20246\nba|Bashkir|башҡорт теле|8562\nbe|Belarusian|беларуская мова|441571\nbg|Bulgarian|български език|39927\nbi|Bislama|Bislama|225\nbm|Bambara|bamanankan|644\nbn|Bengali|বাংলা|21609\nbo|Tibetan|བོད་ཡིག|7660\nbr|Breton|brezhoneg|277725\nbs|Bosnian|bosanski jezik|7370\nca|Catalan|català|710183\nce|Chechen|нохчийн мотт|7243\nch|Chamorro|Chamoru|118\nco|Corsican|corsu|2763\ncr|Cree|ᓀᐦᐃᔭᐍᐏᐣ|1830\ncs|Czech|čeština|59218\ncu|Church Slavic|ѩзыкъ словѣньскъ|551\ncv|Chuvash|чӑваш чӗлхи|10682\ncy|Welsh|Cymraeg|38670\nda|Danish|dansk|13489\nde|German|Deutsch|528721\ndv|Divehi|ދިވެހި|1339\ndz|Dzongkha|རྫོང་ཁ|701\nee|Ewe|Eʋegbe|1193\nel|Greek|Ελληνικά|174277\nen|English|English|6789171\neo|Esperanto|Esperanto|14231\nes|Spanish|Español|370315\net|Estonian|eesti|15106\neu|Basque|euskara|80609\nfa|Persian|فارسی|73663\nff|Fulah|Fulfulde|382\nfi|Finnish|suomi|451236\nfj|Fijian|vosa Vakaviti|103\nfo|Faroese|føroyskt|1569\nfr|French|français|635410\nfy|Western Frisian|Frysk|9091\nga|Irish|Gaeilge|118996\ngd|Gaelic|Gàidhlig|15052\ngl|Galician|Galego|22597\ngn|Guarani|Avañe\'ẽ|1796\ngu|Gujarati|ગુજરાતી|5153\ngv|Manx|Gaelg|2643\nha|Hausa|(Hausa) هَوُسَ|684\nhe|Hebrew|עברית|191315\nhi|Hindi|हिन्दी|71291\nho|Hiri Motu|Hiri Motu|2\nhr|Croatian|hrvatski jezik|23123\nht|Haitian|Kreyòl ayisyen|1587\nhu|Hungarian|magyar|75581\nhy|Armenian|Հայերեն|47734\nhz|Herero|Otjiherero|0\nia|Interlingua|Interlingua|1261\nid|Indonesian|Bahasa Indonesia|14248\nie|Interlingue|Interlingue|699\nig|Igbo|Asụsụ Igbo|397\nii|Sichuan Yi|ꆈꌠ꒿ Nuosuhxop|451\nik|Inupiaq|Iñupiaq|171\nio|Ido|Ido|1416\nis|Icelandic|Íslenska|3763\nit|Italian|Italiano|142083\niu|Inuktitut|ᐃᓄᒃᑎᑐᑦ|2659\nja|Japanese|日本語|1227863\njv|Javanese|ꦧꦱꦗꦮ|1487\nka|Georgian|ქართული|76663\nkg|Kongo|Kikongo|470\nki|Kikuyu|Gĩkũyũ|944\nkj|Kuanyama|Kuanyama|0\nkk|Kazakh|қазақ тілі|48370\nkl|Kalaallisut|kalaallisut|638\nkm|Central Khmer|ខ្មែរ|9838\nkn|Kannada|ಕನ್ನಡ|94730\nko|Korean|한국어|810354\nkr|Kanuri|Kanuri|106\nks|Kashmiri|कॉशुर|12143\nku|Kurdish|Kurdî|32027\nkv|Komi|коми кыв|926\nkw|Cornish|Kernewek|4573\nky|Kirghiz|Кыргызча|7467\nla|Latin|latine|11405\nlb|Luxembourgish|Lëtzebuergesch|8926\nlg|Ganda|Luganda|381\nli|Limburgan|Limburgs|1894\nln|Lingala|Lingála|632\nlo|Lao|ພາສາລາວ|4156\nlt|Lithuanian|lietuvių kalba|61334\nlu|Luba-Katanga|Kiluba|0\nlv|Latvian|latviešu valoda|20006\nmg|Malagasy|fiteny malagasy|2160\nmh|Marshallese|Kajin M̧ajeļ|86\nmi|Maori|te reo Māori|43734\nmk|Macedonian|македонски јазик|33289\nml|Malayalam|മലയാളം|43668\nmn|Mongolian|Монгол хэл|12185\nmr|Marathi|मराठी|20887\nms|Malay|Bahasa Melayu|89104\nmt|Maltese|Malti|4944\nmy|Burmese|ဗမာစာ|78518\nna|Nauru|Dorerin Naoero|573\nnb|Norwegian Bokmål|Norsk Bokmål|1406\nnd|North Ndebele|isiNdebele|15\nne|Nepali|नेपाली|20920\nng|Ndonga|Owambo|0\nnl|Dutch|Nederlands|88215\nnn|Norwegian Nynorsk|Norsk Nynorsk|5931\nno|Norwegian|Norsk|17545\nnr|South Ndebele|isiNdebele|0\nnv|Navajo|Diné bizaad|764\nny|Chichewa|chiCheŵa|664\noc|Occitan|occitan|109476\noj|Ojibwa|ᐊᓂᔑᓈᐯᒧᐎᓐ|3531\nom|Oromo|Afaan Oromoo|206\nor|Oriya|ଓଡ଼ିଆ|1952\nos|Ossetian|ирон ӕвзаг|7259\npa|Punjabi|ਪੰਜਾਬੀ|32032\npi|Pali|पालि|121\npl|Polish|język polski|397147\nps|Pashto|پښتو|15691\npt|Portuguese|Português|61750\nqu|Quechua|Runa Simi|1814\nrm|Romansh|Rumantsch Grischun|1377\nrn|Rundi|Ikirundi|340\nro|Romanian|Română|60558\nru|Russian|русский|1802852\nrw|Kinyarwanda|Ikinyarwanda|814\nsa|Sanskrit|संस्कृतम्|967\nsc|Sardinian|sardu|2030\nsd|Sindhi|सिंधी|9275\nse|Northern Sami|Davvisámegiella|17425\nsg|Sango|yângâ tî sängö|400\nsi|Sinhala|සිංහල|2512\nsk|Slovak|slovenčina|26192\nsl|Slovenian|Slovenski jezik|13345\nsm|Samoan|gagana fa\'a Samoa|269\nsn|Shona|chiShona|519\nso|Somali|Soomaaliga|1789\nsq|Albanian|Shqip|14184\nsr|Serbian (Cyrillic)|српски језик|360775\nsr-Latn|Serbian (Latin)|srpski jezik|273821\nss|Swati|SiSwati|333\nst|Southern Sotho|Sesotho|212\nsu|Sundanese|Basa Sunda|1339\nsv|Swedish|Svenska|173608\nsw|Swahili|Kiswahili|29333\nta|Tamil|தமிழ்|35283\nte|Telugu|తెలుగు|28914\ntg|Tajik|тоҷикӣ|9541\nth|Thai|ไทย|136999\nti|Tigrinya|ትግርኛ|1263\ntk|Turkmen|Türkmençe|10442\ntl|Tagalog|Wikang Tagalog|9901\ntn|Tswana|Setswana|135\nto|Tonga|Faka Tonga|351\ntr|Turkish|Türkçe|43097\nts|Tsonga|Xitsonga|172\ntt|Tatar|татар теле|32051\ntw|Twi|Twi|222\nty|Tahitian|Reo Tahiti|212\nug|Uighur|ئۇيغۇرچە|18102\nuk|Ukrainian|Українська|1188763\nur|Urdu|اردو|92617\nuz|Uzbek|Oʻzbek|15814\nve|Venda|Tshivenḓa|57\nvi|Vietnamese|Tiếng Việt|34488\nvo|Volapük|Volapük|1123\nwa|Walloon|Walon|2277\nwo|Wolof|Wollof|577\nxh|Xhosa|isiXhosa|172\nyi|Yiddish|ייִדיש|3196\nyo|Yoruba|Yorùbá|921\nza|Zhuang|Saɯ cueŋƅ|588\nzh|Chinese|中文 (Zhōngwén)|1720899\nzu|Zulu|isiZulu|1316';

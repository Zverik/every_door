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
  "BA": ["sr"],
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
  "BY": ["ru"],
  "BZ": ["en"],
  "CA": ["fr", "en"],
  "CF": ["fr", "sg"],
  "CH": ["fr", "de", "it", "rm"],
  "CK": ["en"],
  "CL": ["es"],
  "CM": ["fr", "en"],
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
  "KZ": ["kk"],
  "LA": ["lo"],
  "LB": ["ar"],
  "LI": ["de"],
  "LK": ["ta", "si"],
  "LR": ["en"],
  "LT": ["lt"],
  "LU": ["fr", "de", "en"],
  "LV": ["lv"],
  "LY": ["ar"],
  "MA": ["ar"],
  "MC": ["fr"],
  "MD": ["ro"],
  "MH": ["en", "mh"],
  "ML": ["fr"],
  "MM": ["my"],
  "MN": ["mn"],
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
  "OM": ["ar"],
  "PA": ["es"],
  "PE": ["es"],
  "PF": ["fr"],
  "PG": ["en", "ho"],
  "PH": ["en"],
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
  "Q644636": ["tr"],
  "Q7835": ["ru"],
  "QA": ["ar"],
  "RO": ["ro"],
  "RS": ["sr"],
  "RU": ["ru"],
  "RW": ["fr", "en", "rw"],
  "SA": ["ar"],
  "SB": ["en"],
  "SC": ["fr", "en"],
  "SD": ["en", "ar"],
  "SE": ["fi", "yi", "sv"],
  "SG": ["en", "ta", "ms"],
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
  "ZA": ["en", "zu"],
  "ZM": ["en"],
  "ZW": ["en", "sn", "nd"],
};

const _kLanguageData =
    'aar|Afaraf|aa|0\nab|Abkhazian|аҧсуа бызшәа|1\nae|Avestan|avesta|1\naf|Afrikaans|Afrikaans|1\nak|Akan|Akan|1\nam|Amharic|አማርኛ|1\nan|Aragonese|aragonés|1\nar|Arabic|العربية|1\nas|Assamese|অসমীয়া|1\nav|Avaric|авар мацӀ|1\nay|Aymara|aymar aru|1\naz|Azerbaijani|azərbaycan dili|1\nba|Bashkir|башҡорт теле|1\nbe|Belarusian|беларуская мова|1\nbg|Bulgarian|български език|1\nbi|Bislama|Bislama|1\nbm|Bambara|bamanankan|1\nbn|Bengali|বাংলা|1\nbo|Tibetan|བོད་ཡིག|1\nbr|Breton|brezhoneg|1\nbs|Bosnian|bosanski jezik|1\nca|Catalan, Valencian|català|1\nce|Chechen|нохчийн мотт|1\nch|Chamorro|Chamoru|1\nco|Corsican|corsu|1\ncr|Cree|ᓀᐦᐃᔭᐍᐏᐣ|1\ncs|Czech|čeština|1\ncu|Church Slavic, Old Slavonic, Church Slavonic, Old Bulgarian, Old Church Slavonic|ѩзыкъ словѣньскъ|1\ncv|Chuvash|чӑваш чӗлхи|1\ncy|Welsh|Cymraeg|1\nda|Danish|dansk|1\nde|German|Deutsch|1\ndv|Divehi, Dhivehi, Maldivian|ދިވެހި|1\ndz|Dzongkha|རྫོང་ཁ|1\nee|Ewe|Eʋegbe|1\nel|Greek, Modern (1453–)|Ελληνικά|1\nen|English|English|1\neo|Esperanto|Esperanto|1\nes|Spanish, Castilian|Español|1\net|Estonian|eesti|1\neu|Basque|euskara|1\nfa|Persian|فارسی|1\nff|Fulah|Fulfulde|1\nfi|Finnish|suomi|1\nfj|Fijian|vosa Vakaviti|1\nfo|Faroese|føroyskt|1\nfr|French|français|1\nfy|Western Frisian|Frysk|1\nga|Irish|Gaeilge|1\ngd|Gaelic, Scottish Gaelic|Gàidhlig|1\ngl|Galician|Galego|1\ngn|Guarani|Avañe\'ẽ|1\ngu|Gujarati|ગુજરાતી|1\ngv|Manx|Gaelg|1\nha|Hausa|(Hausa) هَوُسَ|1\nhe|Hebrew|עברית|1\nhi|Hindi|हिन्दी|1\nho|Hiri Motu|Hiri Motu|1\nhr|Croatian|hrvatski jezik|1\nht|Haitian, Haitian Creole|Kreyòl ayisyen|1\nhu|Hungarian|magyar|1\nhy|Armenian|Հայերեն|1\nhz|Herero|Otjiherero|0\nia|Interlingua (International Auxiliary Language Association)|Interlingua|1\nid|Indonesian|Bahasa Indonesia|1\nie|Interlingue, Occidental|(originally:) Occidental|1\nig|Igbo|Asụsụ Igbo|1\nii|Sichuan Yi, Nuosu|ꆈꌠ꒿ Nuosuhxop|1\nik|Inupiaq|Iñupiaq|1\nio|Ido|Ido|1\nis|Icelandic|Íslenska|1\nit|Italian|Italiano|1\niu|Inuktitut|ᐃᓄᒃᑎᑐᑦ|1\nja|Japanese|日本語 (にほんご)|1\njv|Javanese|ꦧꦱꦗꦮ|1\nka|Georgian|ქართული|1\nkg|Kongo|Kikongo|1\nki|Kikuyu, Gikuyu|Gĩkũyũ|1\nkj|Kuanyama, Kwanyama|Kuanyama|1\nkk|Kazakh|қазақ тілі|1\nkl|Kalaallisut, Greenlandic|kalaallisut|1\nkm|Central Khmer|ខ្មែរ|1\nkn|Kannada|ಕನ್ನಡ|1\nko|Korean|한국어|1\nkr|Kanuri|Kanuri|1\nks|Kashmiri|कॉशुर|1\nku|Kurdish|Kurdî|1\nkv|Komi|коми кыв|1\nkw|Cornish|Kernewek|1\nky|Kirghiz, Kyrgyz|Кыргызча|1\nla|Latin|latine|1\nlb|Luxembourgish, Letzeburgesch|Lëtzebuergesch|1\nlg|Ganda|Luganda|1\nli|Limburgan, Limburger, Limburgish|Limburgs|1\nln|Lingala|Lingála|1\nlo|Lao|ພາສາລາວ|1\nlt|Lithuanian|lietuvių kalba|1\nlu|Luba-Katanga|Kiluba|1\nlv|Latvian|latviešu valoda|1\nmg|Malagasy|fiteny malagasy|1\nmh|Marshallese|Kajin M̧ajeļ|1\nmi|Maori|te reo Māori|1\nmk|Macedonian|македонски јазик|1\nml|Malayalam|മലയാളം|1\nmn|Mongolian|Монгол хэл|1\nmr|Marathi|मराठी|1\nms|Malay|Bahasa Melayu|1\nmt|Maltese|Malti|1\nmy|Burmese|ဗမာစာ|1\nna|Nauru|Dorerin Naoero|1\nnb|Norwegian Bokmål|Norsk Bokmål|1\nnd|North Ndebele|isiNdebele|0\nne|Nepali|नेपाली|1\nng|Ndonga|Owambo|0\nnl|Dutch, Flemish|Nederlands|1\nnn|Norwegian Nynorsk|Norsk Nynorsk|1\nno|Norwegian|Norsk|1\nnr|South Ndebele|isiNdebele|0\nnv|Navajo, Navaho|Diné bizaad|1\nny|Chichewa, Chewa, Nyanja|chiCheŵa|1\noc|Occitan|occitan|1\noj|Ojibwa|ᐊᓂᔑᓈᐯᒧᐎᓐ|1\nom|Oromo|Afaan Oromoo|1\nor|Oriya|ଓଡ଼ିଆ|1\nos|Ossetian, Ossetic|ирон ӕвзаг|1\npa|Punjabi, Panjabi|ਪੰਜਾਬੀ|1\npi|Pali|पालि|1\npl|Polish|język polski|1\nps|Pashto, Pushto|پښتو|1\npt|Portuguese|Português|1\nqu|Quechua|Runa Simi|1\nrm|Romansh|Rumantsch Grischun|1\nrn|Rundi|Ikirundi|1\nro|Romanian, Moldavian, Moldovan|Română|1\nru|Russian|русский|1\nrw|Kinyarwanda|Ikinyarwanda|1\nsa|Sanskrit|संस्कृतम्|1\nsc|Sardinian|sardu|1\nsd|Sindhi|सिंधी|1\nse|Northern Sami|Davvisámegiella|1\nsg|Sango|yângâ tî sängö|1\nsi|Sinhala, Sinhalese|සිංහල|1\nsk|Slovak|slovenčina|1\nsl|Slovenian|Slovenski jezik|1\nsm|Samoan|gagana fa\'a Samoa|1\nsn|Shona|chiShona|1\nso|Somali|Soomaaliga|1\nsq|Albanian|Shqip|1\nsr|Serbian|српски језик|1\nss|Swati|SiSwati|1\nst|Southern Sotho|Sesotho|1\nsu|Sundanese|Basa Sunda|1\nsv|Swedish|Svenska|1\nsw|Swahili|Kiswahili|1\nta|Tamil|தமிழ்|1\nte|Telugu|తెలుగు|1\ntg|Tajik|тоҷикӣ|1\nth|Thai|ไทย|1\nti|Tigrinya|ትግርኛ|1\ntk|Turkmen|Türkmençe|1\ntl|Tagalog|Wikang Tagalog|1\ntn|Tswana|Setswana|1\nto|Tonga (Tonga Islands)|Faka Tonga|1\ntr|Turkish|Türkçe|1\nts|Tsonga|Xitsonga|1\ntt|Tatar|татар теле|1\ntw|Twi|Twi|1\nty|Tahitian|Reo Tahiti|1\nug|Uighur, Uyghur|ئۇيغۇرچە|1\nuk|Ukrainian|Українська|1\nur|Urdu|اردو|1\nuz|Uzbek|Oʻzbek|1\nve|Venda|Tshivenḓa|1\nvi|Vietnamese|Tiếng Việt|1\nvo|Volapük|Volapük|1\nwa|Walloon|Walon|1\nwo|Wolof|Wollof|1\nxh|Xhosa|isiXhosa|1\nyi|Yiddish|ייִדיש|1\nyo|Yoruba|Yorùbá|1\nza|Zhuang, Chuang|Saɯ cueŋƅ|1\nzh|Chinese|中文 (Zhōngwén)|1\nzu|Zulu|isiZulu|1';

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
    'aar|Afaraf|aa|0\nab|Abkhazian|аҧсуа бызшәа|1145\nae|Avestan|avesta|5\naf|Afrikaans|Afrikaans|14645\nak|Akan|Akan|367\nam|Amharic|አማርኛ|6087\nan|Aragonese|aragonés|2265\nar|Arabic|العربية|1026627\nas|Assamese|অসমীয়া|251\nav|Avaric|авар мацӀ|327\nay|Aymara|aymar aru|281\naz|Azerbaijani|azərbaycan dili|14090\nba|Bashkir|башҡорт теле|4722\nbe|Belarusian|беларуская мова|244447\nbg|Bulgarian|български език|28644\nbi|Bislama|Bislama|194\nbm|Bambara|bamanankan|591\nbn|Bengali|বাংলা|12359\nbo|Tibetan|བོད་ཡིག|4993\nbr|Breton|brezhoneg|212137\nbs|Bosnian|bosanski jezik|3325\nca|Catalan|català|93950\nce|Chechen|нохчийн мотт|2879\nch|Chamorro|Chamoru|84\nco|Corsican|corsu|1134\ncr|Cree|ᓀᐦᐃᔭᐍᐏᐣ|475\ncs|Czech|čeština|48302\ncu|Church Slavic|ѩзыкъ словѣньскъ|207\ncv|Chuvash|чӑваш чӗлхи|8124\ncy|Welsh|Cymraeg|25102\nda|Danish|dansk|8222\nde|German|Deutsch|489163\ndv|Divehi|ދިވެހި|922\ndz|Dzongkha|རྫོང་ཁ|588\nee|Ewe|Eʋegbe|1797\nel|Greek|Ελληνικά|77880\nen|English|English|5334274\neo|Esperanto|Esperanto|10866\nes|Spanish|Español|267804\net|Estonian|eesti|7317\neu|Basque|euskara|53253\nfa|Persian|فارسی|41277\nff|Fulah|Fulfulde|333\nfi|Finnish|suomi|355233\nfj|Fijian|vosa Vakaviti|52\nfo|Faroese|føroyskt|760\nfr|French|français|546740\nfy|Western Frisian|Frysk|6828\nga|Irish|Gaeilge|82937\ngd|Gaelic|Gàidhlig|6540\ngl|Galician|Galego|14483\ngn|Guarani|Avañe\'ẽ|403\ngu|Gujarati|ગુજરાતી|1666\ngv|Manx|Gaelg|1612\nha|Hausa|(Hausa) هَوُسَ|433\nhe|Hebrew|עברית|153501\nhi|Hindi|हिन्दी|43600\nho|Hiri Motu|Hiri Motu|2\nhr|Croatian|hrvatski jezik|10252\nht|Haitian|Kreyòl ayisyen|1096\nhu|Hungarian|magyar|54602\nhy|Armenian|Հայերեն|21468\nhz|Herero|Otjiherero|0\nia|Interlingua|Interlingua|925\nid|Indonesian|Bahasa Indonesia|8307\nie|Interlingue|Interlingue|506\nig|Igbo|Asụsụ Igbo|131\nii|Sichuan Yi|ꆈꌠ꒿ Nuosuhxop|38\nik|Inupiaq|Iñupiaq|128\nio|Ido|Ido|938\nis|Icelandic|Íslenska|2076\nit|Italian|Italiano|108025\niu|Inuktitut|ᐃᓄᒃᑎᑐᑦ|2761\nja|Japanese|日本語|919264\njv|Javanese|ꦧꦱꦗꦮ|838\nka|Georgian|ქართული|39572\nkg|Kongo|Kikongo|395\nki|Kikuyu|Gĩkũyũ|862\nkj|Kuanyama|Kuanyama|1\nkk|Kazakh|қазақ тілі|13052\nkl|Kalaallisut|kalaallisut|584\nkm|Central Khmer|ខ្មែរ|2127\nkn|Kannada|ಕನ್ನಡ|73056\nko|Korean|한국어|658240\nkr|Kanuri|Kanuri|81\nks|Kashmiri|कॉशुर|5468\nku|Kurdish|Kurdî|29670\nkv|Komi|коми кыв|758\nkw|Cornish|Kernewek|911\nky|Kirghiz|Кыргызча|3672\nla|Latin|latine|8895\nlb|Luxembourgish|Lëtzebuergesch|5431\nlg|Ganda|Luganda|369\nli|Limburgan|Limburgs|1073\nln|Lingala|Lingála|567\nlo|Lao|ພາສາລາວ|3014\nlt|Lithuanian|lietuvių kalba|49223\nlu|Luba-Katanga|Kiluba|4\nlv|Latvian|latviešu valoda|11309\nmg|Malagasy|fiteny malagasy|1774\nmh|Marshallese|Kajin M̧ajeļ|63\nmi|Maori|te reo Māori|8975\nmk|Macedonian|македонски јазик|22972\nml|Malayalam|മലയാളം|14798\nmn|Mongolian|Монгол хэл|7875\nmr|Marathi|मराठी|10186\nms|Malay|Bahasa Melayu|13420\nmt|Maltese|Malti|2659\nmy|Burmese|ဗမာစာ|32507\nna|Nauru|Dorerin Naoero|355\nnb|Norwegian Bokmål|Norsk Bokmål|396\nnd|North Ndebele|isiNdebele|0\nne|Nepali|नेपाली|9561\nng|Ndonga|Owambo|0\nnl|Dutch|Nederlands|71574\nnn|Norwegian Nynorsk|Norsk Nynorsk|2504\nno|Norwegian|Norsk|7914\nnr|South Ndebele|isiNdebele|0\nnv|Navajo|Diné bizaad|641\nny|Chichewa|chiCheŵa|99\noc|Occitan|occitan|51805\noj|Ojibwa|ᐊᓂᔑᓈᐯᒧᐎᓐ|546\nom|Oromo|Afaan Oromoo|163\nor|Oriya|ଓଡ଼ିଆ|1608\nos|Ossetian|ирон ӕвзаг|5502\npa|Punjabi|ਪੰਜਾਬੀ|18756\npi|Pali|पालि|68\npl|Polish|język polski|324678\nps|Pashto|پښتو|13652\npt|Portuguese|Português|38176\nqu|Quechua|Runa Simi|933\nrm|Romansh|Rumantsch Grischun|971\nrn|Rundi|Ikirundi|299\nro|Romanian|Română|48448\nru|Russian|русский|1426104\nrw|Kinyarwanda|Ikinyarwanda|446\nsa|Sanskrit|संस्कृतम्|458\nsc|Sardinian|sardu|1570\nsd|Sindhi|सिंधी|8161\nse|Northern Sami|Davvisámegiella|6364\nsg|Sango|yângâ tî sängö|365\nsi|Sinhala|සිංහල|1960\nsk|Slovak|slovenčina|8214\nsl|Slovenian|Slovenski jezik|10210\nsm|Samoan|gagana fa\'a Samoa|220\nsn|Shona|chiShona|359\nso|Somali|Soomaaliga|881\nsq|Albanian|Shqip|14776\nsr|Serbian|српски језик|157996\nss|Swati|SiSwati|310\nst|Southern Sotho|Sesotho|190\nsu|Sundanese|Basa Sunda|519\nsv|Swedish|Svenska|136625\nsw|Swahili|Kiswahili|8839\nta|Tamil|தமிழ்|13910\nte|Telugu|తెలుగు|5994\ntg|Tajik|тоҷикӣ|3443\nth|Thai|ไทย|82009\nti|Tigrinya|ትግርኛ|1075\ntk|Turkmen|Türkmençe|8073\ntl|Tagalog|Wikang Tagalog|5561\ntn|Tswana|Setswana|122\nto|Tonga|Faka Tonga|300\ntr|Turkish|Türkçe|24120\nts|Tsonga|Xitsonga|160\ntt|Tatar|татар теле|16406\ntw|Twi|Twi|115\nty|Tahitian|Reo Tahiti|168\nug|Uighur|ئۇيغۇرچە|13688\nuk|Ukrainian|Українська|532129\nur|Urdu|اردو|58424\nuz|Uzbek|Oʻzbek|7268\nve|Venda|Tshivenḓa|47\nvi|Vietnamese|Tiếng Việt|27767\nvo|Volapük|Volapük|752\nwa|Walloon|Walon|1879\nwo|Wolof|Wollof|446\nxh|Xhosa|isiXhosa|135\nyi|Yiddish|ייִדיש|1180\nyo|Yoruba|Yorùbá|705\nza|Zhuang|Saɯ cueŋƅ|496\nzh|Chinese|中文 (Zhōngwén)|1012372\nzu|Zulu|isiZulu|726';

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
  "Q644636": ["el", "tr"],
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
    'aar|Afaraf|aa|0\nab|Abkhazian|?????????? ????????????|1145\nae|Avestan|avesta|5\naf|Afrikaans|Afrikaans|14645\nak|Akan|Akan|367\nam|Amharic|????????????|6087\nan|Aragonese|aragon??s|2265\nar|Arabic|??????????????|1026627\nas|Assamese|?????????????????????|251\nav|Avaric|???????? ????????|327\nay|Aymara|aymar aru|281\naz|Azerbaijani|az??rbaycan dili|14090\nba|Bashkir|?????????????? ????????|4722\nbe|Belarusian|???????????????????? ????????|244447\nbg|Bulgarian|?????????????????? ????????|28644\nbi|Bislama|Bislama|194\nbm|Bambara|bamanankan|591\nbn|Bengali|???????????????|12359\nbo|Tibetan|?????????????????????|4993\nbr|Breton|brezhoneg|212137\nbs|Bosnian|bosanski jezik|3325\nca|Catalan|catal??|93950\nce|Chechen|?????????????? ????????|2879\nch|Chamorro|Chamoru|84\nco|Corsican|corsu|1134\ncr|Cree|?????????????????????|475\ncs|Czech|??e??tina|48302\ncu|Church Slavic|?????????? ????????????????????|207\ncv|Chuvash|?????????? ??????????|8124\ncy|Welsh|Cymraeg|25102\nda|Danish|dansk|8222\nde|German|Deutsch|489163\ndv|Divehi|????????????|922\ndz|Dzongkha|??????????????????|588\nee|Ewe|E??egbe|1797\nel|Greek|????????????????|77880\nen|English|English|5334274\neo|Esperanto|Esperanto|10866\nes|Spanish|Espa??ol|267804\net|Estonian|eesti|7317\neu|Basque|euskara|53253\nfa|Persian|??????????|41277\nff|Fulah|Fulfulde|333\nfi|Finnish|suomi|355233\nfj|Fijian|vosa Vakaviti|52\nfo|Faroese|f??royskt|760\nfr|French|fran??ais|546740\nfy|Western Frisian|Frysk|6828\nga|Irish|Gaeilge|82937\ngd|Gaelic|G??idhlig|6540\ngl|Galician|Galego|14483\ngn|Guarani|Ava??e\'???|403\ngu|Gujarati|?????????????????????|1666\ngv|Manx|Gaelg|1612\nha|Hausa|(Hausa) ????????????|433\nhe|Hebrew|??????????|153501\nhi|Hindi|??????????????????|43600\nho|Hiri Motu|Hiri Motu|2\nhr|Croatian|hrvatski jezik|10252\nht|Haitian|Krey??l ayisyen|1096\nhu|Hungarian|magyar|54602\nhy|Armenian|??????????????|21468\nhz|Herero|Otjiherero|0\nia|Interlingua|Interlingua|925\nid|Indonesian|Bahasa Indonesia|8307\nie|Interlingue|Interlingue|506\nig|Igbo|As???s??? Igbo|131\nii|Sichuan Yi|????????? Nuosuhxop|38\nik|Inupiaq|I??upiaq|128\nio|Ido|Ido|938\nis|Icelandic|??slenska|2076\nit|Italian|Italiano|108025\niu|Inuktitut|??????????????????|2761\nja|Japanese|?????????|919264\njv|Javanese|????????????|838\nka|Georgian|?????????????????????|39572\nkg|Kongo|Kikongo|395\nki|Kikuyu|G??k??y??|862\nkj|Kuanyama|Kuanyama|1\nkk|Kazakh|?????????? ????????|13052\nkl|Kalaallisut|kalaallisut|584\nkm|Central Khmer|???????????????|2127\nkn|Kannada|???????????????|73056\nko|Korean|?????????|658240\nkr|Kanuri|Kanuri|81\nks|Kashmiri|???????????????|5468\nku|Kurdish|Kurd??|29670\nkv|Komi|???????? ??????|758\nkw|Cornish|Kernewek|911\nky|Kirghiz|????????????????|3672\nla|Latin|latine|8895\nlb|Luxembourgish|L??tzebuergesch|5431\nlg|Ganda|Luganda|369\nli|Limburgan|Limburgs|1073\nln|Lingala|Ling??la|567\nlo|Lao|?????????????????????|3014\nlt|Lithuanian|lietuvi?? kalba|49223\nlu|Luba-Katanga|Kiluba|4\nlv|Latvian|latvie??u valoda|11309\nmg|Malagasy|fiteny malagasy|1774\nmh|Marshallese|Kajin M??aje??|63\nmi|Maori|te reo M??ori|8975\nmk|Macedonian|???????????????????? ??????????|22972\nml|Malayalam|??????????????????|14798\nmn|Mongolian|???????????? ??????|7875\nmr|Marathi|???????????????|10186\nms|Malay|Bahasa Melayu|13420\nmt|Maltese|Malti|2659\nmy|Burmese|???????????????|32507\nna|Nauru|Dorerin Naoero|355\nnb|Norwegian Bokm??l|Norsk Bokm??l|396\nnd|North Ndebele|isiNdebele|0\nne|Nepali|??????????????????|9561\nng|Ndonga|Owambo|0\nnl|Dutch|Nederlands|71574\nnn|Norwegian Nynorsk|Norsk Nynorsk|2504\nno|Norwegian|Norsk|7914\nnr|South Ndebele|isiNdebele|0\nnv|Navajo|Din?? bizaad|641\nny|Chichewa|chiChe??a|99\noc|Occitan|occitan|51805\noj|Ojibwa|????????????????????????|546\nom|Oromo|Afaan Oromoo|163\nor|Oriya|???????????????|1608\nos|Ossetian|???????? ??????????|5502\npa|Punjabi|??????????????????|18756\npi|Pali|????????????|68\npl|Polish|j??zyk polski|324678\nps|Pashto|????????|13652\npt|Portuguese|Portugu??s|38176\nqu|Quechua|Runa Simi|933\nrm|Romansh|Rumantsch Grischun|971\nrn|Rundi|Ikirundi|299\nro|Romanian|Rom??n??|48448\nru|Russian|??????????????|1426104\nrw|Kinyarwanda|Ikinyarwanda|446\nsa|Sanskrit|???????????????????????????|458\nsc|Sardinian|sardu|1570\nsd|Sindhi|???????????????|8161\nse|Northern Sami|Davvis??megiella|6364\nsg|Sango|y??ng?? t?? s??ng??|365\nsi|Sinhala|???????????????|1960\nsk|Slovak|sloven??ina|8214\nsl|Slovenian|Slovenski jezik|10210\nsm|Samoan|gagana fa\'a Samoa|220\nsn|Shona|chiShona|359\nso|Somali|Soomaaliga|881\nsq|Albanian|Shqip|14776\nsr|Serbian|???????????? ??????????|157996\nss|Swati|SiSwati|310\nst|Southern Sotho|Sesotho|190\nsu|Sundanese|Basa Sunda|519\nsv|Swedish|Svenska|136625\nsw|Swahili|Kiswahili|8839\nta|Tamil|???????????????|13910\nte|Telugu|??????????????????|5994\ntg|Tajik|????????????|3443\nth|Thai|?????????|82009\nti|Tigrinya|????????????|1075\ntk|Turkmen|T??rkmen??e|8073\ntl|Tagalog|Wikang Tagalog|5561\ntn|Tswana|Setswana|122\nto|Tonga|Faka Tonga|300\ntr|Turkish|T??rk??e|24120\nts|Tsonga|Xitsonga|160\ntt|Tatar|?????????? ????????|16406\ntw|Twi|Twi|115\nty|Tahitian|Reo Tahiti|168\nug|Uighur|????????????????|13688\nuk|Ukrainian|????????????????????|532129\nur|Urdu|????????|58424\nuz|Uzbek|O??zbek|7268\nve|Venda|Tshiven???a|47\nvi|Vietnamese|Ti???ng Vi???t|27767\nvo|Volap??k|Volap??k|752\nwa|Walloon|Walon|1879\nwo|Wolof|Wollof|446\nxh|Xhosa|isiXhosa|135\nyi|Yiddish|????????????|1180\nyo|Yoruba|Yor??b??|705\nza|Zhuang|Sa?? cue????|496\nzh|Chinese|?????? (Zh??ngw??n)|1012372\nzu|Zulu|isiZulu|726';

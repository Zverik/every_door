// ignore_for_file: avoid_print

import 'dart:io';
import 'package:encrypt/encrypt.dart';

String encryptUrl(String url) {
  const kDefaultAesKey = '+p08T46G5YGKftKBHUeg0A==';
  final encrypter = Encrypter(AES(Key.fromBase64(kDefaultAesKey), mode: AESMode.ctr));
  final decrypted = encrypter.encrypt(url, iv: IV.allZerosOfLength(16));
  return decrypted.base64;
}

void main(List<String> args) {
  if (args.isEmpty) {
    print('Encodes an URL with AES, to put into lib/providers/imagery.dart');
    print('Usage: dart encode_url.dart "url"');
    exit(1);
  }
  print(encryptUrl(args[0]));
}

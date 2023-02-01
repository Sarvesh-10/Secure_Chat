import 'package:chat_app/Services/Encryption/encryption_contract.dart';
import 'package:encrypt/encrypt.dart';

class EncryptionService implements IEncryption {
  final Encrypter _encrypter;
  final _iv = IV.fromLength(16);

  EncryptionService(this._encrypter);
  @override
  String decrypt(String encryptedText) {
    // TODO: implement decrypt

    final encrypted = Encrypted.fromBase64(encryptedText);
    return _encrypter.decrypt(encrypted, iv: _iv);
  }

  @override
  String encrpyt(String text) {
    // TODO: implement encrpyt

    final decrypted = Encrypted.fromBase64(text);
    return _encrypter.encrypt(text, iv: _iv).base64;
    
  }
}

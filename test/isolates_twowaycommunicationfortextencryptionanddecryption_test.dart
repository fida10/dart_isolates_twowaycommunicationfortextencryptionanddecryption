import 'package:isolates_twowaycommunicationfortextencryptionanddecryption/isolates_twowaycommunicationfortextencryptionanddecryption.dart';
import 'package:test/test.dart';


void main() {
  test('encryptDecryptTextInIsolate handles text encryption and decryption',
      () async {
    var textIsolate = await setupTextEncryptionIsolate();
    String encrypted = await textIsolate
        .sendAndReceive({'command': 'encrypt', 'text': 'hello'});

    expect(        
        encrypted,
        isNot('hello'));
    expect(
        await textIsolate
            .sendAndReceive({'command': 'decrypt', 'text': encrypted}),
        equals('hello'));
    expect(
        await textIsolate
            .sendAndReceive({'command': 'encrypt', 'text': 'dart'}),
        isNot('dart'));

    await textIsolate.shutdown();
  });
}

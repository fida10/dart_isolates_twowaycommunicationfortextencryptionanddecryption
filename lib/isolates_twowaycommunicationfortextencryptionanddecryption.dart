/// Support for doing something awesome.
///
/// More dartdocs go here.
library;

import 'dart:async';
import 'dart:isolate';

export 'src/isolates_twowaycommunicationfortextencryptionanddecryption_base.dart';

/*
Practice Question 2: Two-Way Communication for Text Encryption and Decryption

Task:

Create a function encryptDecryptTextInIsolate that performs text encryption and decryption 
in a separate isolate using two-way communication. 
The main isolate can send text to be encrypted or decrypted along with the command ('encrypt' or 'decrypt').
 */

class TextEncryptionMainIsolate {
  Isolate? worker;
  ReceivePort receivedFromWorker = ReceivePort();
  SendPort? sendToWorker;
  Stream? streamFromWorker;

  TextEncryptionMainIsolate() {
    streamFromWorker = receivedFromWorker.asBroadcastStream();
  }

  Future<String> sendAndReceive(Map<String, String> input) async {
    final completer = Completer<String>();

    worker ??= await Isolate.spawn(
        indivEncryptionWorkerIsolate, receivedFromWorker.sendPort);
    (sendToWorker != null)
        ? sendToWorker?.send(input)
        : print(
            'Send port to worker has not been initialized! This must be the first run.');

    late StreamSubscription? sub;
    sub = streamFromWorker?.listen((event) async {
      print('Message from worker: $event');
      if (event is SendPort) {
        sendToWorker = event;
        sendToWorker?.send(input);
      }

      if (event is String) {
        completer.complete(event);
        sub?.cancel();
      }
    });

    return completer.future;
  }

  Future<void> shutdown() async {
    receivedFromWorker.close();
    worker?.kill();
    worker = null;
  }
}

Future<void> indivEncryptionWorkerIsolate(SendPort sendToMain) async {
  final receievedFromMain = ReceivePort();
  sendToMain.send(receievedFromMain.sendPort);

  receievedFromMain.listen((message) {
    print('Message from worker: $message');

    if (message is Map<String, String>) {
      final processed = encryptAndDecrypt(message);
      sendToMain.send(processed);
    }
  });
}

encryptAndDecrypt(Map<String, String> input) {
  Map<String, String> encryptCypher = {
    'a': 'ぁ',
    'b': 'あ',
    'c': 'ぃ',
    'd': 'い',
    'e': 'ぅ',
    'f': 'う',
    'g': 'え',
    'h': 'お',
    'i': 'か',
    'j': 'き',
    'k': 'ぐ',
    'l': 'け',
    'm': 'ご',
    'n': 'ざ',
    'o': 'じ',
    'p': 'ず',
    'q': 'ぜ',
    'r': 'ぞ',
    's': 'だ',
    't': 'ぢ',
    'u': 'づ',
    'v': 'で',
    'w': 'ど',
    'x': 'ぬ',
    'y': 'の',
    'z': 'ゑ',
  };

  Map<String, String> decryptCypher = {
    'ぁ': 'a',
    'あ': 'b',
    'ぃ': 'c',
    'い': 'd',
    'ぅ': 'e',
    'う': 'f',
    'え': 'g',
    'お': 'h',
    'か': 'i',
    'き': 'j',
    'ぐ': 'k',
    'け': 'l',
    'ご': 'm',
    'ざ': 'n',
    'じ': 'o',
    'ず': 'p',
    'ぜ': 'q',
    'ぞ': 'r',
    'だ': 's',
    'ぢ': 't',
    'づ': 'u',
    'で': 'v',
    'ど': 'w',
    'ぬ': 'x',
    'の': 'y',
    'ゑ': 'z',
  };
  if (input['command'] == 'encrypt') {
    return input['text']
        ?.split('')
        .map((indivChar) => encryptCypher[indivChar])
        .join('');
  } else if (input['command'] == 'decrypt') {
    return input['text']
        ?.split('')
        .map((indivChar) => decryptCypher[indivChar])
        .join('');
  } else {
    return null;
  }
}

Future<TextEncryptionMainIsolate> setupTextEncryptionIsolate() async {
  return TextEncryptionMainIsolate();
}

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

/*
অনুশীলনী প্রশ্ন ২: টেক্সট এনক্রিপশন এবং ডিক্রিপশনের জন্য দ্বিমুখী যোগাযোগ

কাজ:

এমন একটি ফাংশন encryptDecryptTextInIsolate তৈরি করুন যা পৃথক একটি আইসোলেটে টেক্সট এনক্রিপশন ও ডিক্রিপশন পরিচালনা করে, দ্বিমুখী যোগাযোগের মাধ্যমে।
মূল আইসোলেট এনক্রিপ্ট বা ডিক্রিপ্ট করার জন্য টেক্সট পাঠাতে পারে এবং নির্দেশনা ('encrypt' বা 'decrypt') সহ।
*/

class TextEncryptionMainIsolate {
  Isolate? worker;
  ReceivePort receivedFromWorker = ReceivePort();
  SendPort? sendToWorker;
  Stream? streamFromWorker;

  /* 
  The above fields remain constant for an object of this class.
  worker: only one Isolate should be created per object
  receivedFromWorker: one receiver should be made for the main isolate, and its sendport should be sent during isolate creation to the worker isolate so that the worker isolate can send back to main
  sendToWorker: This is received from the worker as the means with which the main isolate can send stuff to the worker isolate
  streamFromWorker: The items that are being received from the worker are in the form of a stream. This is that stream
  */

  /* 
  উপরের ফিল্ডগুলি এই ক্লাসের একটি অবজেক্টের জন্য স্থির থাকে।
  worker: প্রতি অবজেক্টের জন্য কেবল একটি আইসোলেট তৈরি করা উচিত
  receivedFromWorker: মূল আইসোলেটের জন্য একটি রিসিভার তৈরি করা উচিত, এবং তার sendport আইসোলেট তৈরির সময় কর্মী আইসোলেটে পাঠানো উচিত যাতে কর্মী আইসোলেট মূলতে ফেরত পাঠাতে পারে
  sendToWorker: এটি কর্মী থেকে প্রাপ্ত হয় যাতে মূল আইসোলেট কর্মী আইসোলেটে জিনিস পাঠাতে পারে
  streamFromWorker: কর্মী থেকে প্রাপ্ত জিনিসগুলি একটি স্ট্রিমের আকারে আসে। এটি সেই স্ট্রিম
  */
  TextEncryptionMainIsolate() {
    streamFromWorker = receivedFromWorker.asBroadcastStream();

    /*
    this converts and saves the stream received from the worker to a broadcast stream
    this is necessary since this stream will be listened to multiple times (see test cases)
    a regular stream can only be listened to once before it is poisoned (or unusable)
    */

    /*
    এটি কর্মী থেকে প্রাপ্ত স্ট্রিমটিকে একটি ব্রডকাস্ট স্ট্রিমে পরিণত করে এবং সংরক্ষণ করে
    এটি প্রয়োজনীয় কারণ এই স্ট্রিমটি একাধিকবার শোনা হবে (টেস্ট কেসগুলি দেখুন)
    একটি সাধারণ স্ট্রিম একবার শোনার পরে বিষাক্ত (বা অব্যবহার্য) হয়ে যায়
    */
  }

  /*
  sendAndReceive: the method used to run encryption/decryption in a separate isolate. Takes a map as input, provided by test cases
   */
  /*
  sendAndReceive: পৃথক একটি আইসোলেটে এনক্রিপশন/ডিক্রিপশন চালানোর জন্য ব্যবহৃত পদ্ধতি। ইনপুট হিসেবে একটি ম্যাপ নেয়, যা টেস্ট কেসগুলি দ্বারা প্রদত্ত
   */
  Future<String> sendAndReceive(Map<String, String> input) async {
    final completer = Completer<String>();
    /*
    completer: we will save the result of the worker isolate inside of completer
     */
    /*
    completer: আমরা কর্মী আইসোলেটের ফলাফল এই completer এর মধ্যে সংরক্ষণ করব
     */

    worker ??= await Isolate.spawn(
        indivEncryptionWorkerIsolate, receivedFromWorker.sendPort);
    /*
        This line spawns a new isolate and saves it inside of the "worker" field IF worker is null
        meaining if a worker isolate has not been spawned, a new isolate will be spawned
        This will happen only once per object of TextEncryptionMainIsolate created

        The isolate is spawned using the indivEncryptionWorkerIsolate method as its main method and receivedFromWorker.sendPort as the method parameter
        receivedFromWorker.sendPort is the sendport of the receivedFromWorker ReceivePort that was created above
        This allows the worker to use this sendport to send stuff back to the main isolate, which is received in the receivedFromWorker ReceivePort
         */

/*
    এই লাইনটি একটি নতুন আইসোলেট তৈরি করে এবং যদি "worker" ফিল্ড খালি থাকে তবে তা "worker" ফিল্ডে সংরক্ষণ করে
    অর্থাৎ যদি কোন কর্মী আইসোলেট তৈরি না হয়, তবে একটি নতুন আইসোলেট তৈরি হবে
    এটি প্রতিটি TextEncryptionMainIsolate অবজেক্ট তৈরির জন্য কেবল একবারই ঘটবে

    আইসোলেটটি তৈরি করা হয় indivEncryptionWorkerIsolate পদ্ধতি ব্যবহার করে এর মূল পদ্ধতি হিসেবে এবং receivedFromWorker.sendPort কে পদ্ধতির প্যারামিটার হিসেবে
    receivedFromWorker.sendPort হল receivedFromWorker ReceivePort-এর সেন্ডপোর্ট যা উপরে তৈরি করা হয়েছিল
    এটি কর্মীকে এই সেন্ডপোর্ট ব্যবহার করে মূল আইসোলেটে জিনিস পাঠানোর সুযোগ দেয়, যা receivedFromWorker ReceivePort-এ গৃহীত হয়
*/

    (sendToWorker != null)
        ? sendToWorker?.send(input)
        : print(
            'Send port to worker has not been initialized! This must be the first run.');
    /*
        After the first execution of the sendAndReceive method, the worker will have already send a sendPort to the main isolate
        This is saved inside of the sendToWorker on the class level (see below code inside listen block to understand how this happens)
        For every subsequent execution of the sendAndReceive method after the first, we can use the already created sendToWorker sendport to send stuff to the worker isolate
        Here, we are sending the input map (from test case) to the worker isolate to process
        If this is the first time the sendAndReceive method is being called, then sendToWorker will be null
        If this is the case, the print statement telling the user that the send port from the worker has not been initialized
         */

    /*
    sendAndReceive পদ্ধতির প্রথম বাস্তবায়নের পরে, কর্মীটি ইতিমধ্যে মূল আইসোলেটে একটি sendPort পাঠাবে
    এটি ক্লাস স্তরে sendToWorker এ সংরক্ষিত হয় (এটি কীভাবে ঘটে তা বুঝতে নীচের কোডের listen ব্লক দেখুন)
    প্রথম বাস্তবায়নের পরে sendAndReceive পদ্ধতির প্রতিটি পরবর্তী বাস্তবায়নে, আমরা ইতিমধ্যে তৈরি করা sendToWorker sendport ব্যবহার করে কর্মী আইসোলেটে জিনিস পাঠাতে পারি
    এখানে, আমরা কর্মী আইসোলেটে প্রক্রিয়া করার জন্য ইনপুট ম্যাপ (টেস্ট কেস থেকে) পাঠাচ্ছি
    যদি এটি sendAndReceive পদ্ধতি ডাকা প্রথম বার হয়, তবে sendToWorker খালি থাকবে
    যদি এই অবস্থা ঘটে, তবে প্রিন্ট বিবৃতিটি ব্যবহারকারীকে জানাবে যে কর্মী থেকে প্রেরিত পোর্টটি আরম্ভ করা হয়নি
*/

    late StreamSubscription? sub;
    sub = streamFromWorker?.listen((event) async {
      /*
      Here, we are listening to what the worker is sending us via a stream
      This stream is a broadcast stream because it will be listened to multiple times (explained above in the constructor)
      One "listen" of this stream is called a StreamSubscription, which we save in a variable sub
      We close this StreamSubscription once we are done listening to it (in other words once the worker isolate has done what we asked it to and we've received a result from it)
      We do this so that one StreamSubscription does not conflict with another
       */

/*
    এখানে, আমরা একটি স্ট্রিমের মাধ্যমে কর্মী যা পাঠাচ্ছে তা শুনছি
    এই স্ট্রিমটি একটি ব্রডকাস্ট স্ট্রিম কারণ এটি বহুবার শোনা হবে (উপরে নির্মাতাতে ব্যাখ্যা করা হয়েছে)
    এই স্ট্রিমের একটি "শোনা"কে StreamSubscription বলা হয়, যা আমরা একটি ভেরিয়েবল sub এ সংরক্ষণ করি
    আমরা শোনা শেষ হলে (অর্থাৎ কর্মী আইসোলেট যা করতে বলা হয়েছে তা করে এবং আমরা এর থেকে ফলাফল পেয়েছি) এই StreamSubscription বন্ধ করি
    আমরা এটি করি যাতে একটি StreamSubscription অন্যের সাথে দ্বন্দ্ব না করে
*/

      print('Message from worker: $event');
      //debug message

      if (event is SendPort) {
        sendToWorker = event;
        sendToWorker?.send(input);
      }
      /*
      The worker, when initialized, will send a Sendport to the main isolate (here) that the main isolate can use to send stuff to the worker
      This "SendPort" is received in this stream
      Once received, we save it in the "sendToWorker" field so that it can be used in later calls of the sendAndReceive method

      We then also send the input map (from test cases) to the worker so it can process it
       */

/*
    কর্মী, আরম্ভ করার সময়, মূল আইসোলেটে (এখানে) একটি Sendport পাঠাবে যা মূল আইসোলেট কর্মীকে জিনিস পাঠাতে ব্যবহার করতে পারে
    এই "SendPort" এই স্ট্রিমে গৃহীত হয়
    গ্রহণ করার পর, আমরা এটি "sendToWorker" ফিল্ডে সংরক্ষণ করি যাতে পরবর্তীতে sendAndReceive পদ্ধতির ডাকে এটি ব্যবহার করা যায়

    এরপর আমরা ইনপুট ম্যাপটি (টেস্ট কেস থেকে) কর্মীকে পাঠাই যাতে সে এটি প্রক্রিয়া করতে পারে
*/

      if (event is String) {
        completer.complete(event);
        sub?.cancel();
      }

      /*
      Once the worker completes processing our input map from above, it returns a String, which is captured here
      It then saves this string inside of the completer we created at the beginning of the function (saved as a future since this is executed asynchronously)

      This was the workers main task so we don't need to listen to it anymore here
      Therefore, we close the StreamSubscription with "cancel()"
       */

/*
    একবার কর্মী উপরের ইনপুট ম্যাপ প্রক্রিয়া সম্পূর্ণ করে, এটি একটি স্ট্রিং ফেরত দেয়, যা এখানে ধরা হয়
    তারপর এই স্ট্রিংটি ফাংশনের শুরুতে তৈরি করা কমপ্লিটারের মধ্যে সংরক্ষণ করা হয় (এটি একটি ফিউচার হিসাবে সংরক্ষিত কারণ এটি অ্যাসিঙ্ক্রোনাসলি নির্বাহিত হয়)

    এটি কর্মীর মূল কাজ ছিল তাই আমাদের আর এখানে শোনা দরকার নেই
    তাই, আমরা "cancel" দিয়ে StreamSubscription বন্ধ করি
*/
    });

    return completer.future;
    //the result that the worker gave us is extracted from the completer class and returned by this function
    //কর্মী যে ফলাফলটি আমাদের দিয়েছে তা কমপ্লিটার ক্লাস থেকে বের করা হয় এবং এই ফাংশন দ্বারা ফেরত দেওয়া হয়
  }

  Future<void> shutdown() async {
    receivedFromWorker.close();
    worker?.kill();
    worker = null;
    /*
    We want to ensure that spawned isolates and channels are deallocated once we are done with them
    We close the receiver that receives from the worker with .close()
    We the kill the isolate so that it does not continue to consume memory
    We also set the isolate value to null so that a new isolate can be created with a new call to the sendAndReceive method above
     */

    /*
    আমরা নিশ্চিত করতে চাই যে তৈরি করা আইসোলেটগুলি এবং চ্যানেলগুলি আমাদের কাজ শেষ হলে ডিআলোকেট করা হবে
    আমরা কর্মী থেকে প্রাপ্ত রিসিভারটি .close() দিয়ে বন্ধ করি
    তারপর আমরা আইসোলেটটি মেরে ফেলি যাতে এটি মেমোরি খরচ করা চালিয়ে যায় না
    আমরা আইসোলেটের মানটি নাল হিসাবে সেট করি যাতে উপরের sendAndReceive পদ্ধতিতে নতুন ডাক দিয়ে একটি নতুন আইসোলেট তৈরি করা যায়
*/
  }
}

/*
This method is intended to run in a separately generated isolate
It takes a SendPort as input, which is used to send data back to the main isolate
 */

/*
    এই পদ্ধতিটি পৃথকভাবে তৈরি করা একটি আইসোলেটে চালানোর জন্য উদ্দিষ্ট
    এটি ইনপুট হিসাবে একটি SendPort নেয়, যা মূল আইসোলেটে ডেটা পাঠাতে ব্যবহৃত হয়
*/
Future<void> indivEncryptionWorkerIsolate(SendPort sendToMain) async {
  final receievedFromMain = ReceivePort();
  sendToMain.send(receievedFromMain.sendPort);
  /*
  A receiver is created here, which will receive stuff from the main isolate
  However, the main isolate must have a way to send to this receiver
  So we send this receiver's sendPort to the main isolate, which the main isolate saves
  We can do this using sendToMain, with is the sendPort of the main isolate's recevePort (given to this isolate when it was created, as a parameter, see above for this)
   */

  /*
    এখানে একটি রিসিভার তৈরি করা হয়েছে, যা মূল আইসোলেট থেকে জিনিস প্রাপ্ত করবে
    তবে, মূল আইসোলেটের এই রিসিভারে পাঠানোর উপায় থাকা আবশ্যক
    তাই আমরা এই রিসিভারের sendPort-টি মূল আইসোলেটে পাঠাই, যা মূল আইসোলেট সংরক্ষণ করে
    আমরা এটি sendToMain ব্যবহার করে করতে পারি, যা মূল আইসোলেটের receivePort-এর sendPort (এই আইসোলেট তৈরি করার সময়, একটি প্যারামিটার হিসাবে দেওয়া, এর জন্য উপরে দেখুন)
*/
  receievedFromMain.listen((message) {
    /*
    This listens for messages coming from the main isolate
     */
/*
    এটি মূল আইসোলেট থেকে আসা বার্তা শোনার জন্য ব্যবহৃত হয়
*/
    print('Message from worker: $message');
    //debug message

    if (message is Map<String, String>) {
      final processed = encryptAndDecrypt(message);
      sendToMain.send(processed);

      /*
      The main isolate sends the input map to the worker isolate (see above), which is received here
      This map is then sent to a processing function (see below) which does some processing to convert that map into a string
      The details of the processing function are not that important to understanding isolates, all we need to know is that it does some task and returns a result
      This result is then saved inside of the "processed" variable
      The resulting variable is send back to the main isolate
       */

/*
    মূল আইসোলেট ইনপুট ম্যাপটি কর্মী আইসোলেটে পাঠায় (উপরে দেখুন), যা এখানে গৃহীত হয়
    এরপর এই ম্যাপটি একটি প্রক্রিয়াজাত ফাংশনে পাঠানো হয় (নীচে দেখুন) যা এই ম্যাপকে স্ট্রিং-এ রূপান্তরিত করার জন্য কিছু প্রক্রিয়া করে
    এই প্রক্রিয়াজাত ফাংশনের বিস্তারিত আইসোলেট বোঝার জন্য তেমন গুরুত্বপূর্ণ নয়, আমাদের জানা দরকার শুধু এটি কিছু কাজ করে এবং ফলাফল ফেরত দেয়
    এই ফলাফলটি তারপর "processed" ভেরিয়েবলের মধ্যে সংরক্ষণ করা হয়
    এই ফলাফলমূলক ভেরিয়েবলটি মূল আইসোলেটে ফিরে পাঠানো হয়
*/
    }
  });
}

/*
  The code below will not be explained in detail
  But essentially it splits the given string in the input map (under the 'text' key, see test cases) into individual characters
  If the 'encrypt' command is given, this converts the characters from english to japanese using the encrypt cypher map
  if the 'decrypt' command is given, this converts the characters from japanes to english using the decrypt cypher map
  if neither command is given, it returns null
 */

/*
    নিচের কোডটি বিস্তারিতভাবে ব্যাখ্যা করা হবে না
    কিন্তু মূলত এটি ইনপুট ম্যাপে দেওয়া স্ট্রিংটি (‘text’ কী অধীনে, টেস্ট কেসগুলি দেখুন) পৃথক অক্ষরগুলিতে বিভক্ত করে
    যদি 'encrypt' কমান্ড দেওয়া হয়, এটি অক্ষরগুলিকে ইংরেজি থেকে জাপানি ভাষায় রূপান্তরিত করে encrypt সাইফার ম্যাপ ব্যবহার করে
    যদি 'decrypt' কমান্ড দেওয়া হয়, এটি অক্ষরগুলিকে জাপানি থেকে ইংরেজি ভাষায় রূপান্তরিত করে decrypt সাইফার ম্যাপ ব্যবহার করে
    যদি কোনো কমান্ড না দেওয়া হয়, তাহলে এটি null ফেরত দেয়
*/

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

/*
This method returns an object the the TextEncryptionMainIsolate class, which will be repeatedly used for the sendAndReceive method
The class level fields remain the same for as long as we use this object (see above explanations + test cases)
 */

/*
    এই পদ্ধতিটি TextEncryptionMainIsolate শ্রেণির একটি অবজেক্ট ফেরত দেয়, যা sendAndReceive পদ্ধতির জন্য বারবার ব্যবহার করা হবে
    যতক্ষণ আমরা এই অবজেক্টটি ব্যবহার করব, ততক্ষণ ক্লাস স্তরের ক্ষেত্রগুলি একই থাকবে (উপরের ব্যাখ্যা এবং টেস্ট কেসগুলি দেখুন)
*/
Future<TextEncryptionMainIsolate> setupTextEncryptionIsolate() async {
  return TextEncryptionMainIsolate();
}

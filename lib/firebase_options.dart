// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDaYHWwqwr_vHqOdI8pYjPvrC2k--HymDU',
    appId: '1:215002605660:web:5140dfcfb49c066fef5e99',
    messagingSenderId: '215002605660',
    projectId: 'adams-county-scheduler',
    authDomain: 'adams-county-scheduler.firebaseapp.com',
    storageBucket: 'adams-county-scheduler.appspot.com',
    measurementId: 'G-PDX3HLG68R',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC5fnbyp8NrSX8qbUUysSX7jmYbAt6fFmg',
    appId: '1:215002605660:android:bd8fa1f11830d4dfef5e99',
    messagingSenderId: '215002605660',
    projectId: 'adams-county-scheduler',
    storageBucket: 'adams-county-scheduler.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC1CjPStBh0Y7YQV5Zi_Gr19P4TwvYxTx0',
    appId: '1:215002605660:ios:0d91c32a001e2bb3ef5e99',
    messagingSenderId: '215002605660',
    projectId: 'adams-county-scheduler',
    storageBucket: 'adams-county-scheduler.appspot.com',
    iosClientId: '215002605660-er2qrtk314seg11parnli7s5gkjknoqc.apps.googleusercontent.com',
    iosBundleId: 'com.adamscountyscheduler.app.adamsCountyScheduler',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyC1CjPStBh0Y7YQV5Zi_Gr19P4TwvYxTx0',
    appId: '1:215002605660:ios:9ef441f56662e914ef5e99',
    messagingSenderId: '215002605660',
    projectId: 'adams-county-scheduler',
    storageBucket: 'adams-county-scheduler.appspot.com',
    iosClientId: '215002605660-c904qaoonm3uqdf69tgarrlpe54u6hna.apps.googleusercontent.com',
    iosBundleId: 'com.adamscountyscheduler.app.adamsCountyScheduler.RunnerTests',
  );
}

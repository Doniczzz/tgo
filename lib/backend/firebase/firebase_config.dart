import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

Future initFirebase() async {
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: "AIzaSyAJc9ga13Jwk8Ao1rh3YcCQbeDh_KuhB-I",
            authDomain: "tgo-acudir-ur1vsf.firebaseapp.com",
            projectId: "tgo-acudir-ur1vsf",
            storageBucket: "tgo-acudir-ur1vsf.appspot.com",
            messagingSenderId: "569468819036",
            appId: "1:569468819036:web:832a3aa440b97e08ed3899"));
  } else {
    await Firebase.initializeApp();
  }
}

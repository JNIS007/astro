import 'dart:developer';
import 'dart:io';

import 'package:astrologer_flutter/helper/dialogs.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  Future<void> _handleGoogleBtnClick(BuildContext context) async {
    Dialogues.showProgressBar(context);
    UserCredential? user = await _signInWithGoogle(context);
    Navigator.pop(context);

    if (user != null) {
      log('\nUser: ${user.user}');
      log('\nUserAdditionalInfo: ${user.additionalUserInfo}');
      // Navigate to a different screen or update the UI as needed
    }
  }

  Future<UserCredential?> _signInWithGoogle(BuildContext context) async {
    try {
      await InternetAddress.lookup('google.com');

      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      log('\n_signInWithGoogle: $e');
      // ignore: use_build_context_synchronously
      Dialogues.showSnackbar(context, 'Something went wrong (Check Internet!)');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.cyan[100],
      body: Container(
        margin: const EdgeInsets.only(left: 25, right: 25),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/nobgfirst.png'),
              const Text(
                'Nice to see you!',
                style: TextStyle(
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40.0),
              SizedBox(
                width: 250,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, 'helloagainlogin');
                  },
                  icon: const Icon(Icons.mail),
                  label: const Text('Continue with Email'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.cyan[300],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, 'signupwithemail');
                },
                child: const Text(
                  "Don't have an account? Sign up",
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              const Text(
                "or",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20.0),
              SizedBox(
                width: 250,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _handleGoogleBtnClick(context);
                  },
                  icon: const Icon(Icons.g_mobiledata_outlined),
                  label: const Text('Signup with Google'),
                  style: ElevatedButton.styleFrom(
                    elevation: 1,
                    shape: const StadiumBorder(),
                    backgroundColor: Colors.lightGreen[400],
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

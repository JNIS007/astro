import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
// Import your ChatScreen or the screen you want to redirect to

class CustomLoadingScreen extends StatelessWidget {
  const CustomLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.cyan[100],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 50),
            Column(
              children: [
                Image.asset(
                  "assets/helloagain.png",
                  height: 150,
                  fit: BoxFit.fill,
                ),
                const SizedBox(height: 40),
                const Text(
                  'Hello Again!',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                ),
                const Text('Log into your account'),
              ],
            ),
            const SizedBox(height: 60),
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            const Text(
              'Loading...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );

  }
}
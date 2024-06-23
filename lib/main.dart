import 'package:astrologer_flutter/pages/chat.dart';
import 'package:astrologer_flutter/pages/helloagainlogin.dart';
import 'package:astrologer_flutter/pages/signup.dart';
import 'package:astrologer_flutter/pages/signupwithemail.dart';
import 'package:astrologer_flutter/utils/initialize.dart';
import 'package:flutter/material.dart';

// Assuming setupFirebase is defined somewhere

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupFirebase();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: 'signup',
      routes: {
        'signup': (context) => const Home(),
        'signupwithemail': (context) => const SignUpWithEmail(),
        //'Verify': (context)=>const OtpPage(),
        //'verify2': (context)=>const OtpGet(),
        'helloagainlogin': (context) => HomeScreen(),
        'chat': (context) => ChatScreen(
              currentUserId: '',
              adminEmail: '',
              recipientEmail: '',
              recipientUsername: '',
            ),
        //'PaymentMethod': (context) => const PaymentApp(),
        //'CheckOut': (context) => const OrderPlacedApp(),
        //'PaymentUnsuccesful': (context) => const OrderPlacedWrongApp(),
        // 'HelpAndSupport': (context) => const HelpAndSupportApp(),
        // 'MyProfile': (context) => const Profile(),
      },
    );
  }
}

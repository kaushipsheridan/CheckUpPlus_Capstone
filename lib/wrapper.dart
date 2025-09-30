import 'package:checkupplus_capstone/screens/homepage.dart';
import 'package:checkupplus_capstone/authentication/views/login.dart';
import 'package:checkupplus_capstone/authentication/views/verifyemail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  @override
  Widget build(BuildContext context) {
    print('Wrapper build called');
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          print('Auth state changed: ${snapshot.connectionState}');
          print('Has data: ${snapshot.hasData}');
          print('Has error: ${snapshot.hasError}');
          if (snapshot.hasError) {
            print('Auth error: ${snapshot.error}');
          }
          if (snapshot.hasData) {
            if (snapshot.data!.emailVerified) {
              return HomePage();
            } else {
              return Verify();
            }
          } else {
            return Login();
          }
        },
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

class FingerAuth extends StatefulWidget {
  const FingerAuth({super.key});

  @override
  State<FingerAuth> createState() => _FingerAuthState();
}

class _FingerAuthState extends State<FingerAuth> {
  final LocalAuthentication auth = LocalAuthentication();

  checkAuth() async {
    bool isAvailable;
    isAvailable = await auth.canCheckBiometrics;
    print(isAvailable);
    if (isAvailable) {}
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

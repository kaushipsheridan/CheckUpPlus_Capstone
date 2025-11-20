import 'package:checkupplus_capstone/wrapper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/user_service.dart'; 

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _name = TextEditingController();
  
  // Added UserService instance
  final UserService _userService = UserService();

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _name.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (_email.text.isEmpty || _password.text.isEmpty || _name.text.isEmpty) {
      _showSnackBar('Please fill in all fields.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Step 1: Create Firebase Auth account
      print('🔄 Creating Firebase Auth account...');
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _email.text.trim(),
        password: _password.text,
      );

      final user = userCredential.user;
      if (user == null) {
        throw Exception('User creation failed - no user returned');
      }
      print('✅ Firebase Auth account created: ${user.uid}');

      // Step 2: Split name into first and last name
      final nameParts = _name.text.trim().split(' ');
      final firstName = nameParts.first;
      final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

      // Step 3: Create Firestore user profile
      print('🔄 Creating Firestore user profile...');
      await _userService.createUserProfile(
        uid: user.uid,
        email: _email.text.trim(),
        firstName: firstName,
        lastName: lastName,
      );
      print('✅ Firestore user profile created');

      // Step 4: Send email verification
      print('🔄 Sending email verification...');
      await user.sendEmailVerification();
      print('✅ Email verification sent');

      // Step 5: Show success and navigate
      _showSnackBar('Sign up successful! Please verify your email.');
      Get.offAll(() => const Wrapper());
      
    } on FirebaseAuthException catch (e) {
      print('❌ Firebase Auth Error: ${e.code} - ${e.message}');
      
      String errorMessage;
      switch (e.code) {
        case 'weak-password':
          errorMessage = 'Password is too weak. Use at least 6 characters.';
          break;
        case 'email-already-in-use':
          errorMessage = 'An account already exists for that email.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is invalid.';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Email/password accounts are not enabled.';
          break;
        default:
          errorMessage = e.message ?? 'Authentication error occurred.';
      }
      _showSnackBar(errorMessage);
      
    } catch (e) {
      print('❌ Signup Error: $e');
      _showSnackBar('Unexpected error: $e');
      
      // If Firestore creation failed but Auth succeeded,
      // profile will be created on next login
      print('⚠️ If Auth succeeded but Firestore failed, profile will be created on next login');
      
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 80),
            _buildLogo(),
            const SizedBox(height: 48),
            _buildNameField(),
            const SizedBox(height: 24),
            _buildEmailField(),
            const SizedBox(height: 24),
            _buildPasswordField(),
            const SizedBox(height: 24),
            _buildSignUpButton(),
            const SizedBox(height: 24),
            _buildDivider(),
            const SizedBox(height: 24),
            _buildSocialButtons(),
            const SizedBox(height: 48),
            _buildLoginText(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() => Column(
    children: [
      Image.asset('assets/logos/CheckupPlusLogo.png', height: 70),
      const SizedBox(height: 16),
      const Text(
        'Sign Up',
        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      const Text(
        'Create a new account to get started',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16, color: Colors.grey),
      ),
    ],
  );

  Widget _buildNameField() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Name', style: TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      TextField(
        controller: _name,
        keyboardType: TextInputType.text,
        decoration: _inputDecoration('Enter your full name'),
      ),
    ],
  );

  Widget _buildEmailField() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Email', style: TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      TextField(
        controller: _email,
        keyboardType: TextInputType.emailAddress,
        decoration: _inputDecoration('example@gmail.com'),
      ),
    ],
  );

  Widget _buildPasswordField() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Password', style: TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      TextField(
        controller: _password,
        obscureText: !_isPasswordVisible,
        decoration: _inputDecoration('*********').copyWith(
          suffixIcon: IconButton(
            icon: Icon(
              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            ),
            onPressed: () {
              setState(() => _isPasswordVisible = !_isPasswordVisible);
            },
          ),
        ),
      ),
    ],
  );

  Widget _buildSignUpButton() => ElevatedButton(
    onPressed: _isLoading ? null : _signUp,
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.blue,
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    child: _isLoading
        ? const CircularProgressIndicator(color: Colors.white)
        : const Text(
            'Sign Up',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
  );

  Widget _buildDivider() => const Row(
    children: [
      Expanded(child: Divider(color: Colors.grey)),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Text('Or sign up with'),
      ),
      Expanded(child: Divider(color: Colors.grey)),
    ],
  );

  Widget _buildSocialButtons() => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      _buildSocialButton('assets/images/apple_logo.png'),
      const SizedBox(width: 24),
      _buildSocialButton('assets/images/google_logo.png'),
      const SizedBox(width: 24),
      _buildSocialButton('assets/images/facebook_logo.png'),
    ],
  );

  Widget _buildSocialButton(String imagePath) => GestureDetector(
    onTap: () {
      // TODO: Implement social login
    },
    child: Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Center(child: Image.asset(imagePath, height: 30)),
    ),
  );

  Widget _buildLoginText() => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Text("Already have an account? "),
      GestureDetector(
        onTap: () {
          Get.back();
        },
        child: const Text(
          'Login',
          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
        ),
      ),
    ],
  );

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: Colors.grey[200],
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  );
}
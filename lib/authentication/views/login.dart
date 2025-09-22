import 'package:checkupplus_capstone/forgot.dart';
import 'package:checkupplus_capstone/signup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (_email.text.isEmpty || _password.text.isEmpty) {
      _showSnackBar('Please enter both email and password.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _email.text.trim(),
        password: _password.text,
      );
      _showSnackBar('Login successful!');
    } on FirebaseAuthException catch (e) {
      _showSnackBar(e.message ?? 'Authentication error occurred.');
    } catch (e) {
      _showSnackBar('Unexpected error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
            _buildEmailField(),
            const SizedBox(height: 24),
            _buildPasswordField(),
            const SizedBox(height: 12),
            _buildForgotPassword(),
            const SizedBox(height: 24),
            _buildSignInButton(),
            const SizedBox(height: 24),
            _buildDivider(),
            const SizedBox(height: 24),
            _buildSocialButtons(),
            const SizedBox(height: 48),
            _buildSignupText(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() => Column(
    children: [
      Image.asset('assets/images/logo.png', height: 70),
      const SizedBox(height: 16),
      const Text(
        'Sign In',
        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      const Text(
        'Hi! Welcome back, you\'ve been missed',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16, color: Colors.grey),
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

  Widget _buildForgotPassword() => Align(
    alignment: Alignment.centerRight,
    child: TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Forgot()),
        );
      },
      child: const Text(
        'Forgot Password?',
        style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600),
      ),
    ),
  );

  Widget _buildSignInButton() => ElevatedButton(
    onPressed: _isLoading ? null : _signIn,
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.blue,
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    child: _isLoading
        ? const CircularProgressIndicator(color: Colors.white)
        : const Text(
            'Sign In',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
  );

  Widget _buildDivider() => const Row(
    children: [
      Expanded(child: Divider(color: Colors.grey)),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Text('Or sign in with'),
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

  Widget _buildSignupText() => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Text("Don't have an account? "),
      GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Signup()),
          );
        },
        child: const Text(
          'Sign Up',
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

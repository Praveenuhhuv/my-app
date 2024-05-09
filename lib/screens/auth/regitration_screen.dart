import 'package:flutter/material.dart';
import 'package:PicBlockChain/helper/dialogs.dart';
import 'package:PicBlockChain/api/apis.dart';
import 'package:PicBlockChain/main.dart';
import 'package:PicBlockChain/screens/auth/login_screen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  bool _isAnimate = false;
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _isAnimate = true;
      });
    });
  }

  _handleRegistration() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    if (email.isNotEmpty && password.isNotEmpty && confirmPassword.isNotEmpty) {
      if (password == confirmPassword) {
        if (password.length < 6) {
          Dialogs.showSnackbar(
              context, 'Password must be at least 6 characters long');
        } else {
          Dialogs.showProgressBar(context); //show progress bar
          try {
            await APIs.auth.createUserWithEmailAndPassword(
                email: email, password: password);
            Navigator.pop(context); //hide progress bar

            Dialogs.showSnackbar(context, 'User created successfully');

            // Navigate back to the login screen
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const LoginScreen()));
          } catch (e) {
            Navigator.pop(context); //hide progress bar
            Dialogs.showSnackbar(context, 'Error creating user: $e');
          }
        }
      } else {
        Dialogs.showSnackbar(context, 'Passwords do not match');
      }
    } else {
      Dialogs.showSnackbar(
          context, 'Please enter email, password, and confirm password');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registration'),
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          AnimatedPositioned(
            top: _isAnimate ? mq.height * .15 : -mq.height * .5,
            right: mq.width * .25,
            width: mq.width * .5,
            duration: const Duration(seconds: 1),
            child: Image.asset('images/icon.png'),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                    ),
                  ),
                  obscureText: !_isPasswordVisible,
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordVisible =
                              !_isConfirmPasswordVisible;
                        });
                      },
                      icon: Icon(
                        _isConfirmPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                    ),
                  ),
                  obscureText: !_isConfirmPasswordVisible,
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _handleRegistration,
                  child: Text('Register'),
                ),
                SizedBox(height: 8),
                Text(
                  'Note: You must use a password you will never forget. Once saved, you cannot change it.',
                  style: TextStyle(
                    color: Colors.red,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

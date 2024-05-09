import 'package:PicBlockChain/screens/auth/regitration_screen.dart';
import 'package:flutter/material.dart';
import 'package:PicBlockChain/helper/dialogs.dart';
import 'package:PicBlockChain/api/apis.dart';
import 'package:PicBlockChain/main.dart';
import 'package:PicBlockChain/screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isAnimate = false;
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _isAnimate = true;
      });
    });
  }

  _handleLogin() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isNotEmpty && password.isNotEmpty) {
      Dialogs.showProgressBar(context); //show progress bar

      try {
        await APIs.auth
            .signInWithEmailAndPassword(email: email, password: password);
        Navigator.pop(context); //hide progress bar

        if (await APIs.userExists()) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const HomeScreen()));
        } else {
          Dialogs.showSnackbar(context, 'User not found.');
        }
      } catch (e) {
        Navigator.pop(context); //hide progress bar
        Dialogs.showSnackbar(context, 'Invalid email or password');
      }
    } else {
      Dialogs.showSnackbar(context, 'Please enter email and password');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome to PicBlockChain'),
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
                ElevatedButton(
                  onPressed: _handleLogin,
                  child: Text('Login'),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to the registration screen
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const RegistrationScreen()));
                  },
                  child: Text('New user? Register here'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

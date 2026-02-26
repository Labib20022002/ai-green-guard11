import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF7DAE9E),
              Color(0xFF0F4C45),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Spacer(),

              /// LOGIN BUTTON
              SizedBox(
                width: 220,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0A2F2A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LoginScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    "Login",
                    style: TextStyle(
                      fontSize: 16,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// SIGN UP BUTTON
              SizedBox(
                width: 220,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0A2F2A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SignUpScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    "Sign up",
                    style: TextStyle(
                      fontSize: 16,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}
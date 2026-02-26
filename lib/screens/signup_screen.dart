import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _obscure = true;

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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Back Button
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                ),

                const SizedBox(height: 40),

                /// NAME
                _inputField(
                  hint: "Azmyeen Al Labib",
                  obscure: false,
                ),

                const SizedBox(height: 24),

                /// EMAIL
                _inputField(
                  hint: "azmyeen@gmail.com",
                  obscure: false,
                ),

                const SizedBox(height: 24),

                /// PASSWORD
                _inputField(
                  hint: "********",
                  obscure: _obscure,
                  suffix: IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility_off : Icons.visibility,
                      color: Colors.white70,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscure = !_obscure;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 40),

                /// SIGN UP BUTTON
                Center(
                  child: SizedBox(
                    width: 200,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0A2F2A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () {
                        // UI only for now
                      },
                      child: const Text(
                        "SIGN UP",
                        style: TextStyle(
                          letterSpacing: 1,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                /// OR SIGN UP WITH
                Row(
                  children: const [
                    Expanded(child: Divider(color: Colors.white38)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        "Or Sign Up with",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.white38)),
                  ],
                ),

                const SizedBox(height: 20),

                /// GOOGLE BUTTON
                Center(
                  child: SizedBox(
                    width: 200,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0A2F2A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () {},
                      child: Image.network(
                        "https://upload.wikimedia.org/wikipedia/commons/0/09/IOS_Google_icon.png",
                        height: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Reusable input field (same as login)
  Widget _inputField({
    required String hint,
    required bool obscure,
    Widget? suffix,
  }) {
    return TextField(
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54),
        suffixIcon: suffix,
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.yellowAccent),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.yellowAccent, width: 2),
        ),
      ),
    );
  }
}
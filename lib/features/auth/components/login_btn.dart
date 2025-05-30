import 'package:flutter/material.dart';

class LoginBtn extends StatelessWidget {
  final VoidCallback onPressed;


  const LoginBtn({
    super.key,
    required this.onPressed,

  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        shape: null,
      ),
      child: const Text('Login', style: TextStyle(fontSize: 18)),
    );
  }
}

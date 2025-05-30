import 'package:flutter/material.dart';

class LoginTxtField extends StatelessWidget {
  final TextEditingController txtController;
  final String labelTxt;
  final Icon icn;
  final bool secureTxt;

  const LoginTxtField({
    super.key,
    required this.txtController,
    required this.labelTxt,
    required this.icn,
    required this.secureTxt,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: txtController,
      obscureText: secureTxt,
      decoration: InputDecoration(
        labelText: labelTxt,
        labelStyle: TextStyle(
          color: Colors.teal,
        ),
        prefixIcon: icn,
        prefixIconColor: Colors.teal,
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.teal),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.teal),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your $labelTxt';
        }
        return null;
      },
    );
  }
}

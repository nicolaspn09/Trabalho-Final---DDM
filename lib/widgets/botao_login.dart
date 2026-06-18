import 'package:flutter/material.dart';

class BotaoLogin extends StatelessWidget {
  final String texto;
  final VoidCallback onPressed;

  const BotaoLogin({
    super.key,
    required this.texto,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: 30,
          vertical: 10,
        ),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Text(
        texto,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}
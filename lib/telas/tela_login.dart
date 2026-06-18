import '../widgets/form_login.dart';
import 'package:flutter/material.dart';

class TelaLogin extends StatelessWidget {
  const TelaLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 10, top: 80),
                child: const Icon(
                  Icons.monetization_on_outlined,
                  size: 80,
                  color: Colors.teal,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 20, top: 10),
                child: const Text(
                  "Controle Financeiro",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
              ),
              const FormLogin(),
            ],
          ),
        ),
      ),
    );
  }
}

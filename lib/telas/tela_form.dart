import 'package:flutter/material.dart';

class TelaForm extends StatelessWidget {
  final String titulo;
  
  const TelaForm({super.key, required this.titulo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(titulo),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          'Formulário de Cadastro',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ),
    );
  }
}

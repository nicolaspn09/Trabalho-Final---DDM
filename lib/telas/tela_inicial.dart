import '../providers/auth_provider.dart';
import 'tela_lista.dart';
import 'tela_login.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TelaInicial extends StatelessWidget {
  const TelaInicial({super.key});

  @override
  Widget build(BuildContext context) {
    AuthProvider authProvider = Provider.of<AuthProvider>(context);
    return authProvider.estaAutenticado
        ? const TelaLista(titulo: 'Controle Financeiro')
        : const TelaLogin();
  }
}

import '../telas/tela_inicial.dart';
import '../providers/auth_provider.dart';
import '../providers/transacao_provider.dart';
import '../util/rotas.dart';
import '../telas/tela_form.dart';
import '../telas/tela_detalhes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => TransacaoProvider()),
      ],
      child: MaterialApp(
        title: 'Gestão Financeira',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          useMaterial3: true,
        ),
        routes: {
          Rotas.telaInicial: (context) => const TelaInicial(),
          Rotas.telaDetalhes: (context) => const TelaDetalhes(titulo: "Detalhes da Transação"),
          Rotas.telaForm: (context) => const TelaForm(titulo: 'Nova Transação'),
        },
      ),
    );
  }
}

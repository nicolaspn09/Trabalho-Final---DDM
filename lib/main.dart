import '../telas/tela_inicial.dart';
import '../providers/auth_provider.dart';
import '../providers/transacao_provider.dart';
import '../util/rotas.dart';
import '../telas/tela_form.dart';
import '../telas/tela_detalhes.dart';
import '../telas/tela_dashboard.dart';
import '../telas/tela_alertas.dart';
import '../telas/tela_chat.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

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
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF38BDF8),
            brightness: Brightness.dark,
            primary: const Color(0xFF38BDF8),
            secondary: const Color(0xFF10B981),
            surface: const Color(0xFF0B121F),
            background: const Color(0xFF0B121F),
          ),
          textTheme: GoogleFonts.outfitTextTheme(Theme.of(context).textTheme).apply(
            bodyColor: Colors.white,
            displayColor: Colors.white,
          ),
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFF0B121F),
        ),
        routes: {
          Rotas.telaInicial: (context) => const TelaInicial(),
          Rotas.telaDetalhes: (context) => const TelaDetalhes(titulo: "Detalhes da Transação"),
          Rotas.telaForm: (context) => const TelaForm(titulo: 'Nova Transação'),
          Rotas.telaDashboard: (context) => const TelaDashboard(),
          Rotas.telaAlertas: (context) => const TelaAlertas(),
          Rotas.telaChat: (context) => const TelaChat(),
        },
      ),
    );
  }
}

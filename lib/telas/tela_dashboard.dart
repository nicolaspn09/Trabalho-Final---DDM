import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/transacao_provider.dart';
import '../providers/auth_provider.dart';
import '../util/rotas.dart';
import '../util/avatar_util.dart';
import 'dart:ui';

class TelaDashboard extends StatefulWidget {
  const TelaDashboard({super.key});

  @override
  State<TelaDashboard> createState() => _TelaDashboardState();
}

class _TelaDashboardState extends State<TelaDashboard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.userId ?? '';
      if (userId.isNotEmpty) {
        Provider.of<TransacaoProvider>(context, listen: false).carregarTransacoes(userId);
      }
    });
    
    _animationController = AnimationController(vsync: this, duration: const Duration(seconds: 15))..repeat(reverse: true);
    _animation = Tween<double>(begin: -0.1, end: 0.1).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOutSine));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  IconData _obterIconeCategoria(String categoria) {
    final catLower = categoria.toLowerCase();
    if (catLower.contains('aliment') || catLower.contains('food') || catLower.contains('mercado') || catLower.contains('supermercado')) {
      return Icons.shopping_cart;
    } else if (catLower.contains('transporte') || catLower.contains('combust') || catLower.contains('gas') || catLower.contains('fuel') || catLower.contains('posto')) {
      return Icons.local_gas_station;
    } else if (catLower.contains('pet') || catLower.contains('anim')) {
      return Icons.pets;
    } else if (catLower.contains('saud') || catLower.contains('health') || catLower.contains('hospital') || catLower.contains('farmacia')) {
      return Icons.medical_services;
    } else if (catLower.contains('lazer') || catLower.contains('game') || catLower.contains('show')) {
      return Icons.sports_esports;
    }
    return Icons.payment;
  }



  @override
  Widget build(BuildContext context) {
    final transacaoProvider = Provider.of<TransacaoProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final transacoes = transacaoProvider.transacoes;
    
    // Pegar recentes (últimas 3)
    final recentes = List.from(transacoes)..sort((a, b) => b.data.compareTo(a.data));
    final limitRecentes = recentes.take(3).toList();

    // Cálculos de categorias
    final Map<String, double> gastosPorCategoria = {};
    for (var t in transacoes.where((tx) => tx.tipo == 'despesa')) {
      gastosPorCategoria.update(t.categoria, (val) => val + t.valor, ifAbsent: () => t.valor);
    }
    
    final categoriasOrdenadas = gastosPorCategoria.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
      
    final double totalGastos = transacaoProvider.totalDespesas > 0 ? transacaoProvider.totalDespesas : 1;

    // Cores das categorias
    final List<Color> catColors = [
      const Color(0xFF10B981),
      const Color(0xFFF97316),
      const Color(0xFFEAB308),
      const Color(0xFF8B5CF6)
    ];

    return Scaffold(
      backgroundColor: Colors.transparent, 
      body: Stack(
        children: [
          // Imagem Animada de Fundo
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return FractionalTranslation(
                  translation: Offset(_animation.value, _animation.value * 0.5),
                  child: Transform.scale(
                    scale: 1.25,
                    child: Image.asset('assets/bg_home.png', fit: BoxFit.cover),
                  ),
                );
              },
            ),
          ),
          
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
              child: Container(color: Colors.transparent),
            ),
          ),
          
          // Escurecimento em degradê (Video Overlay)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent, 
                    Colors.black.withOpacity(0.6), 
                    Colors.black, // Escuro total atrás dos cards
                  ],
                  stops: const [0.0, 0.5, 0.9],
                ),
              ),
            ),
          ),

          // Fundo suave de gradiente verde no topo
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 300,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF10B981).withOpacity(0.15),
                    Colors.black.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Card (Glassmorphism)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Avatar e Nome
                                Row(
                                  children: [
                                    Transform.scale(
                                      scale: 0.75,
                                      child: AvatarUtil.construirAvatar(authProvider.avatarId),
                                    ),
                                    const SizedBox(width: 8),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Olá,', style: TextStyle(color: Color(0xFF7A7A7A), fontSize: 12)),
                                        Text(
                                          authProvider.nomeUsuario,
                                          style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                // Saldo do outro lado
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'R\$ ${transacaoProvider.saldoTotal.toStringAsFixed(2).replaceAll('.', ',')}',
                                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -1),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text('Rend +R\$ 12,34', style: TextStyle(color: Color(0xFF10B981), fontSize: 12, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // LineChart Mini
                            SizedBox(
                              height: 40,
                              width: double.infinity,
                              child: LineChart(
                                LineChartData(
                                  gridData: const FlGridData(show: false),
                                  titlesData: const FlTitlesData(show: false),
                                  borderData: FlBorderData(show: false),
                                  lineBarsData: [
                                    LineChartBarData(
                                      spots: const [
                                        FlSpot(0, 1),
                                        FlSpot(1, 1.5),
                                        FlSpot(2, 1.4),
                                        FlSpot(3, 3.4),
                                        FlSpot(4, 2),
                                        FlSpot(5, 2.2),
                                        FlSpot(6, 1.8),
                                        FlSpot(7, 3),
                                      ],
                                      isCurved: true,
                                      color: const Color(0xFF10B981),
                                      barWidth: 2.5,
                                      isStrokeCapRound: true,
                                      dotData: const FlDotData(show: false),
                                      belowBarData: BarAreaData(
                                        show: true,
                                        gradient: LinearGradient(
                                          colors: [
                                            const Color(0xFF10B981).withOpacity(0.3),
                                            const Color(0xFF10B981).withOpacity(0.0),
                                          ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 180), // Espaço grande para ver o vídeo

                  // Card "Gastos por categoria" (Glassmorphism)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08), // Efeito vidro claro
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
                        ),
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Gastos por categoria • este mês', style: TextStyle(color: Color(0xFF7A7A7A), fontSize: 14)),
                            const Icon(Icons.chevron_right, color: Color(0xFF7A7A7A)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'R\$ ${transacaoProvider.totalDespesas.toStringAsFixed(2).replaceAll('.', ',')}',
                          style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 24),

                        // Barra segmentada única
                        if (categoriasOrdenadas.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: SizedBox(
                              height: 12,
                              child: Row(
                                children: categoriasOrdenadas.asMap().entries.map((entry) {
                                  final idx = entry.key;
                                  final cat = entry.value;
                                  final flex = ((cat.value / totalGastos) * 100).toInt();
                                  final color = catColors[idx % catColors.length];
                                  
                                  return Expanded(
                                    flex: flex == 0 ? 1 : flex,
                                    child: Container(
                                      margin: EdgeInsets.only(right: idx < categoriasOrdenadas.length - 1 ? 4 : 0),
                                      decoration: BoxDecoration(
                                        color: color,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        
                        const SizedBox(height: 24),
                        
                        // Lista de Categorias
                        if (categoriasOrdenadas.isEmpty)
                          const Text('Nenhum gasto.', style: TextStyle(color: Color(0xFF7A7A7A)))
                        else
                          ...categoriasOrdenadas.asMap().entries.map((entry) {
                            final idx = entry.key;
                            final cat = entry.value;
                            final color = catColors[idx % catColors.length];
                            final percentage = ((cat.value / totalGastos) * 100).toStringAsFixed(0);

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: Row(
                                children: [
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: color.withOpacity(0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(_obterIconeCategoria(cat.key), color: color, size: 14),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(cat.key, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                                  ),
                                  Text('$percentage%', style: const TextStyle(color: Color(0xFF7A7A7A), fontSize: 14)),
                                  const SizedBox(width: 12),
                                  Text('R\$ ${cat.value.toStringAsFixed(2).replaceAll('.', ',')}', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            );
                          }).toList(),
                      ],
                    ), // Fecha Column do Card
                  ), // Fecha Container
                ), // Fecha BackdropFilter
              ), // Fecha ClipRRect
              const SizedBox(height: 24),

                  // Transações Recentes Card (Glassmorphism)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08), // Efeito vidro claro
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
                        ),
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Transações Recentes', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        if (limitRecentes.isEmpty)
                          const Text('Nenhuma transação.', style: TextStyle(color: Color(0xFF7A7A7A)))
                        else
                          ...limitRecentes.map((tx) {
                            final isReceita = tx.tipo == 'receita';
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pushNamed(Rotas.telaDetalhes, arguments: tx);
                                },
                                child: Container(
                                  color: Colors.transparent, // Permite clicar em todo o espaço
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: const BoxDecoration(color: Color(0xFF1F1F1F), shape: BoxShape.circle),
                                        child: Icon(
                                          isReceita ? Icons.arrow_downward : Icons.arrow_upward, 
                                          color: isReceita ? const Color(0xFF10B981) : const Color(0xFFFF5C5C)
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(tx.titulo, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                            Text(tx.categoria, style: const TextStyle(color: Color(0xFF7A7A7A), fontSize: 14)),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        '${isReceita ? '' : '-'}R\$ ${tx.valor.toStringAsFixed(2).replaceAll('.', ',')}',
                                        style: TextStyle(color: isReceita ? Colors.white : const Color(0xFFFF5C5C), fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                      ],
                    ),
                   ),
                  ),
                 ),
                 const SizedBox(height: 100), // Espaço pro dock
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

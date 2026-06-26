import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:provider/provider.dart';
import '../providers/transacao_provider.dart';
import '../util/rotas.dart';

class GraficoBalancoPainter extends CustomPainter {
  final double receitas;
  final double despesas;

  GraficoBalancoPainter(this.receitas, this.despesas);

  @override
  void paint(Canvas canvas, Size size) {
    final double total = receitas + despesas;
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    final paintFundo = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20;

    canvas.drawArc(rect, 0, 2 * math.pi, false, paintFundo);

    if (total == 0) return;

    final double anguloReceita = (receitas / total) * 2 * math.pi;
    final double anguloDespesa = (despesas / total) * 2 * math.pi;

    final paintReceita = Paint()
      ..color = const Color(0xFF10B981)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;

    final paintDespesa = Paint()
      ..color = const Color(0xFFEF4444)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;

    // Desenha receitas (verde) começando do topo (-pi/2)
    canvas.drawArc(rect, -math.pi / 2, anguloReceita, false, paintReceita);
    // Desenha despesas (vermelho) começando onde a receita termina
    canvas.drawArc(rect, -math.pi / 2 + anguloReceita, anguloDespesa, false, paintDespesa);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class TelaDashboard extends StatelessWidget {
  const TelaDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final transacaoProvider = Provider.of<TransacaoProvider>(context);
    final transacoes = transacaoProvider.transacoes;
    final alertasNaoLidos = transacaoProvider.alertasNaoLidos;
    
    final totalReceitas = transacaoProvider.totalReceitas;
    final totalDespesas = transacaoProvider.totalDespesas;

    final Map<String, double> gastosPorCategoria = {};
    for (var t in transacoes.where((tx) => tx.tipo == 'despesa')) {
      gastosPorCategoria.update(t.categoria, (val) => val + t.valor, ifAbsent: () => t.valor);
    }
    
    final categoriasOrdenadas = gastosPorCategoria.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
      
    final double maxGasto = categoriasOrdenadas.isNotEmpty ? categoriasOrdenadas.first.value : 1.0;

    return Scaffold(
      backgroundColor: const Color(0xFF0B121F),
      appBar: AppBar(
        title: const Text('Análise Financeira', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1E293B),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Seção do Gráfico de Rosca (Balanço Geral)
              const Text(
                'Balanço Geral',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Center(
                child: SizedBox(
                  width: 200,
                  height: 200,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(200, 200),
                        painter: GraficoBalancoPainter(totalReceitas, totalDespesas),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Saldo', style: TextStyle(color: Colors.grey, fontSize: 14)),
                          Text(
                            'R\$ ${transacaoProvider.saldoTotal.toStringAsFixed(2).replaceAll('.', ',')}',
                            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              // Legendas do Gráfico
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(16)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(width: 12, height: 12, decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle)),
                              const SizedBox(width: 8),
                              const Text('Receitas', style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('R\$ ${totalReceitas.toStringAsFixed(2).replaceAll('.', ',')}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(16)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(width: 12, height: 12, decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle)),
                              const SizedBox(width: 8),
                              const Text('Despesas', style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('R\$ ${totalDespesas.toStringAsFixed(2).replaceAll('.', ',')}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              
              // Seção de Despesas por Categoria (Barras Horizontais)
              const Text(
                'Despesas por Categoria',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              if (categoriasOrdenadas.isEmpty)
                const Center(child: Text('Nenhuma despesa para analisar.', style: TextStyle(color: Colors.grey)))
              else
                ...categoriasOrdenadas.map((entry) {
                  final percent = entry.value / maxGasto;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(entry.key, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                            Text('R\$ ${entry.value.toStringAsFixed(2).replaceAll('.', ',')}', style: const TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold, fontSize: 15)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Stack(
                          children: [
                            Container(
                              height: 10,
                              decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(10)),
                            ),
                            FractionallySizedBox(
                              widthFactor: percent,
                              child: Container(
                                height: 10,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(colors: [Color(0xFFF43F5E), Color(0xFFEF4444)]),
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [BoxShadow(color: const Color(0xFFEF4444).withOpacity(0.5), blurRadius: 4)],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF1E293B),
        selectedItemColor: const Color(0xFF38BDF8),
        unselectedItemColor: Colors.grey,
        currentIndex: 1, // Dashboard ativo
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, Rotas.telaInicial);
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, Rotas.telaAlertas);
          }
        },
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          const BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Dashboard'),
          BottomNavigationBarItem(
            icon: alertasNaoLidos == 0 
                ? const Icon(Icons.notifications) 
                : Badge(
                    label: Text('$alertasNaoLidos'),
                    child: const Icon(Icons.notifications),
                  ),
            label: 'Alertas',
          ),
        ],
      ),
    );
  }
}

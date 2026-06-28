import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transacao_provider.dart';
import '../util/rotas.dart';

class TelaAlertas extends StatefulWidget {
  const TelaAlertas({super.key});

  @override
  State<TelaAlertas> createState() => _TelaAlertasState();
}

class _TelaAlertasState extends State<TelaAlertas> {
  final _limiteController = TextEditingController();
  String _tipoLimite = 'despesa';

  void _adicionarLimite(TransacaoProvider provider) {
    if (_limiteController.text.isEmpty) return;
    final valor = double.tryParse(_limiteController.text.replaceAll(',', '.')) ?? 0.0;
    if (valor <= 0) return;

    provider.adicionarLimite(_tipoLimite, valor);
    _limiteController.clear();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TransacaoProvider>(context, listen: false).marcarAlertasComoLidos();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransacaoProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      appBar: AppBar(
        title: const Text('Central de Alertas', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF000000),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Avisos Recentes',
                style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              if (provider.alertasGerados.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF171717),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'Nenhum alerta pendente',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              else
                ...provider.alertasGerados.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final alerta = entry.value;
                  final isReceita = alerta['tipo'] == 'receita';
                  final neonColor = isReceita ? const Color(0xFF10B981) : const Color(0xFFEF4444);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF171717),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: neonColor.withOpacity(0.2), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: neonColor.withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        )
                      ]
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: neonColor.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(isReceita ? Icons.arrow_upward : Icons.warning_amber_rounded, color: neonColor, size: 20),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(alerta['titulo'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                              const SizedBox(height: 4),
                              Text(alerta['time'], style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => provider.removerAlerta(idx),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black26,
                              borderRadius: BorderRadius.circular(8)
                            ),
                            child: const Icon(Icons.close, color: Colors.grey, size: 20),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              const SizedBox(height: 24),
              const Divider(color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'Configurar Limite de Gastos',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _tipoLimite = 'despesa'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: _tipoLimite == 'despesa' ? const Color(0xFFF97316) : const Color(0xFF171717),
                          borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), bottomLeft: Radius.circular(8)),
                          border: Border.all(color: const Color(0xFFF97316)),
                        ),
                        alignment: Alignment.center,
                        child: Text('Despesa', style: TextStyle(color: _tipoLimite == 'despesa' ? Colors.black : Colors.grey, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _tipoLimite = 'receita'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: _tipoLimite == 'receita' ? const Color(0xFFF97316) : const Color(0xFF171717),
                          borderRadius: const BorderRadius.only(topRight: Radius.circular(8), bottomRight: Radius.circular(8)),
                          border: Border.all(color: const Color(0xFFF97316)),
                        ),
                        alignment: Alignment.center,
                        child: Text('Receita', style: TextStyle(color: _tipoLimite == 'receita' ? Colors.black : Colors.grey, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _limiteController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Valor (R\$)",
                        hintStyle: const TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: const Color(0xFF171717),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _adicionarLimite(provider),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF97316),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Cadastrar', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'LIMITE ATIVOS',
                style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (provider.limitesAtivos.isEmpty)
                const Text('Nenhum limite configurado.', style: TextStyle(color: Colors.grey))
              else
                ...provider.limitesAtivos.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final lim = entry.value;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF171717),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${lim['tipo'] == 'receita' ? 'Receita' : 'Despesa'} > R\$ ${lim['valor'].toStringAsFixed(2).replaceAll('.', ',')}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        GestureDetector(
                          onTap: () => provider.removerLimite(idx),
                          child: const Icon(Icons.close, color: Colors.red, size: 20),
                        ),
                      ],
                    ),
                  );
                }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}

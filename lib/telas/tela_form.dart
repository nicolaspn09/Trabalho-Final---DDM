import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transacao.dart';
import '../providers/transacao_provider.dart';
import '../providers/auth_provider.dart';

class TelaForm extends StatefulWidget {
  final String titulo;
  
  const TelaForm({super.key, required this.titulo});

  @override
  State<TelaForm> createState() => _TelaFormState();
}

class _TelaFormState extends State<TelaForm> {
  final _tituloController = TextEditingController();
  final _valorController = TextEditingController();
  final _categoriaController = TextEditingController();
  String _tipo = 'despesa';

  void _salva() {
    if (_tituloController.text.isEmpty || _valorController.text.isEmpty) {
      return;
    }
    
    final valor = double.tryParse(_valorController.text.replaceAll(',', '.')) ?? 0.0;
    
    final transacao = Transacao(
      titulo: _tituloController.text,
      valor: valor,
      tipo: _tipo,
      categoria: _categoriaController.text.isEmpty ? 'Outros' : _categoriaController.text,
      data: DateTime.now().toIso8601String(),
    );

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final provider = Provider.of<TransacaoProvider>(context, listen: false);
    
    provider.addTransacao(transacao, authProvider.userId ?? '');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B121F), // Fundo principal escuro
      appBar: AppBar(
        title: Text(widget.titulo, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF1E293B),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Text(
                "Dados da Transação",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white) 
              ),
              const SizedBox(height: 20),
              TextField(
                style: const TextStyle(color: Colors.white, fontSize: 18),
                controller: _tituloController,
                decoration: InputDecoration(
                  labelText: "Título ou Descrição",
                  labelStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: const Color(0xFF1E293B), // Fundo do input
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFF38BDF8)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                style: const TextStyle(color: Colors.white, fontSize: 18),
                controller: _valorController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: "Valor (R\$)",
                  labelStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: const Color(0xFF1E293B),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFF38BDF8)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                style: const TextStyle(color: Colors.white, fontSize: 18),
                controller: _categoriaController,
                decoration: InputDecoration(
                  labelText: "Categoria (Ex: Food, Fuel, Saúde)",
                  labelStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: const Color(0xFF1E293B),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFF38BDF8)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _tipo,
                    isExpanded: true,
                    dropdownColor: const Color(0xFF1E293B),
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                    icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF38BDF8)),
                    items: const [
                      DropdownMenuItem(value: 'despesa', child: Text('Despesa (Saída)')),
                      DropdownMenuItem(value: 'receita', child: Text('Receita (Entrada)')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _tipo = val);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _salva,
        backgroundColor: const Color(0xFF38BDF8),
        icon: const Icon(Icons.save, color: Colors.white),
        label: const Text('Salvar Transação', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

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
  String _tipo = 'despesa';
  String _categoria = 'Outros';

  final List<String> _categorias = [
    'Casa',
    'Alimentação',
    'Transporte',
    'Saúde',
    'Educação',
    'Lazer',
    'Outros'
  ];

  void _salva() {
    if (_tituloController.text.isEmpty || _valorController.text.isEmpty) {
      return;
    }
    
    final valor = double.tryParse(_valorController.text.replaceAll(',', '.')) ?? 0.0;
    
    final transacao = Transacao(
      titulo: _tituloController.text,
      valor: valor,
      tipo: _tipo,
      categoria: _categoria,
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
      backgroundColor: const Color(0xFF000000), // Fundo preto puro Nubank Dark
      appBar: AppBar(
        title: Text(widget.titulo, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF000000),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Qual é o valor?",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                    controller: _valorController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      prefixText: "R\$ ",
                      prefixStyle: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                      hintText: "0,00",
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 36, fontWeight: FontWeight.bold),
                      border: InputBorder.none,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Tipo Selector
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _tipo = 'despesa'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: _tipo == 'despesa'
                                  ? const Color(0xFF171717)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: _tipo == 'despesa'
                                    ? const Color(0xFFEF4444)
                                    : const Color(0xFF171717),
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'Despesa',
                                style: TextStyle(
                                  color: _tipo == 'despesa'
                                      ? const Color(0xFFEF4444)
                                      : Colors.grey,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _tipo = 'receita'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: _tipo == 'receita'
                                  ? const Color(0xFF171717)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: _tipo == 'receita'
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFF171717),
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'Receita',
                                style: TextStyle(
                                  color: _tipo == 'receita'
                                      ? const Color(0xFF10B981)
                                      : Colors.grey,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  const Text("Descrição", style: TextStyle(color: Colors.grey, fontSize: 14)),
                  const SizedBox(height: 8),
                  TextField(
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    controller: _tituloController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF171717),
                      hintText: "Ex: Compras no mercado",
                      hintStyle: const TextStyle(color: Colors.grey),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFF97316), width: 1.5), // Borda verde-limão ao focar
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text("Categoria", style: TextStyle(color: Colors.grey, fontSize: 14)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _categoria,
                    dropdownColor: const Color(0xFF171717),
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF171717),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFF97316), width: 1.5),
                      ),
                    ),
                    items: _categorias.map((String categoria) {
                      return DropdownMenuItem<String>(
                        value: categoria,
                        child: Text(categoria),
                      );
                    }).toList(),
                    onChanged: (String? novaCategoria) {
                      if (novaCategoria != null) {
                        setState(() {
                          _categoria = novaCategoria;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          
          // Botão inferior fixo
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Color(0xFF000000),
            ),
            child: ElevatedButton(
              onPressed: _salva,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF97316), // Verde-limão
                foregroundColor: Colors.black, // Texto preto
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'SALVAR',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


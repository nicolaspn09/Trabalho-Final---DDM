import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transacao.dart';
import '../providers/transacao_provider.dart';

class TelaDetalhes extends StatefulWidget {
  const TelaDetalhes({super.key, required String titulo}); // Manter assinatura anterior por compatibilidade se necessário

  @override
  State<TelaDetalhes> createState() => _TelaDetalhesState();
}

class _TelaDetalhesState extends State<TelaDetalhes> {
  late Transacao _transacao;
  bool _isInit = true;

  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _valorController = TextEditingController();
  String? _categoriaSelecionada;

  final List<String> _categorias = [
    'Alimentação',
    'Transporte',
    'Saúde',
    'Lazer',
    'Pet',
    'Outros',
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      final args = ModalRoute.of(context)!.settings.arguments;
      if (args is Transacao) {
        _transacao = args;
        _tituloController.text = _transacao.titulo;
        // Se a categoria da transação não estiver na lista padrão, adicionamos
        if (!_categorias.contains(_transacao.categoria) && _transacao.categoria.isNotEmpty) {
          _categorias.add(_transacao.categoria);
        }
        _categoriaSelecionada = _transacao.categoria;
        _valorController.text = _transacao.valor.toStringAsFixed(2);
      }
      _isInit = false;
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _valorController.dispose();
    super.dispose();
  }

  Future<void> _excluirTransacao() async {
    final transacaoProvider = Provider.of<TransacaoProvider>(context, listen: false);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF171717),
        title: const Text('Excluir Transação', style: TextStyle(color: Colors.white)),
        content: const Text('Tem certeza que deseja excluir esta transação permanente?', style: TextStyle(color: Color(0xFF7A7A7A))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF5C5C)),
            child: const Text('Excluir', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        if (_transacao.id != null) {
          await transacaoProvider.removeTransacao(_transacao.id!);
          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Transação excluída com sucesso.'),
                backgroundColor: Color(0xFF10B981),
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao excluir: $e'),
              backgroundColor: const Color(0xFFFF5C5C),
            ),
          );
        }
      }
    }
  }

  Future<void> _salvarTransacao() async {
    if (!_formKey.currentState!.validate()) return;

    final transacaoProvider = Provider.of<TransacaoProvider>(context, listen: false);
    final novoValor = double.tryParse(_valorController.text.replaceAll(',', '.')) ?? _transacao.valor;

    try {
      if (_transacao.id != null) {
        await transacaoProvider.editarTransacao(
          id: _transacao.id!,
          novoTitulo: _tituloController.text.trim(),
          novaCategoria: _categoriaSelecionada ?? 'Outros',
          novoValor: novoValor,
        );
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Transação atualizada com sucesso.'),
              backgroundColor: Color(0xFF10B981),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar alterações: $e'),
            backgroundColor: const Color(0xFFFF5C5C),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isReceita = _transacao.tipo == 'receita';

    return Scaffold(
      backgroundColor: const Color(0xFF000000), // Fundo Preto Puro
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Detalhes da Transação', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          physics: const BouncingScrollPhysics(),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badge Tipo Transação
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isReceita ? const Color(0x1A10B981) : const Color(0x1AFF5C5C),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isReceita ? Icons.arrow_downward : Icons.arrow_upward,
                        color: isReceita ? const Color(0xFF10B981) : const Color(0xFFFF5C5C),
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isReceita ? 'RECEITA / ENTRADA' : 'DESPESA / SAÍDA',
                        style: TextStyle(
                          color: isReceita ? const Color(0xFF10B981) : const Color(0xFFFF5C5C),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Campo Título
                const Text('Título', style: TextStyle(color: Color(0xFF7A7A7A), fontSize: 14)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _tituloController,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFF171717),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.all(18),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'O título não pode estar vazio';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Campo Valor
                const Text(r'Valor (R$)', style: TextStyle(color: Color(0xFF7A7A7A), fontSize: 14)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _valorController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFF171717),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.all(18),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Insira um valor válido';
                    }
                    if (double.tryParse(value.replaceAll(',', '.')) == null) {
                      return 'Formato de número inválido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Campo Categoria
                const Text('Categoria', style: TextStyle(color: Color(0xFF7A7A7A), fontSize: 14)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _categoriaSelecionada,
                  dropdownColor: const Color(0xFF171717),
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFF171717),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  ),
                  items: _categorias.map((String cat) {
                    return DropdownMenuItem<String>(
                      value: cat,
                      child: Text(cat),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _categoriaSelecionada = val;
                    });
                  },
                ),
                const SizedBox(height: 48),

                // Ações
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: OutlinedButton(
                          onPressed: _excluirTransacao,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFFF5C5C), width: 1.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                            foregroundColor: const Color(0xFFFF5C5C),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.delete_outline, size: 20),
                              SizedBox(width: 8),
                              Text('Excluir', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _salvarTransacao,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF97316), // Verde Limão
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                          ),
                          child: const Text('Salvar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../models/transacao.dart';

class TransacaoProvider with ChangeNotifier {
  final List<Transacao> _transacoes = [
    Transacao(
      id: '1',
      titulo: 'Salário mensal',
      valor: 2500.00,
      tipo: 'receita',
      data: '10/06/2026',
      categoria: 'Trabalho',
    ),
    Transacao(
      id: '2',
      titulo: 'Supermercado',
      valor: 350.50,
      tipo: 'despesa',
      data: '12/06/2026',
      categoria: 'Alimentação',
    ),
    Transacao(
      id: '3',
      titulo: 'Mensalidade da Faculdade',
      valor: 450.00,
      tipo: 'despesa',
      data: '15/06/2026',
      categoria: 'Educação',
    ),
  ];

  List<Transacao> get transacoes => [..._transacoes];

  void addTransacao(Transacao transacao) {
    _transacoes.add(transacao);
    notifyListeners();
  }

  void removeTransacao(String id) {
    _transacoes.removeWhere((t) => t.id == id);
    notifyListeners();
  }
}

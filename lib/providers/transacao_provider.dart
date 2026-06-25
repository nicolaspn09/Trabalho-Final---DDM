import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/transacao.dart';

class TransacaoProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<Transacao> _transacoes = [];

  List<Transacao> get transacoes => [..._transacoes];

  double get saldoTotal {
    double total = 0.0;
    for (var t in _transacoes) {
      if (t.tipo == 'receita') {
        total += t.valor;
      } else {
        total -= t.valor;
      }
    }
    return total;
  }

  double get totalReceitas {
    return _transacoes
        .where((t) => t.tipo == 'receita')
        .fold(0.0, (sum, item) => sum + item.valor);
  }

  double get totalDespesas {
    return _transacoes
        .where((t) => t.tipo == 'despesa')
        .fold(0.0, (sum, item) => sum + item.valor);
  }

  Future<void> carregarTransacoes(String userId) async {
    try {
      final data = await _supabase
          .from('transacoes')
          .select()
          .eq('user_id', userId)
          .order('data', ascending: false);

      _transacoes = (data as List).map((map) {
        return Transacao.fromMap(map, map['id'].toString());
      }).toList();

      notifyListeners();
    } catch (e) {
      print('Erro ao carregar transações: $e');
    }
  }

  Future<void> addTransacao(Transacao transacao, String userId) async {
    try {
      final map = transacao.toMap();
      map.remove('id');
      map['user_id'] = userId;

      final insertedData = await _supabase
          .from('transacoes')
          .insert(map)
          .select()
          .single();

      final newTransacao = Transacao.fromMap(insertedData, insertedData['id'].toString());
      _transacoes.insert(0, newTransacao);
      notifyListeners();
    } catch (e) {
      print('Erro ao adicionar transação: $e');
      rethrow;
    }
  }

  Future<void> removeTransacao(String id) async {
    try {
      await _supabase.from('transacoes').delete().eq('id', id);
      _transacoes.removeWhere((t) => t.id == id);
      notifyListeners();
    } catch (e) {
      print('Erro ao remover transação: $e');
      rethrow;
    }
  }
}

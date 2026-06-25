import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../util/supabase_config.dart';
import '../models/transacao.dart';

class TransacaoProvider with ChangeNotifier {
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

  Map<String, String> get _headers => {
        'apikey': SupabaseConfig.anonKey,
        'Authorization': 'Bearer ${SupabaseConfig.anonKey}',
        'Content-Type': 'application/json',
        'Prefer': 'return=representation'
      };

  Future<void> carregarTransacoes(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('${SupabaseConfig.url}/rest/v1/transacoes?order=data.desc'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _transacoes = data.map((map) {
          return Transacao.fromMap(map as Map<String, dynamic>, map['id'].toString());
        }).toList();

        notifyListeners();
      }
    } catch (e) {
      print('Erro ao carregar transações: $e');
    }
  }

  Future<void> addTransacao(Transacao transacao, String userId) async {
    try {
      final map = transacao.toMap();
      map.remove('id');
      // Ignorando userId pois a tabela transacoes exige chave estrangeira no auth.users, e usamos public.perfis.

      final response = await http.post(
        Uri.parse('${SupabaseConfig.url}/rest/v1/transacoes'),
        headers: _headers,
        body: jsonEncode(map),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final List<dynamic> insertedData = jsonDecode(response.body);
        if (insertedData.isNotEmpty) {
          final newTransacao = Transacao.fromMap(insertedData[0] as Map<String, dynamic>, insertedData[0]['id'].toString());
          _transacoes.insert(0, newTransacao);
          notifyListeners();
        }
      }
    } catch (e) {
      print('Erro ao adicionar transação: $e');
      rethrow;
    }
  }

  Future<void> removeTransacao(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('${SupabaseConfig.url}/rest/v1/transacoes?id=eq.$id'),
        headers: _headers,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        _transacoes.removeWhere((t) => t.id == id);
        notifyListeners();
      }
    } catch (e) {
      print('Erro ao remover transação: $e');
      rethrow;
    }
  }
}

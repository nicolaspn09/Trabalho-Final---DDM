import 'package:flutter/material.dart';
import 'dart:math' as dart_math;
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
        Uri.parse('${SupabaseConfig.url}/rest/v1/transacoes?user_id=eq.$userId&order=data.desc'),
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

  // ALERTS E LIMITES
  List<Map<String, dynamic>> limitesAtivos = [];
  List<Map<String, dynamic>> alertasGerados = [];
  int alertasNaoLidos = 0;
  String? _currentUserId;

  Future<void> carregarDadosCompletos(String userId) async {
    _currentUserId = userId;
    await carregarTransacoes(userId);
    await _carregarLimites(userId);
    await _carregarAlertas(userId);
  }

  Future<void> _carregarLimites(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('${SupabaseConfig.url}/rest/v1/limites_alerta?user_id=eq.$userId&order=created_at.desc'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        limitesAtivos = List<Map<String, dynamic>>.from(jsonDecode(response.body));
        notifyListeners();
      }
    } catch (e) {
      print('Erro ao carregar limites: $e');
    }
  }

  Future<void> _carregarAlertas(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('${SupabaseConfig.url}/rest/v1/avisos_alerta?user_id=eq.$userId&order=created_at.desc'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final data = List<Map<String, dynamic>>.from(jsonDecode(response.body));
        alertasGerados = data.map((a) => {
          'id': a['id'],
          'titulo': a['titulo'],
          'tipo': a['tipo'],
          'lido': a['lido'],
          'time': 'Salvo',
        }).toList();
        alertasNaoLidos = alertasGerados.where((a) => a['lido'] == false).length;
        notifyListeners();
      }
    } catch (e) {
      print('Erro ao carregar alertas: $e');
    }
  }

  Future<void> adicionarLimite(String tipo, double valor) async {
    if (_currentUserId == null) return;
    try {
      final map = {'user_id': _currentUserId, 'tipo': tipo, 'valor': valor};
      final response = await http.post(
        Uri.parse('${SupabaseConfig.url}/rest/v1/limites_alerta'),
        headers: _headers,
        body: jsonEncode(map),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        await _carregarLimites(_currentUserId!);
      }
    } catch (e) {
      print('Erro ao adicionar limite: $e');
    }
  }

  Future<void> removerLimite(int index) async {
    final limit = limitesAtivos[index];
    final id = limit['id'];
    if (id == null) return;

    try {
      final response = await http.delete(
        Uri.parse('${SupabaseConfig.url}/rest/v1/limites_alerta?id=eq.$id'),
        headers: _headers,
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        limitesAtivos.removeAt(index);
        notifyListeners();
      }
    } catch (e) {
      print('Erro ao remover limite: $e');
    }
  }

  Future<void> _verificarLimites(Transacao tx) async {
    if (_currentUserId == null) return;
    bool novoAlerta = false;
    for (var lim in limitesAtivos) {
      if (tx.tipo == lim['tipo'] && tx.valor > (lim['valor'] as num).toDouble()) {
        final alertMap = {
          'user_id': _currentUserId,
          'titulo': 'Aviso: Lançamento de R\$ ${tx.valor.toStringAsFixed(2).replaceAll('.', ',')} ultrapassou o limite de R\$ ${(lim['valor'] as num).toDouble().toStringAsFixed(2).replaceAll('.', ',')}!',
          'tipo': tx.tipo,
          'lido': false
        };
        try {
          await http.post(
            Uri.parse('${SupabaseConfig.url}/rest/v1/avisos_alerta'),
            headers: _headers,
            body: jsonEncode(alertMap),
          );
          novoAlerta = true;
        } catch (e) {
          print('Erro ao gravar alerta: $e');
        }
      }
    }
    if (novoAlerta) await _carregarAlertas(_currentUserId!);
  }

  Future<void> removerAlerta(int index) async {
    final alert = alertasGerados[index];
    final id = alert['id'];
    if (id == null) return;
    
    try {
      final response = await http.delete(
        Uri.parse('${SupabaseConfig.url}/rest/v1/avisos_alerta?id=eq.$id'),
        headers: _headers,
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        alertasGerados.removeAt(index);
        alertasNaoLidos = alertasGerados.where((a) => a['lido'] == false).length;
        notifyListeners();
      }
    } catch (e) {
      print('Erro ao remover alerta: $e');
    }
  }

  Future<void> marcarAlertasComoLidos() async {
    if (alertasNaoLidos > 0 && _currentUserId != null) {
      try {
        final map = {'lido': true};
        await http.patch(
          Uri.parse('${SupabaseConfig.url}/rest/v1/avisos_alerta?user_id=eq.$_currentUserId&lido=eq.false'),
          headers: _headers,
          body: jsonEncode(map),
        );
        for (var a in alertasGerados) {
          a['lido'] = true;
        }
        alertasNaoLidos = 0;
        notifyListeners();
      } catch (e) {
        print('Erro ao marcar como lido: $e');
      }
    }
  }

  Future<void> addTransacao(Transacao transacao, String userId) async {
    try {
      final map = transacao.toMap();
      map.remove('id');
      map['user_id'] = userId;

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
          _verificarLimites(newTransacao); // Call here
          notifyListeners();
        }
      } else {
        print('Erro no insert: ${response.statusCode} - ${response.body}');
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

  Future<void> editarTransacao({
    required String id,
    required String novoTitulo,
    required String novaCategoria,
    required double novoValor,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse('${SupabaseConfig.url}/rest/v1/transacoes?id=eq.$id'),
        headers: _headers,
        body: jsonEncode({
          'titulo': novoTitulo,
          'categoria': novaCategoria,
          'valor': novoValor,
        }),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final index = _transacoes.indexWhere((t) => t.id == id);
        if (index != -1) {
          final oldTx = _transacoes[index];
          _transacoes[index] = Transacao(
            id: oldTx.id,
            titulo: novoTitulo,
            valor: novoValor,
            categoria: novaCategoria,
            tipo: oldTx.tipo,
            data: oldTx.data,
            icone: oldTx.icone,
            banco: oldTx.banco,
          );
          notifyListeners();
        }
      } else {
        print('Erro no patch: ${response.statusCode} - ${response.body}');
        throw Exception('Erro ao atualizar transação');
      }
    } catch (e) {
      print('Erro ao editar transação: $e');
      rethrow;
    }
  }
}

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../util/supabase_config.dart';

class AuthProvider extends ChangeNotifier {
  Map<String, dynamic>? _currentUser;

  bool get estaAutenticado => _currentUser != null;
  String? get email => _currentUser?['email'];
  String? get userId => _currentUser?['id']?.toString();
  String? get token => null;

  String get nomeUsuario {
    if (_currentUser == null) return '';
    final nome = _currentUser!['nome'];
    if (nome != null && nome.toString().isNotEmpty) {
      return nome.toString();
    }
    final userEmail = _currentUser!['email'] ?? '';
    return userEmail.split('@')[0];
  }

  Map<String, String> get _headers => {
        'apikey': SupabaseConfig.anonKey,
        'Authorization': 'Bearer ${SupabaseConfig.anonKey}',
        'Content-Type': 'application/json',
        'Prefer': 'return=representation'
      };

  Future<void> login(String email, String password) async {
    final response = await http.get(
      Uri.parse('${SupabaseConfig.url}/rest/v1/perfis?email=eq.$email'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao conectar ao banco');
    }

    final List<dynamic> data = jsonDecode(response.body);
    
    if (data.isEmpty) {
      throw Exception('Invalid login credentials');
    }
    
    final userRow = data[0];
    
    if (userRow['senha_hash'] != password) {
      throw Exception('Invalid login credentials');
    }
    
    _currentUser = userRow;
    notifyListeners();
  }

  Future<void> cadastra(String email, String password, {String? nome}) async {
    final checkResponse = await http.get(
      Uri.parse('${SupabaseConfig.url}/rest/v1/perfis?email=eq.$email'),
      headers: _headers,
    );

    final List<dynamic> existing = jsonDecode(checkResponse.body);
    if (existing.isNotEmpty) {
      throw Exception('User already exists');
    }
    
    final response = await http.post(
      Uri.parse('${SupabaseConfig.url}/rest/v1/perfis'),
      headers: _headers,
      body: jsonEncode({
        'nome': nome ?? email.split('@')[0],
        'email': email,
        'senha_hash': password,
      }),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final List<dynamic> inserted = jsonDecode(response.body);
      if (inserted.isNotEmpty) {
        _currentUser = inserted[0];
        notifyListeners();
      }
    } else {
      throw Exception('Erro ao cadastrar');
    }
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
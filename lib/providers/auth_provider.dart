import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  
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

  Future<void> login(String email, String password) async {
    print('AuthProvider: Iniciando login para \$email na tabela perfis');
    
    final data = await _supabase
        .from('perfis')
        .select()
        .eq('email', email)
        .limit(1);
    
    if (data.isEmpty) {
      throw Exception('Invalid login credentials');
    }
    
    final userRow = data[0];
    
    if (userRow['senha_hash'] != password) {
      throw Exception('Invalid login credentials');
    }
    
    _currentUser = userRow;
    print('AuthProvider: Login concluído. Usuário: \$_currentUser');
    notifyListeners();
  }

  Future<void> cadastra(String email, String password, {String? nome}) async {
    final existing = await _supabase.from('perfis').select().eq('email', email).limit(1);
    if (existing.isNotEmpty) {
      throw Exception('User already exists');
    }
    
    final inserted = await _supabase.from('perfis').insert({
      'email': email,
      'senha_hash': password,
      'nome': nome ?? email.split('@')[0],
    }).select().single();
    
    _currentUser = inserted;
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
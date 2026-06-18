import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AuthProvider extends ChangeNotifier {
  bool _estaAutenticado = false;
  String? _email;
  String? _token;
  String? _userId;

  bool get estaAutenticado => _estaAutenticado;
  String? get email => _email;
  String? get userId => _userId;
  String? get token => _token;

  final String _apiKey = "AIzaSyAGbSJzbM06Z6tahHshE5qgDrY58PazOkE";

  Future<void> login(String email, String password) async {
    final url = Uri.parse(
      'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$_apiKey',
    );

    final response = await http.post(
      url,
      body: jsonEncode({
        'email': email,
        'password': password,
        'returnSecureToken': true,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    final responseData = jsonDecode(response.body);

    if (responseData['error'] != null) {
      throw Exception(responseData['error']['message']);
    }

    _estaAutenticado = true;
    _token = responseData['idToken'];
    _email = responseData['email'];
    _userId = responseData['localId'];

    notifyListeners();
  }

  Future<void> cadastra(String email, String password) async {
    final url = Uri.parse(
      'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$_apiKey',
    );

    final response = await http.post(
      url,
      body: jsonEncode({
        'email': email,
        'password': password,
        'returnSecureToken': true,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    final responseData = jsonDecode(response.body);

    if (responseData['error'] != null) {
      throw Exception(responseData['error']['message']);
    }

    _estaAutenticado = true;
    _token = responseData['idToken'];
    _email = responseData['email'];
    _userId = responseData['localId'];

    notifyListeners();
  }

  void logout() {
    _estaAutenticado = false;
    _token = null;
    _email = null;
    _userId = null;
    notifyListeners();
  }
}
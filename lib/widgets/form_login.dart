import 'botao_login.dart';
import '../providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum Modo { cadastro, login }

class FormLogin extends StatefulWidget {
  const FormLogin({super.key});

  @override
  State<FormLogin> createState() => _FormLoginState();
}

class _FormLoginState extends State<FormLogin> {
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  Modo _modo = Modo.login;

  bool _ehLogin() => _modo == Modo.login;
  bool _ehCadastro() => _modo == Modo.cadastro;

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _trocaModoTela() {
    setState(() {
      if (_ehLogin()) {
        _modo = Modo.cadastro;
      } else {
        _modo = Modo.login;
      }
    });
  }

  Future<void> _submit() async {
    final valido = _formKey.currentState?.validate() ?? false;

    if (!valido) return;

    setState(() => _isLoading = true);

    AuthProvider authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      if (_ehLogin()) {
        await authProvider.login(
          _emailController.text.trim(),
          _passwordController.text,
        );
      } else {
        await authProvider.cadastra(
          _emailController.text.trim(),
          _passwordController.text,
          nome: _nomeController.text.trim(),
        );
      }
    } catch (error) {
      String mensagemErro = 'Erro na autenticação.';
      final errStr = error.toString();
      
      if (errStr.contains('User already exists')) {
        mensagemErro = 'Este e-mail já está cadastrado.';
      } else if (errStr.contains('Invalid login credentials')) {
        mensagemErro = 'E-mail ou senha incorretos.';
      } else if (errStr.contains('Password should be')) {
        mensagemErro = 'A senha deve conter no mínimo 6 caracteres.';
      } else {
        mensagemErro = errStr.replaceAll('AuthException: ', '').replaceAll('Exception: ', '');
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensagemErro),
          backgroundColor: Colors.red[700],
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1E293B), // Card escuro
      margin: const EdgeInsets.symmetric(horizontal: 20),
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(18),
        height: _ehLogin() ? 320 : 420,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (_ehCadastro())
                TextFormField(
                  controller: _nomeController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Nome Completo',
                    labelStyle: TextStyle(color: Colors.grey),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF38BDF8)),
                    ),
                    icon: Icon(Icons.person_outline, color: Color(0xFF38BDF8)),
                  ),
                  validator: (nomeVal) {
                    final nome = nomeVal ?? '';
                    if (nome.trim().isEmpty) {
                      return 'Informe seu nome.';
                    }
                    return null;
                  },
                ),
              TextFormField(
                controller: _emailController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'E-mail (login)',
                  labelStyle: TextStyle(color: Colors.grey),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF38BDF8)),
                  ),
                  icon: Icon(Icons.email_outlined, color: Color(0xFF38BDF8)),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (emailVal) {
                  final email = emailVal ?? '';
                  if (!email.contains('@')) {
                    return 'Informe um e-mail válido.';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Senha',
                  labelStyle: TextStyle(color: Colors.grey),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF38BDF8)),
                  ),
                  icon: Icon(Icons.lock_outline, color: Color(0xFF38BDF8)),
                ),
                obscureText: true,
                validator: (passwordVal) {
                  final password = passwordVal ?? '';
                  if (password.isEmpty || password.length < 6) {
                    return 'A senha deve conter no mínimo 6 caracteres';
                  }
                  return null;
                },
              ),
              if (_ehCadastro())
                TextFormField(
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Confirmar Senha',
                    labelStyle: TextStyle(color: Colors.grey),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF38BDF8)),
                    ),
                    icon: Icon(Icons.lock_reset, color: Color(0xFF38BDF8)),
                  ),
                  obscureText: true,
                  validator: _ehLogin()
                      ? null
                      : (passwordVal) {
                          final password = passwordVal ?? '';
                          if (password != _passwordController.text) {
                            return 'Senhas informadas são diferentes.';
                          }
                          return null;
                        },
                ),
              const SizedBox(height: 20),
              if (_isLoading)
                const CircularProgressIndicator(color: Color(0xFF38BDF8))
              else
                BotaoLogin(
                  texto: _ehLogin() ? 'Entrar' : 'Registrar Conta',
                  onPressed: _submit,
                ),
              const Spacer(),
              TextButton(
                onPressed: _trocaModoTela,
                child: Text(
                  _ehLogin() ? 'Criar novo cadastro?' : 'Já tem conta? Fazer Login',
                  style: const TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
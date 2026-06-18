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
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  Modo _modo = Modo.login;
  
  final Map<String, String> _dadosForm = {
    'email': '',
    'password': '',
  };

  bool _ehLogin() => _modo == Modo.login;
  bool _ehCadastro() => _modo == Modo.cadastro;

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
    _formKey.currentState?.save();

    AuthProvider authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      if (_ehLogin()) {
        await authProvider.login(
          _dadosForm['email']!,
          _dadosForm['password']!,
        );
      } else {
        await authProvider.cadastra(
          _dadosForm['email']!,
          _dadosForm['password']!,
        );
      }
    } catch (error) {
      String mensagemErro = 'Erro na autenticação.';
      final errStr = error.toString();
      if (errStr.contains('EMAIL_EXISTS')) {
        mensagemErro = 'Este e-mail já está cadastrado.';
      } else if (errStr.contains('EMAIL_NOT_FOUND') || errStr.contains('INVALID_LOGIN_CREDENTIALS')) {
        mensagemErro = 'E-mail ou senha incorretos.';
      } else if (errStr.contains('INVALID_PASSWORD')) {
        mensagemErro = 'Senha incorreta.';
      } else if (errStr.contains('INVALID_EMAIL')) {
        mensagemErro = 'E-mail inválido.';
      } else if (errStr.contains('WEAK_PASSWORD')) {
        mensagemErro = 'A senha é muito fraca.';
      } else {
        mensagemErro = errStr.replaceAll('Exception: ', '');
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
      margin: const EdgeInsets.symmetric(horizontal: 20),
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        height: _ehLogin() ? 320 : 410,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'E-mail (login)',
                  icon: Icon(Icons.email_outlined, color: Colors.teal),
                ),
                keyboardType: TextInputType.emailAddress,
                onSaved: (email) => _dadosForm['email'] = email ?? '',
                validator: (emailVal) {
                  final email = emailVal ?? '';
                  if (!email.contains('@')) {
                    return 'Informe um e-mail válido.';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Senha',
                  icon: Icon(Icons.lock_outline, color: Colors.teal),
                ),
                obscureText: true,
                controller: _passwordController,
                onSaved: (password) => _dadosForm['password'] = password ?? '',
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
                  decoration: const InputDecoration(
                    labelText: 'Confirmar Senha',
                    icon: Icon(Icons.lock_reset, color: Colors.teal),
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
                const CircularProgressIndicator()
              else
                BotaoLogin(
                  texto: _ehLogin() ? 'Entrar' : 'Registrar Conta',
                  onPressed: _submit,
                ),
              const Spacer(),
              BotaoLogin(
                texto: _ehLogin() ? 'Criar novo cadastro?' : 'Já tem conta? Fazer Login', 
                onPressed: _trocaModoTela,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
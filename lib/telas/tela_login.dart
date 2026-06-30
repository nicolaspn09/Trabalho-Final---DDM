import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../providers/auth_provider.dart';

enum ModoTela { boasVindas, login, cadastro }

class TelaLogin extends StatefulWidget {
  const TelaLogin({super.key});

  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> with SingleTickerProviderStateMixin {
  ModoTela _modo = ModoTela.boasVindas;
  bool _isLoading = false;
  bool _ocultarSenha = true;
  bool _ocultarConfirmarSenha = true;

  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(seconds: 15))..repeat(reverse: true);
    _animation = Tween<double>(begin: -0.1, end: 0.1).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOutSine));
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nomeController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _atualizarModo(ModoTela novoModo) {
    setState(() {
      _modo = novoModo;
      _formKey.currentState?.reset();
      _nomeController.clear();
      _emailController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
    });
  }

  Future<void> _submeter() async {
    final valido = _formKey.currentState?.validate() ?? false;
    if (!valido) return;

    setState(() => _isLoading = true);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      if (_modo == ModoTela.login) {
        await authProvider.login(
          _emailController.text.trim(),
          _passwordController.text,
        );
      } else if (_modo == ModoTela.cadastro) {
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

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(mensagemErro),
            backgroundColor: const Color(0xFFFF5C5C),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildInputLabel(String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        texto,
        style: const TextStyle(color: Color(0xFF7A7A7A), fontSize: 14, fontWeight: FontWeight.bold),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint, {Widget? suffixIcon}) {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFF171717),
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF4A4A4A), fontSize: 15),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFF97316), width: 1.5),
      ),
    );
  }

  Widget _buildDivider() {
    return const Row(
      children: [
        Expanded(child: Divider(color: Color(0xFF222222), thickness: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text('OU', style: TextStyle(color: Color(0xFF4A4A4A), fontSize: 13, fontWeight: FontWeight.bold)),
        ),
        Expanded(child: Divider(color: Color(0xFF222222), thickness: 1)),
      ],
    );
  }

  Widget _buildBotoesSociais() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSocialWrapper(
          child: const Text('G', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 16),
        _buildSocialWrapper(
          child: const Icon(Icons.apple, color: Colors.white, size: 26),
        ),
        const SizedBox(width: 16),
        _buildSocialWrapper(
          child: const Icon(Icons.facebook, color: Colors.white, size: 26),
        ),
      ],
    );
  }

  Widget _buildSocialWrapper({required Widget child}) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFF171717),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF222222)),
      ),
      alignment: Alignment.center,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000), // Fundo Preto Puro
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Fundo Animado com Efeito Desfocado (Abstract Blur)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return FractionalTranslation(
                  translation: Offset(_animation.value, _animation.value * 0.5),
                  child: Transform.scale(
                    scale: 1.25,
                    child: Image.asset('assets/bg_login.png', fit: BoxFit.cover),
                  ),
                );
              },
            ),
          ),
          
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
              child: Container(color: Colors.transparent),
            ),
          ),
          
          // Efeito de desfoque por cima do vídeo
          TweenAnimationBuilder<double>(
          tween: Tween<double>(
            begin: 0.0,
            end: _modo == ModoTela.boasVindas ? 0.0 : 8.0,
          ),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
          builder: (context, blurValue, child) {
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: blurValue, sigmaY: blurValue),
              child: Container(
                color: Colors.black.withOpacity((blurValue / 8.0) * 0.6),
                child: child,
              ),
            );
          },
          child: SafeArea(
              child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.0, 0.05),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: SizedBox(
                      key: ValueKey<ModoTela>(_modo),
                      width: double.infinity,
                      child: _buildCorpoTela(),
                    ),
                  ),
                ),
              ),
            );
          },
        ), // LayoutBuilder
       ), // SafeArea
      ), // TweenAnimationBuilder
     ], // children Stack
    ), // Stack (body)
   ); // Scaffold
  }

  Widget _buildCorpoTela() {
    switch (_modo) {
      case ModoTela.boasVindas:
        return _buildBoasVindas();
      case ModoTela.login:
        return _buildLogin();
      case ModoTela.cadastro:
        return _buildCadastro();
    }
  }

  // 1. TELA DE BOAS VINDAS
  Widget _buildBoasVindas() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        // Logo de forma responsiva ampliada (container retangular com borda roxa)
        // Logo Nativo Construído em Flutter (Perfeito, sem fundo quadrado)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFF97316).withOpacity(0.3), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 10,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.savings, // Ícone de porquinho
                color: Color(0xFFF97316), 
                size: 36,
              ),
              const SizedBox(width: 12),
              const Text(
                'MyFinance',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.0,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        // Botão de Entrar
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: () => _atualizarModo(ModoTela.login),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF97316), // Verde Limão
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(27)),
            ),
            child: const Text('Entrar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ),
        const SizedBox(height: 12),
        // Botão de Registrar
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: () => _atualizarModo(ModoTela.cadastro),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF171717),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(27),
                side: const BorderSide(color: Color(0xFF333333), width: 1.5),
              ),
            ),
            child: const Text('Cadastrar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // 2. TELA DE LOGIN
  Widget _buildLogin() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          // Botão voltar
          IconButton(
            onPressed: () => _atualizarModo(ModoTela.boasVindas),
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            padding: EdgeInsets.zero,
            alignment: Alignment.centerLeft,
          ),
          const SizedBox(height: 24),
          const Text(
            "Vamos entrar.",
            style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1),
          ),
          const SizedBox(height: 12),
          const Text(
            "Bem-vindo de volta.\nSentimos sua falta!",
            style: TextStyle(color: Color(0xFF7A7A7A), fontSize: 24, fontWeight: FontWeight.w500, height: 1.3),
          ),
          const SizedBox(height: 36),

          // Email
          _buildInputLabel('E-mail'),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(color: Colors.white),
            decoration: _buildInputDecoration('Digite seu e-mail'),
            validator: (value) {
              if (value == null || !value.contains('@')) {
                return 'Informe um e-mail válido';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),

          // Senha
          _buildInputLabel('Senha'),
          TextFormField(
            controller: _passwordController,
            obscureText: _ocultarSenha,
            style: const TextStyle(color: Colors.white),
            decoration: _buildInputDecoration(
              'Digite sua senha',
              suffixIcon: IconButton(
                onPressed: () => setState(() => _ocultarSenha = !_ocultarSenha),
                icon: Icon(
                  _ocultarSenha ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: const Color(0xFF7A7A7A),
                  size: 20,
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty || value.length < 6) {
                return 'A senha deve conter no mínimo 6 caracteres';
              }
              return null;
            },
          ),
          const SizedBox(height: 32),

          _buildDivider(),
          const SizedBox(height: 24),
          _buildBotoesSociais(),
          
          const Spacer(),
          // Link Cadastro
          Center(
            child: TextButton(
              onPressed: () => _atualizarModo(ModoTela.cadastro),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Não tem uma conta? ", style: TextStyle(color: Color(0xFF7A7A7A))),
                  Text("Cadastre-se", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Botão Confirmar
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submeter,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF97316),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(27)),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2.5),
                    )
                  : const Text('Entrar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // 3. TELA DE CADASTRO
  Widget _buildCadastro() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          // Botão voltar
          IconButton(
            onPressed: () => _atualizarModo(ModoTela.boasVindas),
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            padding: EdgeInsets.zero,
            alignment: Alignment.centerLeft,
          ),
          const SizedBox(height: 12),
          const Text(
            "Vamos começar.",
            style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -1),
          ),
          const SizedBox(height: 4),
          const Text(
            "Comece a sua jornada conosco.",
            style: TextStyle(color: Color(0xFF7A7A7A), fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 20),

          _buildBotoesSociais(),
          const SizedBox(height: 20),
          _buildDivider(),
          const SizedBox(height: 20),

          // Nome Completo
          _buildInputLabel('Nome Completo'),
          TextFormField(
            controller: _nomeController,
            style: const TextStyle(color: Colors.white),
            decoration: _buildInputDecoration('Digite seu nome completo'),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Informe seu nome';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),

          // Email
          _buildInputLabel('E-mail'),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(color: Colors.white),
            decoration: _buildInputDecoration('Digite seu e-mail'),
            validator: (value) {
              if (value == null || !value.contains('@')) {
                return 'Informe um e-mail válido';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),

          // Senha
          _buildInputLabel('Senha'),
          TextFormField(
            controller: _passwordController,
            obscureText: _ocultarSenha,
            style: const TextStyle(color: Colors.white),
            decoration: _buildInputDecoration(
              'Digite sua senha',
              suffixIcon: IconButton(
                onPressed: () => setState(() => _ocultarSenha = !_ocultarSenha),
                icon: Icon(
                  _ocultarSenha ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: const Color(0xFF7A7A7A),
                  size: 20,
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty || value.length < 6) {
                return 'A senha deve conter no mínimo 6 caracteres';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),

          // Confirmar Senha
          _buildInputLabel('Confirmar Senha'),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _ocultarConfirmarSenha,
            style: const TextStyle(color: Colors.white),
            decoration: _buildInputDecoration(
              'Confirme sua senha',
              suffixIcon: IconButton(
                onPressed: () => setState(() => _ocultarConfirmarSenha = !_ocultarConfirmarSenha),
                icon: Icon(
                  _ocultarConfirmarSenha ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: const Color(0xFF7A7A7A),
                  size: 20,
                ),
              ),
            ),
            validator: (value) {
              if (value != _passwordController.text) {
                return 'As senhas informadas são diferentes';
              }
              return null;
            },
          ),
          const Spacer(),
          const SizedBox(height: 16),
          // Link Login
          Center(
            child: TextButton(
              onPressed: () => _atualizarModo(ModoTela.login),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Já tem uma conta? ", style: TextStyle(color: Color(0xFF7A7A7A))),
                  Text("Entrar", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Botão Confirmar Cadastro
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submeter,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF97316),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(27)),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2.5),
                    )
                  : const Text('Cadastrar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

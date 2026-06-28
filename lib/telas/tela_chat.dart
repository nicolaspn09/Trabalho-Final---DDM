import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/transacao_provider.dart';

class TelaChat extends StatefulWidget {
  const TelaChat({super.key});

  @override
  State<TelaChat> createState() => _TelaChatState();
}

class _TelaChatState extends State<TelaChat> {
  final _mensagemController = TextEditingController();
  final _apiKeyController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  List<Map<String, String>> _mensagens = [];
  bool _isLoading = false;
  String? _apiKey;

  @override
  void initState() {
    super.initState();
    _loadApiKey();
    _mensagens.add({
      'role': 'model',
      'text': 'Olá! Eu sou o Pork, seu assistente financeiro. Como posso ajudar você hoje?'
    });
  }

  Future<void> _loadApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _apiKey = prefs.getString('gemini_api_key');
    });
  }

  Future<void> _saveApiKey() async {
    if (_apiKeyController.text.trim().isEmpty) return;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('gemini_api_key', _apiKeyController.text.trim());
    
    setState(() {
      _apiKey = _apiKeyController.text.trim();
    });
  }

  Future<void> _enviarMensagem() async {
    final text = _mensagemController.text.trim();
    if (text.isEmpty || _apiKey == null) return;

    setState(() {
      _mensagens.add({'role': 'user', 'text': text});
      _isLoading = true;
    });
    
    _mensagemController.clear();
    _scrollToBottom();

    // Obter contexto das transações
    final transacaoProvider = Provider.of<TransacaoProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final nomeUsuario = authProvider.nomeUsuario;
    
    String contextoTransacoes = "Aqui estão as transações recentes do usuário:\n";
    for (var t in transacaoProvider.transacoes.take(10)) {
      contextoTransacoes += "- ${t.titulo}: R\$ ${t.valor.toStringAsFixed(2)} (${t.tipo} - ${t.categoria})\n";
    }

    final systemPrompt = """
Você é o Pork, um assistente financeiro de IA com estilo premium, integrado ao aplicativo financeiro do usuário chamado "MyFinance".
O nome do usuário é $nomeUsuario.
Você tem uma personalidade educada, analítica, direta e proativa.
O aplicativo possui o estilo Nubank Dark (design muito moderno e premium).
Sempre chame o usuário pelo nome em suas respostas para um tom mais pessoal.
Responda de forma concisa, útil e foque nas finanças do usuário.
Abaixo está o contexto financeiro atual do usuário:
$contextoTransacoes
""";

    try {
      final response = await http.post(
        Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "system_instruction": {
            "parts": {"text": systemPrompt}
          },
          "contents": [
            {
              "parts": [
                {"text": text}
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final replyText = data['candidates'][0]['content']['parts'][0]['text'];
        
        setState(() {
          _mensagens.add({'role': 'model', 'text': replyText});
        });
      } else {
        setState(() {
          _mensagens.add({'role': 'model', 'text': 'Desculpe, ocorreu um erro ao conectar com minha IA (Status ${response.statusCode}). Verifique se sua chave de API é válida.'});
        });
      }
    } catch (e) {
      setState(() {
        _mensagens.add({'role': 'model', 'text': 'Desculpe, ocorreu um erro de rede. Tente novamente mais tarde.'});
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildConfigApi() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.smart_toy, size: 64, color: Color(0xFFF97316)),
          const SizedBox(height: 24),
          const Text(
            "Olá! Eu sou o Pork.",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          const Text(
            "Para conversar comigo, você precisa fornecer a sua chave de API do Gemini. Fique tranquilo, ela será salva apenas no seu dispositivo de forma segura.",
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _apiKeyController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: "Chave da API do Gemini",
              labelStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: const Color(0xFF171717),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFF97316), width: 1.5),
              ),
              prefixIcon: const Icon(Icons.key, color: Colors.grey),
            ),
            obscureText: true,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveApiKey,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF97316),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'SALVAR CHAVE E CONTINUAR',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMensagem(Map<String, String> msg) {
    final isUser = msg['role'] == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFFF97316) : const Color(0xFF171717),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 0),
            bottomRight: Radius.circular(isUser ? 0 : 16),
          ),
        ),
        child: Text(
          msg['text']!,
          style: TextStyle(
            color: isUser ? Colors.black : Colors.white,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      appBar: AppBar(
        backgroundColor: const Color(0xFF000000),
        title: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Color(0xFFF97316),
              child: Icon(Icons.smart_toy, color: Colors.black),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Pork AI", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
                Text("Seu assistente financeiro", style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            )
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          if (_apiKey != null)
            IconButton(
              icon: const Icon(Icons.key_off, color: Colors.grey),
              tooltip: "Remover API Key",
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('gemini_api_key');
                setState(() {
                  _apiKey = null;
                });
              },
            )
        ],
      ),
      body: _apiKey == null
          ? _buildConfigApi()
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(top: 16),
                    itemCount: _mensagens.length,
                    itemBuilder: (context, index) {
                      return _buildMensagem(_mensagens[index]);
                    },
                  ),
                ),
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(color: Color(0xFFF97316)),
                  ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFF171717),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _mensagemController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: "Pergunte algo ao Pork...",
                            hintStyle: const TextStyle(color: Colors.grey),
                            filled: true,
                            fillColor: const Color(0xFF000000),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                          onSubmitted: (_) => _enviarMensagem(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: _enviarMensagem,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            color: Color(0xFFF97316),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.send, color: Colors.black),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

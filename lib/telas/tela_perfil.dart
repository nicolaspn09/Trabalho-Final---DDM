import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../util/avatar_util.dart';

class TelaPerfil extends StatefulWidget {
  const TelaPerfil({super.key});

  @override
  State<TelaPerfil> createState() => _TelaPerfilState();
}

class _TelaPerfilState extends State<TelaPerfil> {
  late TextEditingController _nomeController;
  late String _selectedAvatar;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _nomeController = TextEditingController(text: authProvider.nomeUsuario);
    _selectedAvatar = authProvider.avatarId ?? '1';
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      appBar: AppBar(
        title: const Text('Meu Perfil', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF000000),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current Avatar
              Center(
                child: AvatarUtil.construirAvatar(_selectedAvatar, size: 100, iconSize: 50),
              ),
              const SizedBox(height: 32),

              const Text('Nome de exibição', style: TextStyle(color: Color(0xFF7A7A7A), fontSize: 14)),
              const SizedBox(height: 8),
              TextField(
                controller: _nomeController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF171717),
                  hintText: 'Digite seu nome',
                  hintStyle: const TextStyle(color: Color(0xFF7A7A7A)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              const Text('Escolha seu avatar', style: TextStyle(color: Color(0xFF7A7A7A), fontSize: 14)),
              const SizedBox(height: 12),
              SizedBox(
                height: 64,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: AvatarUtil.opcoes.length,
                  itemBuilder: (context, idx) {
                    final avatar = AvatarUtil.opcoes[idx];
                    final isSelected = avatar['id'] == _selectedAvatar;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedAvatar = avatar['id'];
                        });
                      },
                      child: Container(
                        width: 56,
                        height: 56,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: avatar['colors'],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? const Color(0xFFF97316) : Colors.transparent,
                            width: 3,
                          ),
                        ),
                        child: isSelected 
                          ? const Icon(Icons.check, color: Colors.white, size: 24)
                          : Icon(avatar['icon'], color: Colors.white, size: 24),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_nomeController.text.trim().isEmpty) return;
                    try {
                      await authProvider.atualizarPerfil(
                        _nomeController.text.trim(),
                        avatarId: _selectedAvatar,
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Perfil atualizado com sucesso!'),
                            backgroundColor: Color(0xFF10B981),
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Erro ao atualizar: $e'),
                            backgroundColor: const Color(0xFFFF5C5C),
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF97316),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  child: const Text(
                    'Salvar Alterações',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
              
              const SizedBox(height: 48),
              
              // Logout button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () {
                    authProvider.logout();
                  },
                  icon: const Icon(Icons.logout, color: Color(0xFFFF5C5C)),
                  label: const Text('Sair da Conta', style: TextStyle(color: Color(0xFFFF5C5C), fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFFF5C5C)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                ),
              ),
              const SizedBox(height: 100), // Space for dock
            ],
          ),
        ),
      ),
    );
  }
}

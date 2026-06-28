import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../providers/transacao_provider.dart';
import '../providers/auth_provider.dart';
import '../util/rotas.dart';
import 'tela_lista.dart';
import 'tela_dashboard.dart';
import 'tela_alertas.dart';
import 'tela_perfil.dart';

class TelaPrincipal extends StatefulWidget {
  const TelaPrincipal({super.key});

  @override
  State<TelaPrincipal> createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  int _currentIndex = 1;
  final PageController _pageController = PageController(initialPage: 1);

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onItemTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/bg_home.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              physics: const BouncingScrollPhysics(),
              children: const [
                TelaLista(titulo: 'Atividades'),
                TelaDashboard(),
                TelaAlertas(),
                TelaPerfil(),
              ],
            ),
          ),
          
          // Floating Bottom Navigation (Nubank Style)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Pill "Pergunte ao Pierre"
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushNamed(Rotas.telaChat);
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF171717).withOpacity(0.9),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.5), width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF8B5CF6).withOpacity(0.2),
                          blurRadius: 10,
                          spreadRadius: 1,
                        )
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF8B5CF6).withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.auto_awesome, color: Color(0xFF8B5CF6), size: 16),
                        ),
                        const SizedBox(width: 8),
                        const Text('Pergunte ao Pork', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Dock
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  decoration: const BoxDecoration(
                    color: Color(0xFF0A0A0A), // Super dark
                    border: Border(top: BorderSide(color: Color(0xFF1F1F1F), width: 1)),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildNavItem(Icons.home_outlined, Icons.home, 1, 'Home'),
                        _buildNavItem(Icons.sync_alt, Icons.sync_alt, 0, 'Atividades'),
                        // Central Action
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pushNamed(Rotas.telaForm);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                              color: Color(0xFFF97316),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.add, color: Colors.black, size: 28),
                          ),
                        ),
                        _buildNavItem(Icons.notifications_none, Icons.notifications, 2, 'Alertas'),
                        _buildNavItem(Icons.person_outline, Icons.person, 3, 'Perfil'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData unselectedIcon, IconData selectedIcon, int index, String label) {
    final isSelected = _currentIndex == index;
    
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSelected ? selectedIcon : unselectedIcon, 
            color: isSelected ? Colors.white : const Color(0xFF7A7A7A), 
            size: 28
          ),
        ],
      ),
    );
  }
}

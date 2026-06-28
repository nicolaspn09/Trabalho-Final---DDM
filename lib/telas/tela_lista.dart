import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../providers/auth_provider.dart';
import '../providers/transacao_provider.dart';
import '../models/transacao.dart';
import '../util/rotas.dart';

class TelaLista extends StatefulWidget {
  final String titulo;

  const TelaLista({super.key, required this.titulo});

  @override
  State<TelaLista> createState() => _TelaListaState();
}

class _TelaListaState extends State<TelaLista> {
  bool _estaCarregando = false;
  String _localizacaoAtual = 'Buscando localização...';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _buscarDados();
      _buscarLocalizacao();
    });
  }

  Future<void> _buscarLocalizacao() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _localizacaoAtual = 'GPS Desativado');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _localizacaoAtual = 'Permissão de GPS Negada');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() => _localizacaoAtual = 'Permissão Negada Permanentemente');
        return;
      }

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.low);
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        // subAdministrativeArea usually holds the city name, or locality
        final city = place.subAdministrativeArea?.isNotEmpty == true ? place.subAdministrativeArea : place.locality;
        setState(() {
          _localizacaoAtual = '${city ?? "Desconhecido"}, ${place.administrativeArea ?? ""}';
        });
      } else {
        setState(() => _localizacaoAtual = 'Local não encontrado');
      }
    } catch (e) {
      setState(() => _localizacaoAtual = 'Não foi possível rastrear');
      print('Erro de GPS: $e');
    }
  }

  Future<void> _buscarDados() async {
    setState(() => _estaCarregando = true);
    final userId = Provider.of<AuthProvider>(context, listen: false).userId;
    if (userId != null) {
      await Provider.of<TransacaoProvider>(context, listen: false).carregarDadosCompletos(userId);
    }
    if (mounted) {
      setState(() => _estaCarregando = false);
    }
  }

  // Helper para obter o ícone correspondente à categoria
  Widget _obterIconeCategoria(String categoria, String tipo) {
    if (tipo == 'receita') {
      return Container(
        padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(
          color: Color(0x1A10B981), // Verde translúcido
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.attach_money, color: Color(0xFF10B981), size: 24),
      );
    }

    final catLower = categoria.toLowerCase();
    IconData iconData = Icons.payment;
    Color color = const Color(0xFF3B82F6); // Azul
    Color bgColor = const Color(0x1A3B82F6);

    if (catLower.contains('aliment') || catLower.contains('food') || catLower.contains('mercado') || catLower.contains('supermercado')) {
      iconData = Icons.shopping_cart;
      color = const Color(0xFFF97316); // Laranja
      bgColor = const Color(0x1AF97316);
    } else if (catLower.contains('transporte') || catLower.contains('combust') || catLower.contains('gas') || catLower.contains('fuel') || catLower.contains('posto')) {
      iconData = Icons.local_gas_station;
      color = const Color(0xFFEAB308); // Amarelo
      bgColor = const Color(0x1AEAB308);
    } else if (catLower.contains('pet') || catLower.contains('anim')) {
      iconData = Icons.pets;
      color = const Color(0xFF8B5CF6); // Roxo
      bgColor = const Color(0x1A8B5CF6);
    } else if (catLower.contains('saud') || catLower.contains('health') || catLower.contains('hospital') || catLower.contains('farmacia')) {
      iconData = Icons.medical_services;
      color = const Color(0xFFEF4444); // Vermelho
      bgColor = const Color(0x1AEF4444);
    } else if (catLower.contains('lazer') || catLower.contains('game') || catLower.contains('show')) {
      iconData = Icons.sports_esports;
      color = const Color(0xFFEC4899); // Rosa
      bgColor = const Color(0x1AEC4899);
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      child: Icon(iconData, color: color, size: 24),
    );
  }

  void _mostrarMenuSettings(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Sair do Aplicativo', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  authProvider.logout();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final transacaoProvider = Provider.of<TransacaoProvider>(context);
    final transacoes = transacaoProvider.transacoes;
    final recentes = transacoes.take(15).toList(); // Vamos exibir um pouco mais de transações

    return Scaffold(
      backgroundColor: const Color(0xFF000000), // Fundo Preto Puro
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              // Header
              const Text(
                'Atividades',
                style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              
              // Barra de Busca
              Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF171717),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.search, color: Color(0xFF7A7A7A), size: 20),
                    SizedBox(width: 8),
                    Text('Buscar', style: TextStyle(color: Color(0xFF7A7A7A), fontSize: 16)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Filtros (Pills horizontais)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFF333333)),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.tune, color: Colors.white, size: 16),
                          SizedBox(width: 6),
                          Text('Filtros', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    _buildFiltroPill('Entradas'),
                    const SizedBox(width: 12),
                    _buildFiltroPill('Saídas'),
                    const SizedBox(width: 12),
                    _buildFiltroPill('Categorias'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Resumo
              Text('${recentes.length} resultados', style: const TextStyle(color: Color(0xFF7A7A7A))),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildResumoMini('Total entradas', transacaoProvider.totalReceitas, Icons.call_received, const Color(0xFF10B981)),
                  const SizedBox(width: 24),
                  _buildResumoMini('Total saídas', transacaoProvider.totalDespesas, Icons.call_made, const Color(0xFFFF5C5C)),
                ],
              ),
              const SizedBox(height: 24),

              // Lista
              Expanded(
                child: _estaCarregando
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFFF97316)))
                  : recentes.isEmpty
                    ? const Center(child: Text('Nenhuma atividade.', style: TextStyle(color: Color(0xFF7A7A7A))))
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: recentes.length,
                        itemBuilder: (context, index) {
                          final tx = recentes[index];
                          final isReceita = tx.tipo == 'receita';
                          
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 24.0),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).pushNamed(Rotas.telaDetalhes, arguments: tx).then((_) => _buscarDados());
                              },
                              child: Row(
                                children: [
                                  // Ícone com logo no badge
                                  SizedBox(
                                    width: 52,
                                    height: 52,
                                    child: Stack(
                                      children: [
                                        Container(
                                          width: 48,
                                          height: 48,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF171717),
                                            shape: BoxShape.circle,
                                          ),
                                          child: _obterIconeCategoria(tx.categoria, tx.tipo),
                                        ),
                                        Positioned(
                                          bottom: 0,
                                          right: 0,
                                          child: Container(
                                            padding: const EdgeInsets.all(3),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF8B5CF6),
                                              shape: BoxShape.circle,
                                              border: Border.all(color: Colors.black, width: 2),
                                            ),
                                            child: const Icon(Icons.flash_on, color: Colors.white, size: 10),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(tx.titulo, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 4),
                                        Text(tx.categoria, style: const TextStyle(color: Color(0xFF7A7A7A), fontSize: 14)),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '${isReceita ? '' : '- '}R\$ ${tx.valor.toStringAsFixed(2).replaceAll('.', ',')}',
                                    style: TextStyle(
                                      color: isReceita ? Colors.white : const Color(0xFFFF5C5C),
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 100), // Padding do dock inferior
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFiltroPill(String texto) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF171717),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(texto, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildResumoMini(String titulo, double valor, IconData icone, Color cor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Color(0xFF171717),
                shape: BoxShape.circle,
              ),
              child: Icon(icone, color: cor, size: 12),
            ),
            const SizedBox(width: 6),
            Text(titulo, style: const TextStyle(color: Color(0xFF7A7A7A), fontSize: 12)),
          ],
        ),
        const SizedBox(height: 4),
        Text('R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }
}
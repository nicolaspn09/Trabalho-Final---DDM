import 'package:flutter/material.dart';
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
    final authProvider = Provider.of<AuthProvider>(context);
    final transacaoProvider = Provider.of<TransacaoProvider>(context);
    final transacoes = transacaoProvider.transacoes;
    final recentes = transacoes.take(4).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0B121F), // Fundo escuro idêntico ao do mockup
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _buscarDados,
          color: const Color(0xFF38BDF8),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cabeçalho de Boas-vindas
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: const Color(0xFF1E293B),
                          child: Text(
                            authProvider.nomeUsuario.isNotEmpty
                                ? authProvider.nomeUsuario[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Boa tarde,',
                                  style: TextStyle(color: Colors.grey, fontSize: 13),
                                ),
                                Text(
                                  authProvider.nomeUsuario,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on, color: Color(0xFF38BDF8), size: 12),
                                    const SizedBox(width: 4),
                                    Text(
                                      _localizacaoAtual,
                                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings, color: Colors.white),
                      onPressed: () => _mostrarMenuSettings(context),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Card Principal de Saldo (Aparência idêntica ao Mockup)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F1E36), Color(0xFF122C54)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.account_balance, color: Color(0xFF38BDF8), size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Saldo Disponível',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'R\$ ${transacaoProvider.saldoTotal.toStringAsFixed(2).replaceAll('.', ',')}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Chip verde com ganhos totais
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0x2610B981), // Verde translúcido
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.arrow_upward, color: Color(0xFF10B981), size: 12),
                            const SizedBox(width: 4),
                            Text(
                              'R\$ ${transacaoProvider.totalReceitas.toStringAsFixed(2).replaceAll('.', ',')}',
                              style: const TextStyle(
                                color: Color(0xFF10B981),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Seção Transações Recentes
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Transações Recentes',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: _buscarDados,
                      child: const Text(
                        'Atualizar',
                        style: TextStyle(color: Color(0xFF38BDF8), fontSize: 13),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Listagem de Transações
                if (_estaCarregando)
                  const Center(child: CircularProgressIndicator(color: Color(0xFF38BDF8)))
                else if (recentes.isEmpty)
                  Container(
                    height: 150,
                    width: double.infinity,
                    alignment: Alignment.center,
                    child: const Text(
                      'Nenhuma transação cadastrada.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: recentes.length,
                    itemBuilder: (context, index) {
                      final tx = recentes[index];
                      final isReceita = tx.tipo == 'receita';

                      return Card(
                        color: const Color(0xFF1E293B),
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ListTile(
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              Rotas.telaDetalhes,
                              arguments: tx,
                            ).then((_) => _buscarDados());
                          },
                          leading: _obterIconeCategoria(tx.categoria, tx.tipo),
                          title: Text(
                            tx.titulo,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            tx.categoria,
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                          ),
                          trailing: Text(
                            '${isReceita ? '+' : '-'} R\$ ${tx.valor.toStringAsFixed(2).replaceAll('.', ',')}',
                            style: TextStyle(
                              color: isReceita ? const Color(0xFF10B981) : Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(Rotas.telaForm).then((_) => _buscarDados());
        },
        backgroundColor: const Color(0xFF38BDF8),
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 28),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF1E293B),
        selectedItemColor: const Color(0xFF38BDF8),
        unselectedItemColor: Colors.grey,
        currentIndex: 0, // Home ativo
        onTap: (index) {
          if (index == 1) {
            Navigator.pushReplacementNamed(context, Rotas.telaDashboard);
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, Rotas.telaAlertas);
          }
        },
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          const BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Dashboard'),
          BottomNavigationBarItem(
            icon: transacaoProvider.alertasNaoLidos == 0 
                ? const Icon(Icons.notifications) 
                : Badge(
                    label: Text('${transacaoProvider.alertasNaoLidos}'),
                    child: const Icon(Icons.notifications),
                  ),
            label: 'Alertas',
          ),
        ],
      ),
    );
  }
}
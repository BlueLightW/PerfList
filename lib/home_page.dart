import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:perf_list/perfil_usuario.dart';
import 'package:perf_list/criador_de_listas.dart';
import 'package:perf_list/amigos.dart';
import 'package:perf_list/settings.dart';
import 'package:perf_list/shared_lists.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final String? nickname = FirebaseAuth.instance.currentUser ?.displayName; 
  final String? profileImageUrl = FirebaseAuth.instance.currentUser ?.photoURL;

  int _selectedIndex = 0; // Índice da aba selecionada

  // Lista de telas para navegação
  final List<Widget> _screens = [
    // Adicione suas telas aqui
    const CriarListaScreen(), // Listas
    AmigosScreen(), // Amigos (substitua por sua tela de amigos)
    SettingsScreen(), // Configurações (substitua por sua tela de configurações)
    SharedListsScreen()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Atualiza o índice da aba selecionada
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PerfList'),
        centerTitle: true,
        actions: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UserProfileSreen()),
                  );
                },
                child: CircleAvatar(
                  radius: 20,
                  backgroundImage: profileImageUrl != null
                      ? NetworkImage(profileImageUrl!)
                      : null,
                  child: profileImageUrl == null
                      ? const Icon(Icons.person, size: 20)
                      : null,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                nickname != null ? nickname! : 'Default',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 16),
            ],
          ),
        ],
      ),
      body: _screens[_selectedIndex], // Exibe a tela correspondente ao índice selecionado
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Listas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Amigos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Configurações',
          ),
          // New item for shared lists
          BottomNavigationBarItem(
            icon: Icon(Icons.share),
            label: 'Compartilhados Comigo',
          ),
        ],
        // 
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        onTap: _onItemTapped, // Chama o método ao tocar em um item
      ),
    );
  }
}
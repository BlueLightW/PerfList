import 'package:flutter/material.dart';
import 'package:perf_list/item_list.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:perf_list/criar_lista_animes.dart';
import 'package:perf_list/criar_lista_filmes.dart';
import 'package:perf_list/criar_lista_series.dart';

class CriarListaScreen extends StatefulWidget {
  const CriarListaScreen({super.key});

  @override
  State<CriarListaScreen> createState() => _CriarListaScreenState();
}

class _CriarListaScreenState extends State<CriarListaScreen> {
  final String? nickname = FirebaseAuth.instance.currentUser?.displayName; 
  final String? profileImageUrl = FirebaseAuth.instance.currentUser?.photoURL;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          
          Expanded(
            child: ListView(
              children: [
                _buildCategoryCard('Animes', Icons.tv, () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateListScreen()),
                )),
                _buildCategoryCard('Filmes', Icons.movie, () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateListFilmesScreen()),
                )),
                _buildCategoryCard('Séries', Icons.live_tv, () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateListSeriesScreen()),
                )),
                _buildCategoryCard('Mercado', Icons.shopping_cart, () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ItemListScreen(category: 'mercado')),
                )),
                _buildCategoryCard('Trabalho Escolar', Icons.school, () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ItemListScreen(category: 'trabalho escolar')),
                )),
                _buildCategoryCard('Compras Online', Icons.shopping_basket, () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ItemListScreen(category: 'category')),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(String title, IconData icon, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      elevation: 4,
      child: InkWell(
          onTap: onTap,
          child: Container(
            height: 80, // Increased height for the card
            child: ListTile(
              mouseCursor: SystemMouseCursors.click,
              contentPadding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 12.0), // Centering vertically
              leading: Icon(icon, size: 40, color: Theme.of(context).primaryColor), // Use theme color
              title: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              visualDensity: const VisualDensity(vertical: -4), // Adjusts vertical density
            ),
          ),
        ),
      
    );
  }
}

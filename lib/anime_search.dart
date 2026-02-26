import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:perf_list/anime.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'dart:async';

class AnimeSearchScreen extends StatefulWidget {
  final String lista;
  const AnimeSearchScreen({super.key, required this.lista});
  @override
  _AnimeSearchScreenState createState() => _AnimeSearchScreenState();
}

class _AnimeSearchScreenState extends State<AnimeSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Anime> _animes = [];
  String user_uid = FirebaseAuth.instance.currentUser!=null ? FirebaseAuth.instance.currentUser!.uid : "";

  void _searchAnimes() async {
    final query = _searchController.text;
    
    if(_searchController.text.length == 2 || _searchController.text.length == 4 || _searchController.text.length == 6 || _searchController.text.length >= 8) {
      try {                                         
        final response = await http.get(Uri.parse('https://api.jikan.moe/v4/anime?q=$query&limit=5'));
        
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          String generateDocumentId(String title) {
          // Remove caracteres inválidos e substitui espaços por underscores
          final documentId = title
              .replaceAll(RegExp(r'[^a-zA-Z0-9 ]'), '')
              .replaceAll(' ', '_')
              .toLowerCase();

            return documentId.isEmpty ? 'default_id' : documentId;
          }
          
          
          
          // print('titulo retornou ${data['data'][0]['title']}');
          setState(() {
            _animes = (data['data'] as List).map((anime) {
              String documentId = generateDocumentId(anime['title']);
              // print("id do doc: $documentId");
              return Anime.fromJson(anime, documentId);
            }).toList();
            
          });
        } else {
          print('Erro ao buscar animes: ${response.statusCode}');
        }
      } catch (e) {
        print('Erro ao buscar animes: $e');
      }
    }
  }

Future<void> _saveAnimeToFirestore(Anime anime) async {
    final uid = user_uid; // Substitua pelo UID do usuário autenticado
    final animeData = anime.toJson();
    
      // Função para criar um ID de documento a partir do título
    
    // print('printando o id: ${animeData['id']}');
    

    try {
      await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('listas')
        .doc('animes')
        .collection('animes')
        .doc(widget.lista)
        .collection('animeList')
        .doc(animeData['id'])
        .set(animeData);
      } catch (e) {
      print('Erro ao salvar anime: $e'); // Imprime o erro no console
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pesquisar Animes'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Pesquisar Anime',
                suffixIcon: Icon(Icons.search),
              ),
              onChanged: (_) => _searchAnimes(),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _animes.length,
              itemBuilder: (context, index) {
                return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(8.0),
                      leading: Image.network(
                        _animes[index].imageUrl,
                        width: 75,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                      title: Text(_animes[index].title),
                      onTap: () {
                        // Retorna o anime selecionado para a tela de adição
                        print(_animes[index]);
                        _saveAnimeToFirestore(_animes[index]);
                        Navigator.pop(context, _animes[index]);
                      },
                    ),
                  );
                },
              ),
            ),
          
        ],
      ),
    );
  }
}

// filme_search.dart
import 'package:flutter/material.dart';
import 'filme.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FilmeSearchScreen extends StatefulWidget {
  final String lista;
  const FilmeSearchScreen({super.key, required this.lista});
  @override
  _FilmeSearchScreenState createState() => _FilmeSearchScreenState();
}

class _FilmeSearchScreenState extends State<FilmeSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Filme> _filmes = [];
  String apiKey = 'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI5NTZlN2Y5MmQ2MzkwZDA2OTQ3YTI4YjJlMmI3M2UyNCIsIm5iZiI6MTczMzU4OTU2MC4yNjIsInN1YiI6IjY3NTQ3YTM4MmEwZTljNzlmMTliOTdiMyIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.Ccr50ObmLdJkjfw_0sirk8UjUbPDc1oZ5kQBiFUrCks';
  String user_uid = FirebaseAuth.instance.currentUser!=null ? FirebaseAuth.instance.currentUser!.uid : "";
  String generateDocumentId(String title) {
    // Remove caracteres inválidos e substitui espaços por underscores
    final documentId = title
        .replaceAll(RegExp(r'[^a-zA-Z0-9 ]'), '')
        .replaceAll(' ', '_')
        .toLowerCase();

      return documentId.isEmpty ? 'default_id' : documentId;
    }
Future<void> _saveFilmeToFirestore(Filme filme) async {
    final uid = user_uid; // Substitua pelo UID do usuário autenticado
    final filmeData = filme.toJson();
    
    print('printando o id: ${filmeData['id']}');
    
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('listas')
          .doc('filmes') // Modificado para 'filmes'
          .collection('filmes')
          .doc(widget.lista)
          .collection('filmeList') // Modificado para 'filmes'
          .doc(generateDocumentId(filmeData['title'])) // Usando o ID do filme
          .set(filmeData);
    } catch (e) {
      print('Erro ao salvar filme: $e'); // Imprime o erro no console
    }
}

void _searchFilmes() async {
  final query = _searchController.text;
  if (query.length == 2 || query.length == 4 || query.length == 6 || query.length >= 8) {
    try {
      final encodedQuery = Uri.encodeQueryComponent(query);
      
      final response = await http.get(
        Uri.parse('https://api.themoviedb.org/3/search/movie?query=$encodedQuery&include_adult=true&language=pt-BR&page=1'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'accept': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _filmes = (data['results'] as List).map((filme){ 
            final documentId = generateDocumentId(filme['title']);
            return Filme.fromJson(filme, documentId);
          }).toList();
        });
      } else {
        // Lidar com o erro de resposta da API
        print('Erro na requisição: ${response.statusCode}');
        // Você pode mostrar uma mensagem ao usuário aqui, se necessário
      }
    } catch (e) {
      // Captura qualquer exceção que ocorra durante a requisição
      print('Erro ao buscar filmes: $e');
      // Você pode mostrar uma mensagem ao usuário aqui, se necessário
    }
  } else {
    // Lidar com o caso em que a consulta é muito curta
    print('A consulta deve ter pelo menos 2 caracteres.');
    // Você pode mostrar uma mensagem ao usuário aqui, se necessário
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buscar Filmes'),centerTitle: true,),
      body: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: (value) => _searchFilmes(),
            decoration: const InputDecoration(labelText: 'Digite o nome do filme'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filmes.length,// filme_search.dart
              itemBuilder: (context, index) {
                final filme = _filmes[index];
                return ListTile(
                  title: Text(filme.titulo),
                  leading: Image.network(filme.imagemUrl, width: 50, fit: BoxFit.cover),
                  subtitle: Text('Data de Lançamento: ${filme.dataLancamento}'),
                  onTap: () {
                    _saveFilmeToFirestore(filme);
                    Navigator.pop(context, filme); // Retorna o filme selecionado
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
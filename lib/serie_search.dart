import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:perf_list/serie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'dart:async';

class SerieSearchScreen extends StatefulWidget {
  final String lista;
  const SerieSearchScreen({super.key, required this.lista});
  @override
  _SerieSearchScreenState createState() => _SerieSearchScreenState();
}

class _SerieSearchScreenState extends State<SerieSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Serie> _series = [];
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
  Future<void> _saveSerieToFirestore(Serie serie) async {
    final uid = user_uid; // Substitua pelo UID do usuário autenticado
    final serieData = serie.toJson();
    
    print('printando o id: ${serieData['id']}');
    
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('listas')
          .doc('series') // Modificado para 'filmes'
          .collection('series')
          .doc(widget.lista)
          .collection('serieList') // Modificado para 'filmes'
          .doc(generateDocumentId(serieData['name'])) // Usando o ID do filme
          .set(serieData);
    } catch (e) {
      print('Erro ao salvar serie: $e'); // Imprime o erro no console
    }
}

  void _searchSeries() async {
    final query = _searchController.text;
  if (query.length == 2 || query.length == 4 || query.length == 6 || query.length >= 8) {
    try {
      final encodedQuery = Uri.encodeQueryComponent(query);
      
      final response = await http.get(
        Uri.parse('https://api.themoviedb.org/3/search/tv?query=$encodedQuery&include_adult=true&language=pt-BR&page=1'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'accept': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _series = (data['results'] as List).map((serie){ 
            final documentId = generateDocumentId(serie['name']);
            return Serie.fromJson(serie, documentId);
          }).toList();
        });
      } else {
        // Lidar com o erro de resposta da API
        print('Erro na requisição: ${response.statusCode}');
        // Você pode mostrar uma mensagem ao usuário aqui, se necessário
      }
    } catch (e) {
      // Captura qualquer exceção que ocorra durante a requisição
      print('Erro ao buscar series: $e');
      // Você pode mostrar uma mensagem ao usuário aqui, se necessário
    }
  }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pesquisar Series'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Pesquisar Serie',
                suffixIcon: Icon(Icons.search),
              ),
              onChanged: (_) => _searchSeries(),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _series.length,
              itemBuilder: (context, index) {
                return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(8.0),
                      leading: Image.network(
                        _series[index].imagemUrl,
                        width: 75,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                      title: Text(_series[index].titulo),
                      onTap: () {
                        // Retorna a serie selecionado para a tela de adição
                        print(_series[index]);
                        _saveSerieToFirestore(_series[index]);
                        Navigator.pop(context, _series[index]);
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

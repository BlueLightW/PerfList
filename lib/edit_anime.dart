import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:perf_list/anime.dart';


class EditAnimeScreen extends StatefulWidget {
  final Anime anime;
  final String lista;

  const EditAnimeScreen({super.key, required this.anime, required this.lista});

  @override
  _EditAnimeScreenState createState() => _EditAnimeScreenState();
}

class _EditAnimeScreenState extends State<EditAnimeScreen> {
  int _lastEpisode = 20; // Último episódio assistido
  String user_uid = FirebaseAuth.instance.currentUser!.uid;
  String? _selectedStatus;
  

  @override
  void initState() {
    super.initState();
    // Inicializa o estado com os dados do anime
    _lastEpisode = widget.anime.ultimoEpisodio;
  }



  Future<void> _updateAnimeInFirestore() async {
    final uid = user_uid;
    final animeData = {
      'nome': widget.anime.title,
      'imagem': widget.anime.imageUrl,
      'status': _selectedStatus,
      'ultimo_episodio': _lastEpisode,
      'id': widget.anime.id,
    };
  try{
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('listas')
        .doc('animes')
        .collection('animes')
        .doc(widget.lista)
        .collection('animeList') // Use o ID do anime para atualizar
        .doc(widget.anime.id) 
        .update(animeData);
  } catch(e){
    print('Erro ao atualizar o anime: $e');
  }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar ${widget.anime.title}'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Título: ${widget.anime.title}'),
            // CheckboxListTile(
            //   title: const Text('Assistido'),
            //   value: _isWatched,
            //   onChanged: (bool? value) {
            //     setState(() {
            //       _isWatched = value ?? false;
            //     });
            //   },
            // ),
            DropdownButton<String>(
              value: _selectedStatus,
              hint: const Text('Selecione o status'),
              items: <String>['Completo', 'Assistindo', 'Não comecei']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedStatus = newValue; // Atualiza o status selecionado
                });
              },
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Último Episódio Assistido'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _lastEpisode = int.tryParse(value) ?? 0; // Atualiza o último episódio
              },
            ),
            ElevatedButton(
              onPressed: () async {
                await _updateAnimeInFirestore(); // Atualiza o anime no Firestore
                Navigator.pop(context); // Volta para a tela anterior
              },
              child: const Text('Salvar Alterações'),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:perf_list/serie.dart';


class EditSerieScreen extends StatefulWidget {
  final Serie serie;
  final String lista;

  const EditSerieScreen({super.key, required this.serie, required this.lista});

  @override
  _EditSerieScreenState createState() => _EditSerieScreenState();
}

class _EditSerieScreenState extends State<EditSerieScreen> {
  int _lastEpisode = 20; // Último episódio assistido
  String user_uid = FirebaseAuth.instance.currentUser!.uid;
  String? _selectedStatus;
  

  @override
  void initState() {
    super.initState();
    // Inicializa o estado com os dados da serie
    _lastEpisode = widget.serie.ultimoEpisodio;
  }



  Future<void> _updateSerieInFirestore() async {
    final uid = user_uid;
    final serieData = {
      'nome': widget.serie.titulo,
      'imagem': widget.serie.imagemUrl,
      'status': _selectedStatus,
      'ultimo_episodio': _lastEpisode,
      'id': widget.serie.id,
    };
    print('uid: $uid, serieData: $serieData');

  try{
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('listas')
        .doc('series')
        .collection('series')
        .doc(widget.lista)
        .collection('serieList') // Use o ID do serie para atualizar
        .doc(widget.serie.id) 
        .update(serieData);
  } catch(e){
    print('Erro ao atualizar o serie: $e');
  }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar ${widget.serie.titulo}'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Título: ${widget.serie.titulo}'),
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
                await _updateSerieInFirestore(); // Atualiza a serie no Firestore
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
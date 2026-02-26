// edit_filme.dart
import 'package:flutter/material.dart';
import 'filme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';




class EditFilmeScreen extends StatefulWidget {
  final Filme filme;
  final String lista;

  const EditFilmeScreen({super.key, required this.filme, required this.lista});

  @override
  _EditFilmeScreenState createState() => _EditFilmeScreenState();
}

class _EditFilmeScreenState extends State<EditFilmeScreen> {
  String user_uid = FirebaseAuth.instance.currentUser!.uid;
  String? _selectedStatus;
  



  Future<void> _updateFilmeInFirestore() async {
    final uid = user_uid;
    final filmeData = {
      'nome': widget.filme.titulo,
      'imagem': widget.filme.imagemUrl,
      'status': _selectedStatus,
      'id': widget.filme.id,
    };
  try{
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('listas')
        .doc('filmes')
        .collection('filmes')
        .doc(widget.lista)
        .collection('filmeList') // Use o ID do filme para atualizar
        .doc(widget.filme.id) 
        .update(filmeData);
  } catch(e){
    print('Erro ao atualizar o filme: $e');
  }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar ${widget.filme.titulo}'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Título: ${widget.filme.titulo}'),
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
            // TextField(
            //   decoration: const InputDecoration(labelText: 'Último Episódio Assistido'),
            //   keyboardType: TextInputType.number,
            //   onChanged: (value) {
            //     _lastEpisode = int.tryParse(value) ?? 0; // Atualiza o último episódio
            //   },
            // ),
            ElevatedButton(
              onPressed: () async {
                await _updateFilmeInFirestore(); // Atualiza o Filme no Firestore
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
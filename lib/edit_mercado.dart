import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:perf_list/mercado.dart';


class EditMercadoScreen extends StatefulWidget {
  final Mercado mercado;
  final String lista;

  const EditMercadoScreen({super.key, required this.mercado, required this.lista});

  @override
  _EditMercadoScreenState createState() => _EditMercadoScreenState();
}

class _EditMercadoScreenState extends State<EditMercadoScreen> {
  int _quantidade = 1; // Último episódio assistido
  String user_uid = FirebaseAuth.instance.currentUser!.uid;
  String? _categoria;
  

  @override
  void initState() {
    super.initState();
    // Inicializa o estado com os dados do mercado
    _quantidade = widget.mercado.quantidade;
  }



  Future<void> _updateMercadoInFirestore() async {
    final uid = user_uid;
    final mercadoData = {
      'nome': widget.mercado.nome,
      'quantidade': _quantidade,
      'categoria': _categoria,
      'id': widget.mercado.id,
    };
  try{
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('listas')
        .doc('mercados')
        .collection('mercados')
        .doc(widget.lista)
        .collection('mercadoList') // Use o ID do mercado para atualizar
        .doc(widget.mercado.id) 
        .update(mercadoData);
  } catch(e){
    print('Erro ao atualizar o mercado: $e');
  }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar ${widget.mercado.nome}'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Título: ${widget.mercado.nome}'),
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
              value: _categoria,
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
                  _categoria = newValue; // Atualiza o status selecionado
                });
              },
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Último Episódio Assistido'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _quantidade = int.tryParse(value) ?? 0; // Atualiza o último episódio
              },
            ),
            ElevatedButton(
              onPressed: () async {
                await _updateMercadoInFirestore(); // Atualiza o mercado no Firestore
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
// add_filme.dart
import 'package:flutter/material.dart';
import 'filme.dart';
import 'filme_search.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:perf_list/edit_filme.dart';

class AddFilmeScreen extends StatefulWidget {
  final String lista;

  const AddFilmeScreen({super.key, required this.lista});

  @override
  _AddFilmeScreenState createState() => _AddFilmeScreenState();
}


class _AddFilmeScreenState extends State<AddFilmeScreen> {
  List<Filme> _addedFilmes = [];
  bool _showText = true;
  String user_uid = FirebaseAuth.instance.currentUser!=null ? FirebaseAuth.instance.currentUser!.uid : "";
  String nomeLista = '';
  final List<Filme> _selectedFilmes = [];
    @override
  void initState() {
    super.initState();
    _pegarListaDeFilmes(user_uid); // Chama a função ao carregar a página
    nomeLista = widget.lista;
  }

  Future<void> _deleteSelectedFilmes() async {
    final uid = user_uid;

    for (var filme in _selectedFilmes) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('listas')
            .doc('filmes')
            .collection('filmes')
            .doc(widget.lista)
            .collection('filmeList')
            .doc(filme.id)
            .delete();
      } catch (e) {
        print('Erro ao excluir filme: $e');
      }
    }

    setState(() {
      _addedFilmes.removeWhere((filme) => _selectedFilmes.contains(filme));
      _selectedFilmes.clear();
    });
    // Navigator.pop(context);
  }

  void _toggleSelection(Filme filme) {
    setState(() {
      if (_selectedFilmes.contains(filme)) {
        _selectedFilmes.remove(filme);
      } else {
        _selectedFilmes.add(filme);
      }
    });
  }

  Future<void> _pegarListaDeFilmes(String uid) async {
      if (uid.isEmpty) {
        print("UID está vazio.");
        return; // Retorna se o UID estiver vazio
      }

      final FirebaseFirestore firestore = FirebaseFirestore.instance;

      try {
        final snapshot = await firestore
            .collection('users')
            .doc(uid)
            .collection('listas')
            .doc('filmes')
            .collection('filmes')
            .get();

        if (snapshot.docs.isNotEmpty) {
      setState(() {
        _addedFilmes = List<Filme>.from(snapshot.docs.map((filme) {
          final data = filme.data();
          // Verifique se o campo 'title' não é nulo
          if (data['id'] != null) {
            _showText = false;
            return Filme.fromFirebase(data);        
          } else {
            print('Título do filme é nulo para o documento: ${filme['id']}');
            return null; // Ou você pode optar por lançar uma exceção ou lidar de outra forma
          }
        }).where((filme) => filme != null)); // Filtra os nulos
      });
    } else {
      print("Dados do filme não encontrados.");
    }
    } catch (e) {
        print("Erro ao pegar a lista de filmes: $e"); // Imprime o erro no console
      }
    }

  void _addFilme(Filme filme) {
    setState(() {
      _addedFilmes.add(filme);
      _showText = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(nomeLista),centerTitle: true,),
      body: Column(
        children: [
          if (_showText)
            const Text('Clique no botão abaixo para adicionar um filme à sua lista.'),
          Expanded(
            child: ListView.builder(
              itemCount: _addedFilmes.length,
              itemBuilder: (context, index) {
                final filme = _addedFilmes[index];
                final isSelected = _selectedFilmes.contains(filme);
                return ListTile(
                  contentPadding: const EdgeInsets.all(8.0),
                  title: Text(_addedFilmes[index].titulo),
                  leading: (isSelected) ? const Icon(Icons.check_circle, color: Colors.green) : Image.network(
                    _addedFilmes[index].imagemUrl,
                    width: 75,
                    height: 100,
                    fit: BoxFit.cover,),
                  trailing: Text(_addedFilmes[index].status),
                  tileColor: isSelected ? Colors.lightBlueAccent : null,
                  onTap: () {
                    (isSelected) ? _toggleSelection(_addedFilmes[index],) :
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditFilmeScreen(lista: nomeLista, filme: _addedFilmes[index]),
                      ),
                    );
                  },
                  onLongPress: () => _toggleSelection(_addedFilmes[index],),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final filme = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => FilmeSearchScreen(lista: nomeLista,)),
          );
          if (filme != null) {
            _addFilme(filme);
          }
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: _selectedFilmes.isNotEmpty
          ? BottomAppBar(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${_selectedFilmes.length} selecionados'),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: _deleteSelectedFilmes, // Chama a função para excluir os animes selecionados
                  ),
                ],
              ),
            )
          : null,
    );
  }
}
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:perf_list/serie_search.dart';
import 'package:perf_list/edit_serie.dart';
import 'package:perf_list/serie.dart';
import 'package:perf_list/friend_selection.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddSerieScreen extends StatefulWidget {
  final String lista;
  const AddSerieScreen({super.key, required this.lista});

  @override
  _AddSerieScreenState createState() => _AddSerieScreenState();
}

class _AddSerieScreenState extends State<AddSerieScreen> {
  List<Serie> _addedSeries = []; // Lista para armazenar os animes adicionados
  bool _showText = true;
  String user_uid = FirebaseAuth.instance.currentUser!=null ? FirebaseAuth.instance.currentUser!.uid : "";
  String nomeLista = '';
  final List<Serie> _selectedSeries = [];

  @override
  void initState() {
    super.initState();
    _pegarListaDeSeries(user_uid);
     nomeLista = widget.lista;// Chama a função ao carregar a página
  }

  void _addSerie(Serie serie) {
    print('Adicionando serie: ${serie.id}');
    setState(() {
      
      _addedSeries.add(serie);
      _showText = false;
    });
  }
Future<void> _deleteSelectedSeries() async {
    final uid = user_uid;

    for (var filme in _selectedSeries) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('listas')
            .doc('series')
            .collection('series')
            .doc(widget.lista)
            .collection('serieList')
            .doc(filme.id)
            .delete();
      } catch (e) {
        print('Erro ao excluir serie: $e');
      }
    }

    setState(() {
      _addedSeries.removeWhere((serie) => _selectedSeries.contains(serie));
      _selectedSeries.clear();
    });
    // Navigator.pop(context);
  }

  void _toggleSelection(Serie serie) {
    setState(() {
      if (_selectedSeries.contains(serie)) {
        _selectedSeries.remove(serie);
      } else {
        _selectedSeries.add(serie);
      }
    });
  }


Future<void> _pegarListaDeSeries(String uid) async {
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
        .doc('series')
        .collection('series')
        .doc(widget.lista)
        .collection('serieList')
        .get();

    if (snapshot.docs.isNotEmpty) {
  setState(() {
    _addedSeries = List<Serie>.from(snapshot.docs.map((serie) {
      final data = serie.data();
      // Verifique se o campo 'title' não é nulo
      if (data['id'] != null) {
        _showText = false;
        return Serie.fromFirebase(data);        
      } else {
        print('Título do serie é nulo para o documento: ${serie['id']}');
        return null; // Ou você pode optar por lançar uma exceção ou lidar de outra forma
      }
    }).where((serie) => serie != null)); // Filtra os nulos
  });
} else {
  print("Dados de serie não encontrados.");
}
} catch (e) {
    print("Erro ao pegar a lista de series: $e"); // Imprime o erro no console
  }
}
  Future<void> _saveSerieToFirestore(Serie serie) async {
    final uid = user_uid; // Substitua pelo UID do usuário autenticado
    final serieData = serie.toJson();
    
      // Função para criar um ID de documento a partir do título
    String generateDocumentId(String title) {
      // Remove caracteres inválidos e substitui espaços por underscores
      final documentId = title
          .replaceAll(RegExp(r'[^a-zA-Z0-9 ]'), '')
          .replaceAll(' ', '_')
          .toLowerCase();

      return documentId.isEmpty ? 'default_id' : documentId;
    }

    String documentId = generateDocumentId(serieData['title']);
    serieData['id'] = documentId;

    try {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('listas')
        .doc('series')
        .collection('series')
        .doc(widget.lista)
        .collection('serieList')
        .doc(documentId)
        .set(serieData);
    } catch (e) {
    print('Erro ao salvar serie: $e'); // Imprime o erro no console
  }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(nomeLista),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () async {
              final selectedFriends = await Navigator.push<List<String>>(
                context,
                MaterialPageRoute(
                    builder: (context) => const FriendSelectionPage()),
              );

              if (selectedFriends != null && selectedFriends.isNotEmpty) {
                final currentUser = FirebaseAuth.instance.currentUser;
                if (currentUser == null) return;

                final listId = widget.lista;
                const listType = 'series';
                final ownerUid = currentUser.uid;
                final ownerNickname =
                    currentUser.displayName ?? 'Usuário Anônimo';

                final listDoc = await FirebaseFirestore.instance
                    .collection('users')
                    .doc(ownerUid)
                    .collection('listas')
                    .doc(listType)
                    .collection(listType)
                    .doc(listId)
                    .get();

                final listName = listDoc.data()?['nome'] ?? 'Lista sem nome';

                WriteBatch batch = FirebaseFirestore.instance.batch();

                for (String friendUid in selectedFriends) {
                  DocumentReference sharedListRef =
                      FirebaseFirestore.instance.collection('shared_lists').doc();
                  batch.set(sharedListRef, {
                    'ownerUid': ownerUid,
                    'ownerNickname': ownerNickname,
                    'sharedWithUid': friendUid,
                    'listId': listId,
                    'listName': listName,
                    'listType': listType,
                    'sharedAt': FieldValue.serverTimestamp(),
                  });
                }

                await batch.commit();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Lista compartilhada com sucesso!')),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_showText)
           const Column(
              children: [
                Opacity(
                  opacity: 0.7, // Define a opacidade do texto
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Clique no botão abaixo para adicionar um serie à sua lista. Você poderá selecionar um serie da pesquisa.',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                SizedBox(height: 8), // Espaço entre o texto e a seta
                Icon(Icons.arrow_downward, size: 30), // Seta apontando para baixo
              ],
            ),
            Expanded(
            child: ListView.builder(
              itemCount: _addedSeries.length,
              itemBuilder: (context, index) {
                final serie = _addedSeries[index];
                final isSelected = _selectedSeries.contains(serie);
                return ListTile(
                  title: Text(_addedSeries[index].titulo),
                  contentPadding: const EdgeInsets.all(8.0),
                  leading: (isSelected) ? const Icon(Icons.check_circle, color: Colors.green) : Image.network(
                        _addedSeries[index].imagemUrl,
                        width: 75,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                  trailing: Padding(
                    padding: const EdgeInsets.only(right: 16.0), // Ajuste o valor conforme necessário
                    child: Text(_addedSeries[index].status),
                  ),
                  tileColor: isSelected ? Colors.lightBlueAccent : null,
                  onTap: () {
                    (isSelected) ? _toggleSelection(_addedSeries[index],) :
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditSerieScreen(lista: nomeLista, serie: _addedSeries[index]),
                      ),
                    );// Aqui você pode adicionar a lógica para editar o serie, se necessário
                  },
                  onLongPress: () => _toggleSelection(_addedSeries[index],),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
            onPressed: () async {
                  final serie = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SerieSearchScreen(lista: nomeLista,)),
                  );
                  if (serie != null) {
                    _addSerie(serie);
                    // await _saveSerieToFirestore(anime); // Salva o anime no Firestore
                  }
                }, // Ícone do botão flutuante
            tooltip: 'Adicionar Serie',
            child: const Icon(Icons.add), // Dica de ferramenta
      ),
      bottomNavigationBar: _selectedSeries.isNotEmpty
          ? BottomAppBar(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${_selectedSeries.length} selecionados'),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: _deleteSelectedSeries, // Chama a função para excluir os animes selecionados
                  ),
                ],
              ),
            )
          : null,
    );
  }
}
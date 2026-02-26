import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:perf_list/anime_search.dart';
import 'package:perf_list/edit_anime.dart';
import 'package:perf_list/anime.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:perf_list/friend_selection.dart';

class AddAnimeScreen extends StatefulWidget {
  final String lista;
  const AddAnimeScreen({super.key, required this.lista});

  @override
  _AddAnimeScreenState createState() => _AddAnimeScreenState();
}

class _AddAnimeScreenState extends State<AddAnimeScreen> {
  List<Anime> _addedAnimes = []; // Lista para armazenar os animes adicionados
  bool _showText = true;
  String user_uid = FirebaseAuth.instance.currentUser!=null ? FirebaseAuth.instance.currentUser!.uid : "";
  String nomeLista = '';
  final List<Anime> _selectedAnimes = [];

  @override
  void initState() {
    super.initState();
    _pegarListaDeAnimes(user_uid);
     nomeLista = widget.lista;// Chama a função ao carregar a página
  }

  void _addAnime(Anime anime) {
    print('Adicionando anime: ${anime.id}');
    setState(() {
      
      _addedAnimes.add(anime);
      _showText = false;
    });
  }

 Future<void> _deleteSelectedAnimes() async {
    final uid = user_uid;

    for (var anime in _selectedAnimes) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('listas')
            .doc('animes')
            .collection('animes')
            .doc(widget.lista)
            .collection('animeList')
            .doc(anime.id)
            .delete();
      } catch (e) {
        print('Erro ao excluir anime: $e');
      }
    }

    setState(() {
      _addedAnimes.removeWhere((anime) => _selectedAnimes.contains(anime));
      _selectedAnimes.clear();
    });
    // Navigator.pop(context);
  }

  void _toggleSelection(Anime anime) {
    setState(() {
      if (_selectedAnimes.contains(anime)) {
        _selectedAnimes.remove(anime);
      } else {
        _selectedAnimes.add(anime);
      }
    });
  }

Future<void> _pegarListaDeAnimes(String uid) async {
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
        .doc('animes')
        .collection('animes')
        .doc(widget.lista)
        .collection('animeList')
        .get();

    if (snapshot.docs.isNotEmpty) {
  setState(() {
    _addedAnimes = List<Anime>.from(snapshot.docs.map((anime) {
      final data = anime.data();
      // Verifique se o campo 'title' não é nulo
      if (data['id'] != null) {
        _showText = false;
        return Anime.fromFirebase(data);        
      } else {
        print('Título do anime é nulo para o documento: ${anime['id']}');
        return null; // Ou você pode optar por lançar uma exceção ou lidar de outra forma
      }
    }).where((anime) => anime != null)); // Filtra os nulos
  });
} else {
  print("Dados de anime não encontrados.");
}
} catch (e) {
    print("Erro ao pegar a lista de animes: $e"); // Imprime o erro no console
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
                const listType = 'animes';
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
                      'Clique no botão abaixo para adicionar um anime à sua lista. Você poderá selecionar um anime da pesquisa.',
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
              itemCount: _addedAnimes.length,
              itemBuilder: (context, index) {
                final anime = _addedAnimes[index];
                final isSelected = _selectedAnimes.contains(anime);
                
                return ListTile(
                  title: Text(_addedAnimes[index].title),
                  contentPadding: const EdgeInsets.all(8.0),
                  leading:(isSelected) ? const Icon(Icons.check_circle, color: Colors.green) :Image.network(
                        _addedAnimes[index].imageUrl,
                        width: 75,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                  tileColor: isSelected ? Colors.lightBlueAccent : null,
                  trailing: Padding(
                    padding: const EdgeInsets.only(right: 16.0), // Ajuste o valor conforme necessário
                    child: Text(_addedAnimes[index].status),
                  ),
                  onTap: () {
                    (isSelected)? _toggleSelection(_addedAnimes[index]):
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditAnimeScreen(lista: nomeLista, anime: _addedAnimes[index]),
                      ),
                    );// Aqui você pode adicionar a lógica para editar o anime, se necessário
                  },
                  onLongPress: () => _toggleSelection(_addedAnimes[index],),
                );
              },
            ),
          ),
          
        ],
      ),
      floatingActionButton: FloatingActionButton(
            onPressed: () async {
                  final anime = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AnimeSearchScreen(lista: nomeLista,)),
                  );
                  if (anime != null) {
                    _addAnime(anime);
                    // await _saveAnimeToFirestore(anime); // Salva o anime no Firestore
                  }
                }, // Ícone do botão flutuante
            tooltip: 'Adicionar Anime',
            child: const Icon(Icons.add), // Dica de ferramenta
      ),
      bottomNavigationBar: _selectedAnimes.isNotEmpty
          ? BottomAppBar(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${_selectedAnimes.length} selecionados'),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: _deleteSelectedAnimes, // Chama a função para excluir os animes selecionados
                  ),
                ],
              ),
            )
          : null,
    );
  }
}
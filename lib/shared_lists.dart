import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:perf_list/shared_list_items_screen.dart';

class SharedListsScreen extends StatefulWidget {
  const SharedListsScreen({Key? key}) : super(key: key);

  @override
  State<SharedListsScreen> createState() => _SharedListsScreenState();
}

class _SharedListsScreenState extends State<SharedListsScreen> {
  final _currentUser = FirebaseAuth.instance.currentUser;

  Stream<QuerySnapshot>? _sharedListsStream;

  @override
  void initState() {
    super.initState();
    if (_currentUser != null) {
      _sharedListsStream = FirebaseFirestore.instance
          .collection('shared_lists')
          .where('sharedWithUid', isEqualTo: _currentUser!.uid)
          .orderBy('sharedAt', descending: true)
          .snapshots();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Compartilhados Comigo'),
        ),
        body: const Center(
          child:
              Text('Você precisa estar logado para ver as listas compartilhadas.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Compartilhados Comigo'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _sharedListsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            print('Erro ao buscar listas compartilhadas: ${snapshot.error}');
            return Center(child: Text('Ocorreu um erro: ${snapshot.error}'));

          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Nenhuma lista foi compartilhada com você ainda.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
              ),
            );
          }

          final sharedLists = snapshot.data!.docs;

          return ListView.builder(
            itemCount: sharedLists.length,
            itemBuilder: (context, index) {
              final listData =
                  sharedLists[index].data() as Map<String, dynamic>;
              final listName = listData['listName'] ?? 'Lista sem nome';
              final ownerNickname =
                  listData['ownerNickname'] ?? 'Usuário desconhecido';
              final listType = listData['listType'];
              final ownerUid = listData['ownerUid'];
              final listId = listData['listId'];

              IconData iconData;
              switch (listType) {
                case 'animes':
                  iconData = Icons.tv;
                  break;
                case 'filmes':
                  iconData = Icons.movie;
                  break;
                case 'series':
                  iconData = Icons.live_tv;
                  break;
                case 'mercados':
                  iconData = Icons.shopping_cart;
                  break;
                default:
                  iconData = Icons.list;
              }

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: Icon(iconData, color: Theme.of(context).primaryColor),
                  title: Text(listName),
                  subtitle: Text('Compartilhado por: $ownerNickname'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SharedListItemsScreen(
                          ownerUid: ownerUid,
                          listId: listId,
                          listName: listName,
                          listType: listType,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

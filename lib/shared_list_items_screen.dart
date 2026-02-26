import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:perf_list/anime.dart';
import 'package:perf_list/filme.dart';
import 'package:perf_list/mercado.dart';
import 'package:perf_list/serie.dart';

class SharedListItemsScreen extends StatefulWidget {
  final String ownerUid;
  final String listId;
  final String listName;
  final String listType;

  const SharedListItemsScreen({
    Key? key,
    required this.ownerUid,
    required this.listId,
    required this.listName,
    required this.listType,
  }) : super(key: key);

  @override
  State<SharedListItemsScreen> createState() => _SharedListItemsScreenState();
}

class _SharedListItemsScreenState extends State<SharedListItemsScreen> {
  Stream<QuerySnapshot>? _itemsStream;

  @override
  void initState() {
    super.initState();
    String itemsCollectionName;
    switch (widget.listType) {
      case 'animes':
        itemsCollectionName = 'animeList';
        break;
      case 'filmes':
        itemsCollectionName = 'filmeList';
        break;
      case 'series':
        itemsCollectionName = 'serieList';
        break;
      case 'mercados':
        itemsCollectionName = 'mercadoList';
        break;
      default:
        itemsCollectionName = '';
    }

    if (itemsCollectionName.isNotEmpty) {
      _itemsStream = FirebaseFirestore.instance
          .collection('users')
          .doc(widget.ownerUid)
          .collection('listas')
          .doc(widget.listType)
          .collection(widget.listType)
          .doc(widget.listId)
          .collection(itemsCollectionName)
          .snapshots();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.listName),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _itemsStream,
        builder: (context, snapshot) {
          if (_itemsStream == null) {
            return const Center(
              child: Text('Tipo de lista desconhecido.'),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Ocorreu um erro: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Esta lista compartilhada está vazia.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
              ),
            );
          }

          final items = snapshot.data!.docs;

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final itemData = items[index].data() as Map<String, dynamic>;
              return _buildListItem(context, itemData);
            },
          );
        },
      ),
    );
  }

  Widget _buildListItem(BuildContext context, Map<String, dynamic> data) {
    switch (widget.listType) {
      case 'animes':
        final anime = Anime.fromFirebase(data);
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: ListTile(
            leading: Image.network(anime.imageUrl,
                width: 75, height: 100, fit: BoxFit.cover),
            title: Text(anime.title),
            trailing: Text(anime.status),
          ),
        );
      case 'filmes':
        final filme = Filme.fromFirebase(data);
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: ListTile(
            leading: Image.network(filme.imagemUrl,
                width: 75, height: 100, fit: BoxFit.cover),
            title: Text(filme.titulo),
            trailing: Text(filme.status),
          ),
        );
      case 'series':
        final serie = Serie.fromFirebase(data);
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: ListTile(
            leading: Image.network(serie.imagemUrl,
                width: 75, height: 100, fit: BoxFit.cover),
            title: Text(serie.titulo),
            trailing: Text(serie.status),
          ),
        );
      case 'mercados':
        final mercado = Mercado.fromFirebase(data);
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: ListTile(
            leading:
                Icon(Icons.shopping_cart, color: Theme.of(context).primaryColor),
            title: Text(mercado.nome),
            trailing: Text('Qtd: ${mercado.quantidade}'),
          ),
        );
      default:
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: ListTile(
            title: Text(data.toString()),
          ),
        );
    }
  }
}
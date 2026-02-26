import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ItemListScreen extends StatefulWidget {
  final String category;

  const ItemListScreen({super.key, required this.category});

  @override
  _ItemListScreenState createState() => _ItemListScreenState();
}

class _ItemListScreenState extends State<ItemListScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _items = [];

  void _searchItems() async {
    final query = _searchController.text;
    if (query.isNotEmpty) {
      final snapshot = await FirebaseFirestore.instance
          .collection(widget.category)
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: '$query\uf8ff')
          .get();

      setState(() {
        _items = snapshot.docs.map((doc) => doc['name'] as String).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pesquisar ${widget.category}'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Pesquisar',
                suffixIcon: Icon(Icons.search),
              ),
              onSubmitted: (_) => _searchItems(),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _items.length,
 itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_items[index]),
                  onTap: () {
                    // Aqui você pode adicionar a lógica para adicionar o item à lista do usuário
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
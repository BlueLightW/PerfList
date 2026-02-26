import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:perf_list/mercado_cadastro.dart';
import 'package:perf_list/edit_mercado.dart';
import 'package:perf_list/friend_selection.dart';
import 'package:perf_list/mercado.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddMercadoScreen extends StatefulWidget {
  final String lista;
  const AddMercadoScreen({super.key, required this.lista});

  @override
  _AddMercadoScreenState createState() => _AddMercadoScreenState();
}

class _AddMercadoScreenState extends State<AddMercadoScreen> {
  List<Mercado> _addedMercados = []; // Lista para armazenar os mercados adicionados
  bool _showText = true;
  String user_uid = FirebaseAuth.instance.currentUser!=null ? FirebaseAuth.instance.currentUser!.uid : "";
  String nomeLista = '';
  final List<Mercado> _selectedMercados = [];

  @override
  void initState() {
    super.initState();
    _pegarListaDeMercados(user_uid);
     nomeLista = widget.lista;// Chama a função ao carregar a página
  }

  void _addMercado(Mercado mercado) {
    print('Adicionando mercado: ${mercado.id}');
    setState(() {
      
      _addedMercados.add(mercado);
      _showText = false;
    });
  }

 Future<void> _deleteSelectedMercados() async {
    final uid = user_uid;

    for (var mercado in _selectedMercados) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('listas')
            .doc('mercados')
            .collection('mercados')
            .doc(widget.lista)
            .collection('mercadoList')
            .doc(mercado.id)
            .delete();
      } catch (e) {
        print('Erro ao excluir item: $e');
      }
    }

    setState(() {
      _addedMercados.removeWhere((mercado) => _selectedMercados.contains(mercado));
      _selectedMercados.clear();
    });
    // Navigator.pop(context);
  }

  void _toggleSelection(Mercado mercado) {
    setState(() {
      if (_selectedMercados.contains(mercado)) {
        _selectedMercados.remove(mercado);
      } else {
        _selectedMercados.add(mercado);
      }
    });
  }

Future<void> _pegarListaDeMercados(String uid) async {
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
        .doc('mercados')
        .collection('mercados')
        .doc(widget.lista)
        .collection('mercadoList')
        .get();

    if (snapshot.docs.isNotEmpty) {
  setState(() {
    _addedMercados = List<Mercado>.from(snapshot.docs.map((mercado) {
      final data = mercado.data();
      // Verifique se o campo 'title' não é nulo
      if (data['id'] != null) {
        _showText = false;
        return Mercado.fromFirebase(data);        
      } else {
        print('Título do mercado é nulo para o documento: ${mercado['id']}');
        return null; // Ou você pode optar por lançar uma exceção ou lidar de outra forma
      }
    }).where((mercado) => mercado != null)); // Filtra os nulos
  });
} else {
  print("Dados de item não encontrados.");
}
} catch (e) {
    print("Erro ao pegar a lista de itens: $e"); // Imprime o erro no console
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
                const listType = 'mercados';
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
                      'Clique no botão abaixo para adicionar um item à sua lista. Você poderá selecionar um anime da pesquisa.',
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
              itemCount: _addedMercados.length,
              itemBuilder: (context, index) {
                final mercado = _addedMercados[index];
                final isSelected = _selectedMercados.contains(mercado);
                
                return ListTile(
                  title: Text(_addedMercados[index].nome),
                  contentPadding: const EdgeInsets.all(8.0),
                  // leading:(isSelected) ? Icon(Icons.check_circle, color: Colors.green) :Image.network(
                  //       _addedMercados[index].imageUrl,
                  //       width: 75,
                  //       height: 100,
                  //       fit: BoxFit.cover,
                  //     ),
                  tileColor: isSelected ? Colors.lightBlueAccent : null,
                  trailing: Padding(
                    padding: const EdgeInsets.only(right: 16.0), // Ajuste o valor conforme necessário
                    child: Text('${_addedMercados[index].quantidade}'),
                  ),
                  onTap: () {
                    (isSelected)? _toggleSelection(_addedMercados[index]):
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditMercadoScreen(lista: nomeLista, mercado: _addedMercados[index]),
                      ),
                    );// Aqui você pode adicionar a lógica para editar o mercado, se necessário
                  },
                  onLongPress: () => _toggleSelection(_addedMercados[index],),
                );
              },
            ),
          ),
          
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //       onPressed: () async {
      //             final mercado = await Navigator.push(
      //               context,
      //               MaterialPageRoute(builder: (context) => MercadoSearchScreen(lista: nomeLista,)),
      //             );
      //             if (mercado != null) {
      //               _addMercado(mercado);
                    
      //             }
      //           },
      //       child: const Icon(Icons.add), // Ícone do botão flutuante
      //       tooltip: 'Adicionar Mercado', // Dica de ferramenta
      // ),
      bottomNavigationBar: _selectedMercados.isNotEmpty
          ? BottomAppBar(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${_selectedMercados.length} selecionados'),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: _deleteSelectedMercados, // Chama a função para excluir os animes selecionados
                  ),
                ],
              ),
            )
          : null,
    );
  }
}
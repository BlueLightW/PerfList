import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:perf_list/add_serie.dart';

class CreateListSeriesScreen extends StatefulWidget {
  const CreateListSeriesScreen({super.key});

  @override
  _CreateListSeriesScreenState createState() => _CreateListSeriesScreenState();
}

class _CreateListSeriesScreenState extends State<CreateListSeriesScreen> {
  final TextEditingController _listNameController = TextEditingController();
  String userUid = FirebaseAuth.instance.currentUser  != null ? FirebaseAuth.instance.currentUser !.uid : "";
  bool _showInputFields = false; // Controla a exibição dos campos de entrada
  int numeroSeries = 0;
  List selecionadas = [];
  bool showDeleteBar = false;
  @override
  void initState() {
    super.initState();
    _pegarListasCriadas(); // Chama a função para pegar as listas criadas ao iniciar
  }
  void toggleSelection(String item) {
    setState(() {
      if (selecionadas.contains(item)) {
        selecionadas.remove(item);
      } else {
        selecionadas.add(item);
      }
      showDeleteBar = selecionadas.isNotEmpty;
    });
  }
  void deleteSelected() {
    for(dynamic item in selecionadas) {
      FirebaseFirestore.instance
      .collection('users')
      .doc(userUid)
      .collection('listas')
      .doc('series').collection('series').doc(item).delete().then((_)=>print('lista removida: $item'));
      
    }
    setState(() {
      
      selecionadas.clear();
      showDeleteBar = false;
    });
  }

  Future<void> _editarLista(String listaId, String nomeAtual) async {
  final TextEditingController editController = TextEditingController(text: nomeAtual);

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Editar Nome da Lista'),
        content: TextField(
          controller: editController,
          decoration: const InputDecoration(
            labelText: 'Novo Nome',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Fecha o diálogo
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              String novoNome = editController.text.trim();
              if (novoNome.isNotEmpty) {
                await _atualizarLista(listaId, novoNome);
                Navigator.of(context).pop(); // Fecha o diálogo
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Por favor, insira um nome válido.')),
                );
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      );
    },
  );
}

Future<void> _atualizarLista(String listaId, String novoNome) async {
  final firestore = FirebaseFirestore.instance;

  try {
    // Obter os itens da lista antiga
    final snapshot = await firestore
        .collection('users')
        .doc(userUid)
        .collection('listas')
        .doc('series')
        .collection('series')
        .doc(listaId)
        .collection('serieList')
        .get();

    // Criar uma nova lista com o novo nome
    String novaListaId = novoNome.replaceAll(RegExp(r'[^a-zA-Z0-9 ]'), '').replaceAll(' ', '_').toLowerCase();
    await firestore
        .collection('users')
        .doc(userUid)
        .collection('listas')
        .doc('series')
        .collection('series')
        .doc(novaListaId)
        .set({
          'nome': novoNome,
          'dataCriacao': FieldValue.serverTimestamp(),
          'id': novaListaId,
        });

    // Copiar os itens da lista antiga para a nova
    for (var doc in snapshot.docs) {
      await firestore
          .collection('users')
          .doc(userUid)
          .collection('listas')
          .doc('series')
          .collection('series')
          .doc(novaListaId)
          .collection('serieList')
          .doc(doc.id)
          .set(doc.data());
    }

    // Excluir a lista antiga
    await firestore
        .collection('users')
        .doc(userUid)
        .collection('listas')
        .doc('series')
        .collection('series')
        .doc(listaId)
        .delete();

    print('Lista atualizada com sucesso: $novoNome');
    setState(() {}); // Atualiza a interface
  } catch (e) {
    print('Erro ao atualizar lista: $e');
  }
}

  Future<List<Map<String, dynamic>>> _pegarListasCriadas() async {
  final firestore = FirebaseFirestore.instance;

  try {
    final snapshot = await firestore
        .collection('users')
        .doc(userUid)
        .collection('listas')
        .doc('series')
        .collection('series')
        .get();
    // Mapeia os documentos para uma lista de mapas contendo os dados
    return snapshot.docs.map((doc) {
      return {
        'id': doc.id,
        'nome': doc['nome'], // Acessa o campo 'nome'
        // Adicione outros campos que você deseja acessar aqui
      };
    }).toList();
  } catch (e) {
    print('Erro ao pegar listas criadas: $e');
    return [];
  }
}

  Future<int> _pegarNumeroItens(doc) async {
     final firestore = FirebaseFirestore.instance;
    try {
      final snapshot = await firestore
          .collection('users')
          .doc(userUid)
          .collection('listas')
          .doc('series')
          .collection('series')
          .doc(doc)
          .collection('serieList')
          .get();
      print('numero de series para a lista $doc: ${snapshot.docs.length}');
      return snapshot.docs.length;
    } catch (e) {
      print('Erro ao pegar listas criadas: $e');
      return 0;
    }
  }

  Future<void> criarListaPersonalizada(String nomeLista) async {
    final firestore = FirebaseFirestore.instance;
    String listaFormatada = nomeLista
              .replaceAll(RegExp(r'[^a-zA-Z0-9 ]'), '')
              .replaceAll(' ', '_')
              .toLowerCase();
    try {
      await firestore
          .collection('users')
          .doc(userUid)
          .collection('listas')
          .doc('series')
          .collection('series') // Usa o nome da lista como o nome da coleção
          .doc(listaFormatada) // Cria um documento vazio dentro da nova coleção
          .set({
            'nome': nomeLista,
            'dataCriacao': FieldValue.serverTimestamp(),
            'id': listaFormatada,
          });

      print('Lista personalizada criada com sucesso: $nomeLista');
      _listNameController.clear(); // Limpa o campo de texto
      _pegarListasCriadas(); // Atualiza a lista de listas criadas
    } catch (e) {
      print('Erro ao criar lista personalizada: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar Lista de Séries'),centerTitle: true,),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // ElevatedButton(
            //   onPressed: () {
            //     setState(() {
            //       _showInputFields = !_showInputFields; // Alterna a exibição dos campos
            //     });
            //   },
            //   child: const Text('Criar Lista'),
            // ),
            if (_showInputFields) ...[
              TextField(
                controller: _listNameController,
                decoration: const InputDecoration(
                  labelText: 'Nome da Lista',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  String nomeLista = _listNameController.text.trim();
                  if (nomeLista.isNotEmpty) {
                    criarListaPersonalizada(nomeLista);
                  } else {
                    // Exibir um alerta se o nome da lista estiver vazio
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Por favor, insira um nome para a lista.')),
                    );
                  }
                  setState(() {
                    _showInputFields = !_showInputFields;
                  });
                },
                icon: const Icon(Icons.send), // Ícone de enviar
                label: const Text('Enviar'),
              ),
            ],
            const SizedBox(height: 20),
            const Text('Listas Criadas:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _pegarListasCriadas(), // Chama a função para pegar as listas
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Erro: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Nenhuma lista criada.'));
                  }

                  // Aqui você pode usar as listas criadas
                  List<Map<String, dynamic>> listasCriadas = snapshot.data!;
                  return ListView.builder(
                    itemCount: listasCriadas.length,
                    itemBuilder: (context, index) {
                      return FutureBuilder<int>(
                        future: _pegarNumeroItens(listasCriadas[index]['id']), // Chama a função para pegar o número de itens
                        builder: (context, snapshot) {
                          bool isSelected = selecionadas.contains(listasCriadas[index]['id']);
                          print(selecionadas);
                          return ListTile(
                            title: Row(
                              children: [
                                Text(
                                  listasCriadas[index]['nome'],
                                  style: isSelected ? const TextStyle(fontSize: 14) : const TextStyle(fontSize: 16), // Tamanho do texto
                                ),
                                IconButton(
                                  onPressed: () => _editarLista(listasCriadas[index]['id'], listasCriadas[index]['nome']),
                                  icon: const Icon(Icons.edit),
                                ),
                              ],
                            ),
                            leading: isSelected
                                ? const Icon(Icons.check_circle, color: Colors.green) // Ícone quando selecionado
                                : null,
                            tileColor: isSelected ? Colors.lightBlueAccent : null, // Cor de fundo quando selecionado
                            trailing: snapshot.connectionState == ConnectionState.waiting
                                ? const CircularProgressIndicator()
                                : snapshot.hasError
                                    ? const Text('Erro')
                                    : Text('${snapshot.data ?? 0} series'),
                            onTap: () {
                              (isSelected) ? toggleSelection(listasCriadas[index]['id'])
                              : Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddSerieScreen(lista: listasCriadas[index]['id']),
                                ),
                              );
                            },
                            selected: isSelected,
                            onLongPress: () {
                              print(isSelected);
                              print(listasCriadas[index].toString());
                              toggleSelection(listasCriadas[index]['id']);
                            },
                          );

                        },
                      );
                    },
                  );
                },
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _showInputFields = !_showInputFields; // Alterna a exibição dos campos
                });
              },
              style: ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 24), padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 26.0)),
              child: const Text('Criar Lista'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: showDeleteBar
          ? BottomAppBar(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${selecionadas.length} selecionadas'),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: deleteSelected,
                  ),
                ],
              ),
            )
          : null,
    );
  }
}
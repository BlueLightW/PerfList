import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:perf_list/pesquisa_perfis.dart';
import 'package:perf_list/perfil_outros.dart';

class AmigosScreen extends StatefulWidget {
  const AmigosScreen({super.key});

  @override
  _AmigosScreenState createState() => _AmigosScreenState();
}

class _AmigosScreenState extends State<AmigosScreen> {
  int amigosCount = 0; // Contador de amigos
  final String uid = FirebaseAuth.instance.currentUser!.uid; // UID do usuário atual
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<Map<String, dynamic>> _amigosData = [];
  DocumentSnapshot? _documentSnapshot;

  @override
  void initState() {
    super.initState();
    _getAmigosCount(); 
    _fetchAmigosData(); // Chama a função para obter a contagem de amigos
  }

  Future<void> _getAmigosCount() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (doc.exists) {
        List<dynamic> amigos = doc['amigos'] ?? []; // Obtém a lista de amigos
        setState(() {
          amigosCount = amigos.length; // Atualiza a contagem de amigos
        });
      }
    } catch (e) {
      print("Erro ao obter a contagem de amigos: $e");
    }
  }

  Future<void> _fetchAmigosData() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      print("Usuário não autenticado");
      return; // Ou trate o erro de acordo
    }
    
    String currentUserUid = currentUser.uid;

    try {
      final userDoc = await _firestore.collection('users').doc(currentUserUid).get();
      
      if (!userDoc.exists) {
        print("Documento do usuário não encontrado");
        return; // Ou trate o erro de acordo
      }

      List<dynamic> amigosUids = userDoc['amigos'] ?? [];
      _amigosData.clear();

      if (amigosUids.isNotEmpty) {
        List<Future<DocumentSnapshot>> amigoFutures = amigosUids.map((amigoUid) {
          return _firestore.collection('users').doc(amigoUid).get();
        }).toList();

        List<DocumentSnapshot> amigoDocs = await Future.wait(amigoFutures);
        for (DocumentSnapshot amigoDoc in amigoDocs) {
          if (amigoDoc.exists) {
            _amigosData.add(amigoDoc.data() as Map<String, dynamic>);
          }
        }
      }
    } catch (e) {
      print("Erro ao buscar documento do usuário: $e");
    }

    setState(() {});
  }

  Future<void> _profile(uid) async {
    DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
    setState(() {
      _documentSnapshot = userDoc;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Amigos: $amigosCount',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TelaPesquisar()),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Adicionar Amigos'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            amigosCount == 0
              ? const Text(
                  'Você não adicionou nenhum amigo ainda',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                )
              : Expanded(
                  child: ListView.builder(
                    itemCount: _amigosData.length,
                    itemBuilder: (context, index) {
                      var amigo = _amigosData[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          title: Text(amigo['nickname']),
                          subtitle: Text(amigo['genero']),
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(amigo['profileImage'] ?? ''),
                          ),
                          onTap: () async {
                            await _profile(amigo['uid']);
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => UserProfileDisplayScreen(userProfile: _documentSnapshot!)),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

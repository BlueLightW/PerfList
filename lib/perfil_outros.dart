import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProfileDisplayScreen extends StatefulWidget {
  final DocumentSnapshot userProfile;

  const UserProfileDisplayScreen({super.key, required this.userProfile});

  @override
  State<UserProfileDisplayScreen> createState() => _UserProfileDisplayScreenState();
}

class _UserProfileDisplayScreenState extends State<UserProfileDisplayScreen> {
  @override
  void initState() {
    super.initState();
    _getListaAmigos();
  }

  final _firestore = FirebaseFirestore.instance;
  List<String> _listaAmigos = [];
  bool isLoading = true;

  Future<void> _getListaAmigos() async {
    try {
      final snapshot = await _firestore.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).get();
      if (!snapshot.exists) {
        print('Documento do usuário não encontrado');
        setState(() {
          isLoading = false;
        });
        return;
      }
      final data = snapshot.data() as Map<String, dynamic>;
      print('data2: ${data['amigos']}');
      setState(() {
        _listaAmigos = List<String>.from(data['amigos'] ?? []);
        isLoading = false;
      });
    } catch (e) {
      print('Erro ao buscar lista de amigos: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> adicionarAmigo() async {
    if (widget.userProfile['uid'] != FirebaseAuth.instance.currentUser!.uid) {
      try {
        if (!_listaAmigos.contains(widget.userProfile['uid'])) {
          await _firestore.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).update({
            'amigos': FieldValue.arrayUnion([widget.userProfile['uid']])
          });
        } else {
          print('Usuário já é amigo.');
        }
      } catch (e) {
        print('Erro ao adicionar amigo: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String nickname = widget.userProfile['nickname'] ?? 'Nome não disponível';
    String? profileImageUrl = widget.userProfile['profileImage'];
    DateTime dataNascimento = (widget.userProfile['data_nascimento'] as Timestamp?)?.toDate() ?? DateTime.now();
    String genero = widget.userProfile['genero'] ?? 'Informação não disponível';
    String uid = widget.userProfile['uid'] ?? 'Informação não disponível';

    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Carregando...'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(nickname),
        centerTitle: true,
        actions: [
          _listaAmigos.contains(widget.userProfile['uid']) ? const SizedBox() :
          FirebaseAuth.instance.currentUser!.uid == widget.userProfile['uid'] ?
          const SizedBox() : ElevatedButton.icon(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await adicionarAmigo();
              Navigator.pop(context); // Volta para a HomeScreen
            },
            label: const Text('Adicionar como amigo'),
          )
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 110,
                backgroundImage: profileImageUrl != null ? NetworkImage(profileImageUrl) : null,
                child: profileImageUrl == null ? const Icon(Icons.person, size: 50) : null,
              ),
              const SizedBox(height: 20),
              Text(
                nickname,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              _buildInfoCard('Data de nascimento: ', DateFormat('dd-MM-yyyy').format(dataNascimento)),
              _buildInfoCard('Genero: ', genero),

              // Use o StreamBuilder para escutar as listas
              StreamBuilder<List<int>>(
                stream: _getUserListsStream(uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Erro: ${snapshot.error}');
                  } else if (!snapshot.hasData) {
                    return const Text('Nenhum dado encontrado.');
                  } else {
                    final data = snapshot.data!;
                    return lista(data[0], data[1], data[2]);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Stream<List<int>> _getUserListsStream(String userUid) async* {
    while (true) {
      try {
        var listadeAnimes = await pegarNumero(userUid, 'animes');
        var listadeFilmes = await pegarNumero(userUid, 'filmes');
        var listadeSeries = await pegarNumero(userUid, 'series');
        yield [listadeAnimes, listadeFilmes, listadeSeries];
      } catch (e) {
        yield [0, 0, 0]; // Retorna zeros em caso de erro
      }
      await Future.delayed(const Duration(seconds: 60)); // Delay para evitar chamadas excessivas
    }
  }

  Future<int> pegarNumero(String userUid, String list) async {
    try {
      final listasCollection = _firestore.collection('users').doc(userUid).collection('listas').doc(list).collection(list);
      final listasSnapshot = await listasCollection.get();
      if (listasSnapshot.docs.isEmpty) {
        print('Nenhuma lista encontrada na coleção "$list".');
        return 0;
      }
      return listasSnapshot.docs.length;
    } catch (e) {
      print('Erro ao acessar a lista de $list: $e');
      throw Exception('Falha ao buscar $list');
    }
  }

  Widget _buildInfoCard(String title, String value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(
          '$title $value',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget lista(int animes, int filmes, int series) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          ListTile(title: Text('Listas de Animes: $animes', style: const TextStyle(fontWeight: FontWeight.bold))),
          ListTile(title: Text('Listas de Filmes: $filmes', style: const TextStyle(fontWeight: FontWeight.bold))),
          ListTile(title: Text('Listas de Séries: $series', style: const TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}

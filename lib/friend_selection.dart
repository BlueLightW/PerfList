import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FriendSelectionPage extends StatefulWidget {
  const FriendSelectionPage({super.key});

  @override
  State<FriendSelectionPage> createState() => _FriendSelectionPageState();
}

class _FriendSelectionPageState extends State<FriendSelectionPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<Map<String, dynamic>> _amigosData = [];
  final List<String> _selectedFriends = [];

  @override
  void initState() {
    super.initState();
    _fetchAmigosData();
  }

  Future<void> _fetchAmigosData() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      print("Usuário não autenticado");
      return;
    }
    
    String currentUserUid = currentUser.uid;

    try {
      final userDoc = await _firestore.collection('users').doc(currentUserUid).get();
      
      if (!userDoc.exists) {
        print("Documento do usuário não encontrado");
        return;
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

  void _toggleSelection(String uid) {
    setState(() {
      if (_selectedFriends.contains(uid)) {
        _selectedFriends.remove(uid);
      } else {
        _selectedFriends.add(uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Friends'),
        actions: [
          if (_selectedFriends.isNotEmpty)
            TextButton(
              onPressed: () {
                Navigator.pop(context, _selectedFriends);
              },
              child: Text(
                'Done (${_selectedFriends.length})',
                style: const TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: ListView.separated(
        itemCount: _amigosData.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final friend = _amigosData[index];
          final isSelected = _selectedFriends.contains(friend['uid']);

          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(friend['profileImage'] ?? ''),
            ),
            title: Text(friend['nickname']),
            trailing: Checkbox(
              value: isSelected,
              onChanged: (bool? value) {
                _toggleSelection(friend['uid']);
              },
            ),
            onTap: () {
              _toggleSelection(friend['uid']);
            },
          );
        },
      ),
    );
  }
}
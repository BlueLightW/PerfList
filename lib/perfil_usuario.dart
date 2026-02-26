import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:cloudinary/cloudinary.dart';
import 'package:intl/intl.dart';

class UserProfileSreen extends StatefulWidget {
  const UserProfileSreen({super.key});

  @override
  _UserProfileSreenState createState() => _UserProfileSreenState();
}

class _UserProfileSreenState extends State<UserProfileSreen> {
  // User data with editable fields
  bool isLoading = true;
  int listaAnimes = 0;
  int listaFilmes = 0;
  int listaSeries = 0;
  String genero = '';
  DateTime dataNascimento = DateTime.now();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? nickname;
  String? profileImageUrl;
  File? _image; // Para armazenar a imagem selecionada
  final uid = FirebaseAuth.instance.currentUser!=null ? FirebaseAuth.instance.currentUser!.uid : "";
  final Cloudinary cloudinary = Cloudinary.signedConfig(
    apiKey: '579925776938761',
    apiSecret: 'mnGy_P77wFgyuyKpVm9MaJKdOxo',
    cloudName: 'dmuwqctpw',
  );
  @override
  void initState() {
    super.initState();
    _loadUserData();
    
  }
 
void _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser ;
    var listadeAnimes = await pegarNumero(uid, 'animes');
    var listadeFilmes = await pegarNumero(uid, 'filmes');
    var listadeSeries = await pegarNumero(uid, 'series');
    setState(() {
      listaAnimes = listadeAnimes;
      listaFilmes = listadeFilmes;
      listaSeries = listadeSeries;
    });
    // DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(uid).collection('user').doc('dados').get();
    DocumentSnapshot doc = await FirebaseFirestore.instance
    .collection('users')
    .doc(uid)
    .get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        setState(() {
          genero = data['genero'] ?? "Informação não disponível";
          // dataNascimento = data['data_nascimento'] ?? DateTime.now();
          if (data['data_nascimento'] is Timestamp) {
            dataNascimento = (data['data_nascimento'] as Timestamp).toDate();
          } else {
            dataNascimento = DateTime.now(); // Ou outra lógica para lidar com a ausência de data
          }
        });
      } else {
        print('Documento não encontrado');
      }
     if (user != null) {
      setState(() {
        nickname = user.displayName;
        profileImageUrl = user.photoURL;
        isLoading = false;
      });
  }
  }

  Future<int> pegarNumero(String userUid, String list) async {
    final FirebaseFirestore db = FirebaseFirestore.instance;

    try {
      final listasCollection = db.collection('users').doc(userUid).collection('listas').doc(list).collection(list);
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



String pegarDataFormatada(data) {
    final DateFormat formatter = DateFormat('dd-MM-yyyy'); // Change the format as needed
    return formatter.format(data);
  }

  // Method to show edit dialog for name
  void _editName() {
    final nameController = TextEditingController(text: nickname);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Name'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            hintText: 'Enter new name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {

              setState(() {
                nickname = nameController.text;
              });
              _saveUserInfo();
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
Future<String> _uploadImageToCloudinary( Uint8List bytes, uid) async {
      // Fazer o upload da imagem usando a biblioteca Cloudinary
      
      final response = await
        cloudinary.unsignedUpload
        (
        
        uploadPreset: 'perfil',
        fileBytes: bytes,
        resourceType: CloudinaryResourceType.image,
        folder: uid,
        fileName: 'profile-picture$uid',
        progressCallback: (count, total) {
        print(
        'Uploading image from file with progress: $count/$total');
  });


    if(response.isSuccessful) {
    print('Get your image from with ${response.secureUrl}');
    }
    return response.secureUrl!;
  }

  // Função para selecionar uma imagem
  Future<void> _selectImage() async {
    if (kIsWeb || Platform.isWindows || Platform.isMacOS) {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );
      print("pegou a imagem com sucesso");
      try {
        if (result != null) {
          if (kIsWeb) {
            Uint8List? bytes = result.files.single.bytes;
            if (bytes != null) {
              await _checkAndReplaceImage(uid,  bytes);
            } else {
              print("Erro: bytes não estão disponíveis.");
            }
          } else {
            File file = File(result.files.single.path!);
            Uint8List? bytes = result.files.single.bytes;
            print("pegou o arquivo $file");
            // Carregar a imagem no Cloudinary
            await _checkAndReplaceImage(uid, bytes!,);
          }
        }
      } catch (e) {
        print("Erro ao processar a imagem: $e");
      }
    } else {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        try {
          File file = File(pickedFile.path);
          // Carregar a imagem no Cloudinary
          await _checkAndReplaceImage(uid, await file.readAsBytes());
        } catch (e) {
          print("Erro ao processar a imagem: $e");
        }
      }
    }
  }
  Future<void> _uploadImageUrlToFirestore(String imageUrl, String publicId, String uid) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).collection('user').doc('dados').set({
      'profileImage': imageUrl,
      'publicId': publicId, // Armazene o public_id
    }, SetOptions(merge: true)).then((_){_auth.currentUser!.updatePhotoURL(imageUrl);});
    setState(() {
      profileImageUrl = imageUrl;
    });
  }
  Future<void> _deletePreviousImage(String publicId) async {
    // Excluir a imagem usando a biblioteca Cloudinary
    final response = await
      cloudinary.destroy
      (publicId,
      resourceType: CloudinaryResourceType.image,
      invalidate: false,
      );
    if(response.isSuccessful){
    //Do something else
      print("deletou com sucesso!");
    }
  }
  Future<void> _checkAndReplaceImage(String uid, Uint8List bytes) async {
    // Recuperar os dados do usuário
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(uid).collection('user').doc('dados').get();
    if (doc.exists) {
      String? publicId = doc['publicId']; // Obter o public_id da imagem anterior
      // Se houver uma imagem anterior, exclua-a
      if (publicId != null) {
        await _deletePreviousImage(publicId);
      }

      // Fazer o upload da nova imagem
      String imageUrl = await _uploadImageToCloudinary(bytes, uid);
      print('url: $imageUrl');
      // Salvar a nova URL e o public_id no Firestore
      await _uploadImageUrlToFirestore(imageUrl, publicId!, uid);
    } else {
      // Se não houver documento, você pode fazer o upload normalmente
      String imageUrl = await _uploadImageToCloudinary(bytes, uid);
      await _uploadImageUrlToFirestore(imageUrl, "profile_picture$uid", uid); // Sem public_id
    }
  }

  // Função para salvar as informações do usuário
  Future<void> _saveUserInfo() async {
    User? user = _auth.currentUser ;
    if (user != null) {
      await user.updateProfile(displayName: nickname, photoURL: profileImageUrl);
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({'nickname': nickname, 'profileImage': profileImageUrl});
      // Atualize a URL da imagem de perfil se necessário
      await user.reload();
      // Recarregue os dados do usuário
      _loadUserData();
    }
  }
  // Method to show edit dialog for profile picture URL
  void _editProfilePicture() {
    final urlController = TextEditingController(text: profileImageUrl);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile Picture'),
        content: TextField(
          controller: urlController,
          decoration: const InputDecoration(
            hintText: 'Enter new profile picture URL',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                
              });
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
        title: const Text('Perfil'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile Picture with Edit Button
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 110,
                        backgroundImage: _image != null
                            ? FileImage(_image!)
                            : (profileImageUrl != null ? NetworkImage(profileImageUrl!) : null),
                        child: _image == null && profileImageUrl == null
                            ? const Icon(Icons.person, size: 50)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: IconButton(
                          icon: const Icon(Icons.edit, color: Colors.white),
                          onPressed: _selectImage,
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.black54,
                            shape: const CircleBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
              
                  // Name with Edit Button
                  
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text(
                          nickname ?? 'Nome não disponível',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: _editName,
                        ),
                      ],
                    ),
                  
                  const SizedBox(height: 10),
              
                  // Other User Information Cards (non-editable)
                  _buildInfoCard('Data de nascimento: ', pegarDataFormatada(dataNascimento)),
                  _buildInfoCard('Genero: ', genero),
              
                   lista(listaAnimes, listaFilmes, listaSeries),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to create consistent info cards
  Widget _buildInfoCard(String title, String value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(
          '$title $value',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        // trailing: Text(value),
      ),
    );
  }

  // Helper method to format birthday
  String _formatBirthday(DateTime birthday) {
    return '${birthday.day}/${birthday.month}/${birthday.year}';
  }
  Widget lista(int animes, int filmes, int series){
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          ListTile(title: Text('Listas de Animes: $animes',style: const TextStyle(fontWeight: FontWeight.bold)),),

          ListTile(title: Text('Listas de Filmes: $filmes',style: const TextStyle(fontWeight: FontWeight.bold)),),
          ListTile(title: Text('Listas de Séries: $series',style: const TextStyle(fontWeight: FontWeight.bold)),)
        ],
      )
    );
  }

}




import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:perf_list/home_page.dart';

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  _CadastroPageState createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final _nicknameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _selectedGender;
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 142, 116, 255),
              Color.fromARGB(255, 234, 116, 255),
              Color.fromARGB(255, 245, 130, 169),
              Color.fromARGB(255, 255, 95, 83),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8.0,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Cadastro',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                _buildTextField('Nickname', false, _nicknameController),
                _buildTextField('Email', false, _emailController, isEmail: true),
                _buildTextField('Senha', true, _passwordController),
                _buildTextField('Repetir Senha', true, _confirmPasswordController),
                _buildDateField('Data de Nascimento'),
                _buildGenderDropdown(),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(10),
                  child: ElevatedButton(
                    onPressed: _registerUser ,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple[600],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text('Cadastrar', style: TextStyle(color: Colors.white, fontSize: 18)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, bool isPassword, TextEditingController controller, {bool isEmail = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Colors.purple),
          ),
        ),
        keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
      ),
    );
  }

  Widget _buildDateField(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Colors.purple),
          ),
        ),
        readOnly: true,
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(1900),
            lastDate: DateTime(2100),
          );
          if (pickedDate != null) {
            setState(() {
              _selectedDate = pickedDate; // Armazena a data selecionada
            });
          }
        },
        controller: TextEditingController(
          text: _selectedDate != null ? "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}" : '',
        ),
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: 'Gênero',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Colors.purple),
          ),
        ),
        value: _selectedGender,
        items: const [
          DropdownMenuItem(value: null, child: Text('Selecione')),
          DropdownMenuItem(value: 'masculino', child: Text('Masculino')),
          DropdownMenuItem(value: 'feminino', child: Text('Feminino')),
          DropdownMenuItem(value: 'outro', child: Text('Outro')),
        ],
        onChanged: (value) {
          setState(() {
            _selectedGender = value; // Armazena o gênero selecionado
          });
        },
      ),
    );
  }

  Future<void> _registerUser () async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    final nickname = _nicknameController.text.trim();

    if (password != confirmPassword) {
      // Exibir mensagem de erro se as senhas não coincidirem
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('As senhas não coincidem!')),
      );
      return;
    }

    try {
      final UserCredential userCredential;
      userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      print('usuário: ${userCredential.user}');
      // Aqui você pode salvar os dados adicionais do usuário no Firestore, se necessário
      
      final data = {
      'nickname': nickname,
      'data_nascimento': _selectedDate,
      'genero': _selectedGender!,
      'uid': userCredential.user?.uid, // Added null check
      'isDarkMode': false,
      'profileImage':'https://res.cloudinary.com/dmuwqctpw/image/upload/v1733852519/users/usuarios/khgd1ivd6qhpkkim3do8.jpg',
      'publicId': 'users/usuarios/khgd1ivd6qhpkkim3do8',
      'amigos': [],
      };
      await _saveUserToFirestore(data, userCredential.user?.uid).then((_) {
        print('Usuário salvo no Firestore com sucesso');
      });
      await userCredential.user?.updateDisplayName(nickname); // Added null check
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuário cadastrado com sucesso!')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } catch (e) {
      // Exibir mensagem de erro em caso de falha no cadastro
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao cadastrar: $e')),
      );
      print('Erro ao cadastrar: $e');
    }
  }
}

Future<void> _saveUserToFirestore(dados, uid) async {
    final userData = dados;
    print('printando o id: $uid');
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set(userData);
      } catch (e) {
      print('Erro ao salvar dados do usuário: $e'); // Imprime o erro no console
    }
  }

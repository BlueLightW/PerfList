import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:perf_list/home_page.dart';
import 'package:provider/provider.dart';
import 'package:perf_list/auth_provider.dart' as auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:perf_list/cadastro.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  

  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Initialize Firebase
    _initializeFirebase();
    Future.delayed(const Duration(milliseconds: 5), () {
      setState(() {
        isLoading = false;
        // Define o estado de carregamento como falso após o atraso
      });
    });
  }

  Future<void> _initializeFirebase() async {
    await Firebase.initializeApp();
    _checkUser_Session();
  }

  void _checkUser_Session() async {
    final user = FirebaseAuth.instance.currentUser ;
    if (user != null) {
      // User is already signed in, navigate to main page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      try {
        final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Captura o UID do usuário logado
        final user = credential.user;
        if (user != null) {
          
          Provider.of<auth.AuthProvider>(context, listen: false).login();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      } on FirebaseAuthException catch (e) {
        String message;
        if (e.code == 'user-not-found') {
          message = 'Não existe usuário com esse email.';
        } else if (e.code == 'wrong-password') {
          message = 'Senha incorreta para esse usuário.';
        } else {
          message = 'Ocorreu um erro, tente novamente.';
        }
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      } catch (e) {
        // Handle any other exceptions
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An unexpected error occurred.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.deepPurple,
            Colors.pinkAccent,
            
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(''),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0, // Set elevation to 0 for a seamless look
        ),
        body: Container(
          
          child: Center(
            child: Container(
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
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Login',
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(color: Colors.purple),
                            ),
                            ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, insira seu email.';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            email = value;
                          },
                          
                          
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Senha',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(color: Colors.purple),
                            ),),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, insira sua senha.';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            password = value;
                          },
                          onFieldSubmitted: (value) {
                            // Chama a função _login quando a tecla Enter é pressionada
                            _login();
                          },
                          
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            
                            FilledButton(
                              onPressed: _login,
                              child: const Text('Login', style: TextStyle(fontSize: 18)),
                            ),
                            const SizedBox(width: 10,),
                            ElevatedButton(
                              onPressed: () {
                                // Navega para a página de cadastro
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => CadastroPage()),
                                );
                              },
                              child: const Text('Cadastrar', style: TextStyle(fontSize: 18),),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
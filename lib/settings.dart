import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:perf_list/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:perf_list/login.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isDarkMode = false; // Variável para controlar o tema

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Configurações'),
      //   centerTitle: true,
      // ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text(
            //   'Configurações de Tema',
            //   style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            // ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Text('Tema: ', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 15,),
                ElevatedButton(
                  onPressed: () {
                    
                    themeProvider.toggleTheme();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: Row(
                    children: [
                      Text(isDarkMode ? 'Mudar para Tema Escuro' : 'Mudar para Tema Claro'),
                      Icon(isDarkMode ? Icons.dark_mode: Icons.light_mode),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut(); // Faz logout
                  // Aqui você pode navegar para a tela de login ou outra tela
                  Navigator.push(
                  context,
                    MaterialPageRoute(
                      builder: (context) => LoginPage(),
                    ),
                  ); // Exemplo de navegação
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 26.0),
                  textStyle: const TextStyle(fontSize: 24),
                ),
                child: Text('Logout'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
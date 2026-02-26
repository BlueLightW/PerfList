// theme_provider.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = true;

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadThemePreference();
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    _saveThemePreference();
  }

  Future<void> _loadThemePreference() async {
    User? user = FirebaseAuth.instance.currentUser ;
    if (user != null) {
      try{
      DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (snapshot.exists) {
        Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;
        _isDarkMode = data?['isDarkMode'] ?? false;
        notifyListeners();
      } else {
      // Aplicar tema padrão se o usuário não estiver logado
      _isDarkMode = false; // ou true, dependendo do seu tema padrão
      notifyListeners();
    } 
    } catch (e) {print('erro ao gravar tema: $e');} 
  }
  }
  Future<void> _saveThemePreference() async {
    User? user = FirebaseAuth.instance.currentUser ;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'isDarkMode': _isDarkMode,
      }, SetOptions(merge: true)).then((_){print('sucesso ao gravar dados');}).catchError((e){print('erro ao gravar tema: $e');}); 
    }     
  }
}
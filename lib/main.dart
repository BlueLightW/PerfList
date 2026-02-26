import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:perf_list/home_page.dart';
import 'package:provider/provider.dart';
import 'package:perf_list/login.dart';
import 'package:perf_list/theme_provider.dart';
import 'auth_provider.dart';

// Import your product list
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AuthProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => ThemeProvider(), // Adicione seu ThemeProvider aqui
        ),
      ],
      child: const MainApp(),
    )
  );
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  bool isLoading = true; // Estado de carregamento

  @override
  void initState() {
    super.initState();
    // Simula um atraso de 1 segundo
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        isLoading = false;
        // Define o estado de carregamento como falso após o atraso
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      title: 'PerfList',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: themeProvider.isDarkMode
            ? const ColorScheme.dark(
                primary: Color(0xFF00796B),
                secondary: Color(0xFF004D40),
              )
            : const ColorScheme.light(
                primary: Color(0xFF00796B),
                secondary: Color(0xFF004D40),
              ),
        fontFamily: 'Roboto',
      ),
      home: Consumer<AuthProvider>(
        builder: (context, auth, child) {
          if (auth.isLoggedIn) {
            if (isLoading) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
            return const HomeScreen();
          } else {
            if (isLoading) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
            return LoginPage();
          }
        },
      ),
    );
  }
}

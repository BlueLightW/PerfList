// filme.dart
import 'package:flutter/material.dart';
import 'filme.dart';

class FilmeScreen extends StatelessWidget {
  final Filme filme;

  const FilmeScreen({super.key, required this.filme});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(filme.titulo),centerTitle: true,),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(filme.imagemUrl),
            const SizedBox(height: 10),
            Text('Título: ${filme.titulo}', style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 10),
            Text('Data de Lançamento: ${filme.dataLancamento}'),
            const SizedBox(height: 10),
            Text('Sinopse: ${filme.sinopse}'),
            // Aqui você pode adicionar mais detalhes do filme, se necessário
          ],
        ),
      ),
    );
  }
}
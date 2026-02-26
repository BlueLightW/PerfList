// filme.dart
class Mercado {
  final String nome;
  final String categoria;
  final int quantidade;
  final String id;
// Último episódio assistido

  Mercado({
    required this.nome,
    required this.categoria,
    required this.quantidade,
    required this.id,

  });

  // factory Mercado.fromJson(Map<String, dynamic> json, id) {
  //   return Mercado(
  //     titulo: json['name'],
  //     imagemUrl: 'https://image.tmdb.org/t/p/w500${json['poster_path']}', // URL da imagem
  //     dataLancamento: json['first_air_date'],
  //     sinopse: json['overview'],
  //     id: id,
  //     status: 'Não assistido',
  //     ultimoEpisodio: 0, // Último episódio assistido
  //   );
  // }
   factory Mercado.fromFirebase(Map<String, dynamic> json) {
    return Mercado(
      nome: json['nome'], 
      categoria: json['data_lancamento'], 
      quantidade: json['sinopse'],
      id: '',
      );
  }

  // Método para converter um objeto Anime em um Map (por exemplo, ao salvar no Firestore)
  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'categoria': categoria,
      'quantidade': quantidade,
      'id': id,
    };
  }
}
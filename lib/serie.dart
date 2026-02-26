// filme.dart
class Serie {
  final String titulo;
  final String imagemUrl;
  final String dataLancamento;
  final String sinopse;
  final String id;
  final String status;
  final int ultimoEpisodio; // Último episódio assistido

  Serie({
    required this.titulo,
    required this.imagemUrl,
    required this.dataLancamento,
    required this.sinopse,
    required this.id,
    required this.status,
    required this.ultimoEpisodio,
  });

  factory Serie.fromJson(Map<String, dynamic> json, id) {
    return Serie(
      titulo: json['name'],
      imagemUrl: 'https://image.tmdb.org/t/p/w500${json['poster_path']}', // URL da imagem
      dataLancamento: json['first_air_date'],
      sinopse: json['overview'],
      id: id,
      status: 'Não assistido',
      ultimoEpisodio: 0, // Último episódio assistido
    );
  }
  factory Serie.fromFirebase(Map<String, dynamic> json) {
    return Serie(
      titulo: json['nome'], 
      imagemUrl: json['imagem'], 
      dataLancamento: json['data_lancamento'], 
      sinopse: json['sinopse'],
      id: '',
      status: 'Não assistido',
      ultimoEpisodio: 0, // Último episódio assistido
      );
  }

  // Método para converter um objeto Anime em um Map (por exemplo, ao salvar no Firestore)
  Map<String, dynamic> toJson() {
    return {
      'nome': titulo,
      'imagem': imagemUrl,
      'data_lancamento': dataLancamento,
      'sinopse': sinopse,
      'status': status,
      'id': id,
      'ultimo_episodio': ultimoEpisodio,
    };
  }
}
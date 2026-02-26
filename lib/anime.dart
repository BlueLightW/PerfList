class Anime {
  final String title; // Título do anime
  final String imageUrl; // URL da imagem do anime
  final String status; // Status do anime (assistido, em andamento)
  final int ultimoEpisodio; // Último episódio assistido
  final String id;

  Anime({
    required this.title,
    required this.imageUrl,
    required this.status,
    required this.ultimoEpisodio,
    required this.id,
  });

  // Método para criar um objeto Anime a partir de um Map (por exemplo, ao ler do Firestore)
  factory Anime.fromJson(Map<String, dynamic> json, String id) {
    return Anime(
      title: json['title'],
      imageUrl: json['images']['jpg']['image_url'],
      status: '',
      ultimoEpisodio: 0,
      id: id,
    );
  }

  factory Anime.fromFirebase(Map<String, dynamic> json) {
    return Anime(
      title: json['nome'], 
      imageUrl: json['imagem'], 
      status: json['status'], 
      ultimoEpisodio: json['ultimo_episodio'],
      id: json['id'],
      );
  }

  // Método para converter um objeto Anime em um Map (por exemplo, ao salvar no Firestore)
  Map<String, dynamic> toJson() {
    return {
      'nome': title,
      'imagem': imageUrl,
      'status': status,
      'ultimo_episodio': ultimoEpisodio,
      'id': id,
    };
  }
}
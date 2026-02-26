// filme.dart
class Filme {
  final String titulo;
  final String imagemUrl;
  final String dataLancamento;
  final String sinopse;
  final String id;
  final String status;

  Filme({
    required this.titulo,
    required this.imagemUrl,
    required this.dataLancamento,
    required this.sinopse,
    required this.id,
    required this.status,
  });

  factory Filme.fromJson(Map<String, dynamic> json, id) {
    return Filme(
      titulo: json['title'],
      imagemUrl: 'https://image.tmdb.org/t/p/w500${json['poster_path']}', // URL da imagem
      dataLancamento: json['release_date'],
      sinopse: json['overview'],
      id: id,
      status: 'Não assistido',
    );
  }
  factory Filme.fromFirebase(Map<String, dynamic> json) {
    return Filme(
      titulo: json['nome'], 
      imagemUrl: json['imagem'], 
      dataLancamento: json['data_lancamento'], 
      sinopse: json['sinopse'],
      id: '',
      status: 'Não assistido',
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
    };
  }
}
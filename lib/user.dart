// user.dart
class Usuario {
   final String uid;
  // final String nome;
  final String nickname;
  final DateTime dataNascimento;
  final String genero;

  Usuario({
     required this.uid,
    // required this.nome,
    required this.nickname,
    required this.dataNascimento,
    required this.genero,
  });

  // Método para converter um objeto Usuario em um mapa (para Firestore, por exemplo)
  Map<String, dynamic> toMap() {
    return {
       'uid': uid,
      // 'nome': nome,
      'nickname': nickname,
      'data_nascimento': dataNascimento.toIso8601String(),
      'genero': genero,
    };
  }

  // Método para criar um objeto Usuario a partir de um mapa
  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      uid: map['uid'],
      // nome: map['nome'],
      nickname: map['nickname'],
      dataNascimento: DateTime.parse(map['data_nascimento']),
      genero: map['genero'],
    );
  }
}
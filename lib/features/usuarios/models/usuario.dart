class Usuario {
  final int id;
  final String nome;
  final String email;
  final String situacao;

  const Usuario({
    required this.id,
    required this.nome,
    required this.email,
    required this.situacao,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] as int,
      nome: json['nome'] as String,
      email: json['email'] as String,
      situacao: json['situacao'] as String,
    );
  }

  bool get ativo => situacao == 'ATIVO';

  Map<String, dynamic> toRequest() => {
        'nome': nome,
        'email': email,
        'situacao': situacao,
      };
}

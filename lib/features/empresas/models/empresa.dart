class Empresa {
  final int id;
  final String razaoSocial;
  final String cnpj;
  final String email;
  final String situacao;

  const Empresa({
    required this.id,
    required this.razaoSocial,
    required this.cnpj,
    required this.email,
    required this.situacao,
  });

  factory Empresa.fromJson(Map<String, dynamic> json) {
    return Empresa(
      id: json['id'] as int,
      razaoSocial: json['razaoSocial'] as String,
      cnpj: json['cnpj'] as String,
      email: json['email'] as String,
      situacao: json['situacao'] as String,
    );
  }

  bool get ativa => situacao == 'ATIVO';

  Map<String, dynamic> toRequest() => {
        'razaoSocial': razaoSocial,
        'cnpj': cnpj,
        'email': email,
        'situacao': situacao,
      };
}

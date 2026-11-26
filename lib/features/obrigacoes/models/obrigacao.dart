class Obrigacao {
  final int id;
  final String titulo;
  final String? descricao;
  final String prazo;
  final String status;
  final int empresaId;
  final String empresaRazaoSocial;
  final int usuarioId;
  final String usuarioNome;

  const Obrigacao({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.prazo,
    required this.status,
    required this.empresaId,
    required this.empresaRazaoSocial,
    required this.usuarioId,
    required this.usuarioNome,
  });

  factory Obrigacao.fromJson(Map<String, dynamic> json) {
    return Obrigacao(
      id: json['id'] as int,
      titulo: json['titulo'] as String,
      descricao: json['descricao'] as String?,
      prazo: json['prazo'] as String,
      status: json['status'] as String,
      empresaId: json['empresaId'] as int,
      empresaRazaoSocial: json['empresaRazaoSocial'] as String,
      usuarioId: json['usuarioId'] as int,
      usuarioNome: json['usuarioNome'] as String,
    );
  }

  String? get proximoStatus {
    switch (status) {
      case 'PENDENTE':
        return 'EM_ANDAMENTO';
      case 'EM_ANDAMENTO':
        return 'CONCLUIDA';
      default:
        return null;
    }
  }

  String get statusLabel {
    switch (status) {
      case 'PENDENTE':
        return 'Pendente';
      case 'EM_ANDAMENTO':
        return 'Em andamento';
      case 'CONCLUIDA':
        return 'Concluída';
      default:
        return status;
    }
  }
}

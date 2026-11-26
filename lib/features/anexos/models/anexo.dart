class Anexo {
  final int id;
  final String nomeOriginal;
  final String contentType;
  final int tamanhoBytes;
  final int obrigacaoId;

  const Anexo({
    required this.id,
    required this.nomeOriginal,
    required this.contentType,
    required this.tamanhoBytes,
    required this.obrigacaoId,
  });

  factory Anexo.fromJson(Map<String, dynamic> json) {
    return Anexo(
      id: json['id'] as int,
      nomeOriginal: json['nomeOriginal'] as String,
      contentType: json['contentType'] as String,
      tamanhoBytes: json['tamanhoBytes'] as int,
      obrigacaoId: json['obrigacaoId'] as int,
    );
  }
}

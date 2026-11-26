import 'package:flutter_test/flutter_test.dart';
import 'package:gerenciamento_obrigacoes_app/features/obrigacoes/models/obrigacao.dart';

void main() {
  test('proximoStatus segue o fluxo linear', () {
    const pendente = Obrigacao(
      id: 1,
      titulo: 'X',
      descricao: null,
      prazo: '2030-01-01',
      status: 'PENDENTE',
      empresaId: 1,
      empresaRazaoSocial: 'A',
      usuarioId: 1,
      usuarioNome: 'B',
    );
    const andamento = Obrigacao(
      id: 1,
      titulo: 'X',
      descricao: null,
      prazo: '2030-01-01',
      status: 'EM_ANDAMENTO',
      empresaId: 1,
      empresaRazaoSocial: 'A',
      usuarioId: 1,
      usuarioNome: 'B',
    );
    const concluida = Obrigacao(
      id: 1,
      titulo: 'X',
      descricao: null,
      prazo: '2030-01-01',
      status: 'CONCLUIDA',
      empresaId: 1,
      empresaRazaoSocial: 'A',
      usuarioId: 1,
      usuarioNome: 'B',
    );

    expect(pendente.proximoStatus, 'EM_ANDAMENTO');
    expect(andamento.proximoStatus, 'CONCLUIDA');
    expect(concluida.proximoStatus, isNull);
  });
}

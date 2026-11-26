import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gerenciamento_obrigacoes_app/core/network/api_client.dart';
import 'package:gerenciamento_obrigacoes_app/features/obrigacoes/models/obrigacao.dart';

final obrigacaoRepositoryProvider = Provider<ObrigacaoRepository>((ref) {
  return ObrigacaoRepository(ref.watch(apiClientProvider));
});

class ObrigacaoRepository {
  ObrigacaoRepository(this._dio);

  final Dio _dio;

  Future<List<Obrigacao>> listar({String? status, int? empresaId}) async {
    final response = await _dio.get(
      '/api/obrigacoes',
      queryParameters: {
        if (status != null) 'status': status,
        if (empresaId != null) 'empresaId': empresaId,
      },
    );
    return (response.data as List)
        .map((e) => Obrigacao.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Obrigacao> buscar(int id) async {
    final response = await _dio.get('/api/obrigacoes/$id');
    return Obrigacao.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Obrigacao> salvar({int? id, required Map<String, dynamic> body}) async {
    final Response response;
    if (id == null) {
      response = await _dio.post('/api/obrigacoes', data: body);
    } else {
      response = await _dio.put('/api/obrigacoes/$id', data: body);
    }
    return Obrigacao.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Obrigacao> atualizarStatus(int id, String status) async {
    final response = await _dio.patch(
      '/api/obrigacoes/$id/status',
      data: {'status': status},
    );
    return Obrigacao.fromJson(response.data as Map<String, dynamic>);
  }
}

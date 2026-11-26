import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gerenciamento_obrigacoes_app/core/network/api_client.dart';
import 'package:gerenciamento_obrigacoes_app/features/anexos/models/anexo.dart';

final anexoRepositoryProvider = Provider<AnexoRepository>((ref) {
  return AnexoRepository(ref.watch(apiClientProvider));
});

class AnexoRepository {
  AnexoRepository(this._dio);

  final Dio _dio;

  Future<List<Anexo>> listar(int obrigacaoId) async {
    final response = await _dio.get('/api/obrigacoes/$obrigacaoId/anexos');
    return (response.data as List)
        .map((e) => Anexo.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Anexo> upload({
    required int obrigacaoId,
    required String fileName,
    required Uint8List bytes,
  }) async {
    final formData = FormData.fromMap({
      'arquivo': MultipartFile.fromBytes(bytes, filename: fileName),
    });
    final response = await _dio.post(
      '/api/obrigacoes/$obrigacaoId/anexos',
      data: formData,
    );
    return Anexo.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<int>> download(int id) async {
    final response = await _dio.get<List<int>>(
      '/api/anexos/$id/download',
      options: Options(responseType: ResponseType.bytes),
    );
    return response.data ?? <int>[];
  }
}

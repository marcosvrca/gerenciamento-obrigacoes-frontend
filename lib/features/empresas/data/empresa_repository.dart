import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gerenciamento_obrigacoes_app/core/network/api_client.dart';
import 'package:gerenciamento_obrigacoes_app/features/empresas/models/empresa.dart';

final empresaRepositoryProvider = Provider<EmpresaRepository>((ref) {
  return EmpresaRepository(ref.watch(apiClientProvider));
});

class EmpresaRepository {
  EmpresaRepository(this._dio);

  final Dio _dio;

  Future<List<Empresa>> listar({String? situacao}) async {
    final response = await _dio.get(
      '/api/empresas',
      queryParameters: {
        if (situacao != null) 'situacao': situacao,
      },
    );
    return (response.data as List)
        .map((e) => Empresa.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Empresa> salvar({int? id, required Map<String, dynamic> body}) async {
    final Response response;
    if (id == null) {
      response = await _dio.post('/api/empresas', data: body);
    } else {
      response = await _dio.put('/api/empresas/$id', data: body);
    }
    return Empresa.fromJson(response.data as Map<String, dynamic>);
  }
}

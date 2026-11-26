import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gerenciamento_obrigacoes_app/core/network/api_client.dart';
import 'package:gerenciamento_obrigacoes_app/features/usuarios/models/usuario.dart';

final usuarioRepositoryProvider = Provider<UsuarioRepository>((ref) {
  return UsuarioRepository(ref.watch(apiClientProvider));
});

class UsuarioRepository {
  UsuarioRepository(this._dio);

  final Dio _dio;

  Future<List<Usuario>> listar({String? situacao}) async {
    final response = await _dio.get(
      '/api/usuarios',
      queryParameters: {
        if (situacao != null) 'situacao': situacao,
      },
    );
    return (response.data as List)
        .map((e) => Usuario.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Usuario> salvar({int? id, required Map<String, dynamic> body}) async {
    final Response response;
    if (id == null) {
      response = await _dio.post('/api/usuarios', data: body);
    } else {
      response = await _dio.put('/api/usuarios/$id', data: body);
    }
    return Usuario.fromJson(response.data as Map<String, dynamic>);
  }
}

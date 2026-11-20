
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/character.dart';

class ApiService {
  static const String _baseUrl = 'rickandmortyapi.com';

  static const Duration _timeout = Duration(seconds: 30);

  Future<http.Response> _request(Uri uri) async {
    try {
      return await http.get(uri).timeout(_timeout);
    } on TimeoutException {
      throw Exception(
        'A conexão demorou demais. Verifique sua internet e tente novamente.',
      );
    } on SocketException {
      throw Exception(
        'Não foi possível conectar à internet. Verifique sua conexão.',
      );
    } catch (e) {
      throw Exception('Erro ao conectar com a API: $e');
    }
  }

  Future<Map<String, dynamic>> fetchCharacters({
    int page = 1,
  }) async {
    final uri = Uri.https(
      _baseUrl,
      '/api/character',
      {'page': '$page'},
    );

    final response = await _request(uri);

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    throw Exception(
      'Não foi possível carregar os personagens. '
          'Código: ${response.statusCode}',
    );
  }

  Future<List<Character>> searchCharacters(String query) async {
    final uri = Uri.https(
      _baseUrl,
      '/api/character',
      {'name': query},
    );

    final response = await _request(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      return (data['results'] as List)
          .map(
            (item) => Character.fromJson(
          item as Map<String, dynamic>,
        ),
      )
          .toList();
    }

    if (response.statusCode == 404) {
      return [];
    }

    throw Exception(
      'Falha ao realizar a busca. Código: ${response.statusCode}',
    );
  }

  Future<Character> fetchCharacterDetails(int id) async {
    final uri = Uri.https(
      _baseUrl,
      '/api/character/$id',
    );

    final response = await _request(uri);

    if (response.statusCode == 200) {
      return Character.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }

    throw Exception(
      'Não foi possível carregar os detalhes. '
          'Código: ${response.statusCode}',
    );
  }

  Future<Character> fetchCharacterById(int id) {
    return fetchCharacterDetails(id);
  }
}

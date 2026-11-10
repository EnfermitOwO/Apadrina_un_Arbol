
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/foro_remote_model.dart';

class ForoService {
  static const String url =
      'https://apadrina-un-arbol-web.onrender.com/apis/api_foro.php';

  // ==========================================
  // OBTENER PUBLICACIONES
  // ==========================================
  static Future<List<ForoRemoteModel>> obtenerPosts() async {
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) {
        throw Exception(
          'Error al cargar publicaciones: ${response.statusCode}',
        );
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! List) {
        throw Exception('La respuesta del servidor no es válida');
      }

      return decoded
          .map(
            (item) => ForoRemoteModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    } catch (e) {
      print('Error al obtener publicaciones: $e');
      rethrow;
    }
  }

  // ==========================================
  // CREAR PUBLICACIÓN
  // ==========================================
  static Future<bool> crearPost({
    required String emailUsuario,
    required String nombreUsuario,
    required String mensaje,
    String? imagen,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'email_usuario': emailUsuario.trim().toLowerCase(),
          'nombre_usuario': nombreUsuario.trim(),
          'mensaje': mensaje.trim(),
          'imagen': imagen,
          'tipo_multimedia': 'image',
        }),
      );

      print('Respuesta al publicar: ${response.body}');

      if (response.statusCode != 200) {
        return false;
      }

      final resultado = jsonDecode(response.body);

      return resultado is Map &&
          resultado['success'] == true;
    } catch (e) {
      print('Error al crear publicación: $e');
      return false;
    }
  }
}

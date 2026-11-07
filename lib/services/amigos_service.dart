
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/amigo_model.dart';

class AmigosService {
  static const String baseUrl =
      'https://apadrina-un-arbol-web.onrender.com/apis/api_amigos.php';

  // BUSCAR USUARIOS
  static Future<List<AmigoModel>> buscarUsuarios({
    required String busqueda,
    required String emailUsuario,
  }) async {
    try {
      final uri = Uri.parse(baseUrl).replace(
        queryParameters: {
          'accion': 'buscar',
          'q': busqueda,
          'email_usuario': emailUsuario,
        },
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          final List usuarios = data['usuarios'] ?? [];

          return usuarios
              .map((usuario) => AmigoModel.fromJson(usuario))
              .toList();
        }
      }

      throw Exception('No se pudieron buscar los usuarios.');
    } catch (e) {
      print('Error buscando usuarios: $e');
      rethrow;
    }
  }

  // ENVIAR SOLICITUD DE AMISTAD
  static Future<bool> enviarSolicitud({
    required String emailUsuario,
    required String emailAmigo,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl?accion=solicitar'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email_usuario': emailUsuario,
          'email_amigo': emailAmigo,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }

      return false;
    } catch (e) {
      print('Error enviando solicitud: $e');
      return false;
    }
  }

  // COMPATIBILIDAD CON EL CÓDIGO ANTERIOR
  static Future<bool> agregarAmigo({
    required String emailUsuario,
    required String emailAmigo,
  }) {
    return enviarSolicitud(
      emailUsuario: emailUsuario,
      emailAmigo: emailAmigo,
    );
  }

  // OBTENER AMIGOS ACEPTADOS
  static Future<List<AmigoModel>> obtenerAmigos({
    required String emailUsuario,
  }) async {
    try {
      final uri = Uri.parse(baseUrl).replace(
        queryParameters: {
          'accion': 'listar',
          'email_usuario': emailUsuario,
        },
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          final List amigos = data['amigos'] ?? [];

          return amigos
              .map((amigo) => AmigoModel.fromJson(amigo))
              .toList();
        }
      }

      throw Exception('No se pudieron obtener los amigos.');
    } catch (e) {
      print('Error obteniendo amigos: $e');
      rethrow;
    }
  }

  // OBTENER SOLICITUDES RECIBIDAS
  static Future<List<AmigoModel>> obtenerSolicitudesRecibidas({
    required String emailUsuario,
  }) async {
    try {
      final uri = Uri.parse(baseUrl).replace(
        queryParameters: {
          'accion': 'recibidas',
          'email_usuario': emailUsuario,
        },
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          final List solicitudes = data['solicitudes'] ?? [];

          return solicitudes
              .map((solicitud) => AmigoModel.fromJson(solicitud))
              .toList();
        }
      }

      throw Exception('No se pudieron obtener las solicitudes.');
    } catch (e) {
      print('Error obteniendo solicitudes recibidas: $e');
      rethrow;
    }
  }

  // OBTENER SOLICITUDES ENVIADAS
  static Future<List<AmigoModel>> obtenerSolicitudesEnviadas({
    required String emailUsuario,
  }) async {
    try {
      final uri = Uri.parse(baseUrl).replace(
        queryParameters: {
          'accion': 'enviadas',
          'email_usuario': emailUsuario,
        },
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          final List solicitudes = data['solicitudes'] ?? [];

          return solicitudes
              .map((solicitud) => AmigoModel.fromJson(solicitud))
              .toList();
        }
      }

      throw Exception('No se pudieron obtener las solicitudes enviadas.');
    } catch (e) {
      print('Error obteniendo solicitudes enviadas: $e');
      rethrow;
    }
  }

  // RESPONDER SOLICITUD: ACEPTAR O RECHAZAR
  static Future<bool> responderSolicitud({
    required String emailUsuario,
    required String emailSolicitante,
    required String respuesta,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl?accion=responder'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email_usuario': emailUsuario,
          'email_solicitante': emailSolicitante,
          'respuesta': respuesta,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }

      return false;
    } catch (e) {
      print('Error respondiendo solicitud: $e');
      return false;
    }
  }
}
 
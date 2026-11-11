
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApadrinamientoService {
  static const String baseUrl =
      'https://apadrina-un-arbol-web.onrender.com/apis/api_apadrinamientos.php';

  // CREAR APADRINAMIENTO O DONACIÓN
  static Future<Map<String, dynamic>> crearApadrinamiento({
    required String emailUsuario,
    required int idArbol,
    required String nombrePersonalizado,
    required String tipoAdopcion,
    required double monto,
    required String metodoPago,
    Map<String, dynamic>? datosTarjeta,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl?accion=crear');

      final Map<String, dynamic> cuerpo = {
        'email_usuario': emailUsuario,
        'id_arbol': idArbol,
        'nombre_personalizado': nombrePersonalizado,
        'tipo_adopcion': tipoAdopcion,
        'monto': monto,
        'metodo_pago': metodoPago,
      };

      if (metodoPago == 'Tarjeta' && datosTarjeta != null) {
        cuerpo['datos_tarjeta'] = datosTarjeta;
      }

      final respuesta = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(cuerpo),
      ).timeout(const Duration(seconds: 30));

      final datos = jsonDecode(respuesta.body);

      if (respuesta.statusCode == 200 && datos['success'] == true) {
        return Map<String, dynamic>.from(datos);
      }

      throw Exception(
        datos['mensaje'] ??
            datos['error'] ??
            'No se pudo realizar el registro',
      );
    } catch (e) {
      throw Exception('Error al crear el registro: $e');
    }
  }

  // OBTENER MIS ÁRBOLES APADRINADOS Y DONACIONES
  static Future<List<Map<String, dynamic>>> obtenerApadrinamientos({
    required String emailUsuario,
  }) async {
    try {
      final uri = Uri.parse(baseUrl).replace(
        queryParameters: {
          'accion': 'listar',
          'email_usuario': emailUsuario,
        },
      );

      final respuesta = await http.get(uri).timeout(
        const Duration(seconds: 30),
      );

      final datos = jsonDecode(respuesta.body);

      if (respuesta.statusCode == 200 && datos['success'] == true) {
        final lista = datos['apadrinamientos'] as List? ?? [];

        return lista
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      }

      throw Exception(
        datos['mensaje'] ??
            datos['error'] ??
            'No se pudieron obtener los registros',
      );
    } catch (e) {
      throw Exception('Error al consultar los registros: $e');
    }
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/foro_remote_model.dart';

class ForoService {
  // Reemplazamos 'localhost' por '10.0.2.2' para que el emulador llegue a tu XAMPP
  static const String url = 'http://10.0.2.2/Apadrina-un-Arbol/apis/api_foro.php';

  static Future<List<ForoRemoteModel>> obtenerPosts() async {
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((dynamic item) => ForoRemoteModel.fromJson(item)).toList();
      } else {
        throw Exception('Error al cargar el foro: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al conectar con la API del foro: $e');
      throw Exception('No se pudo conectar con el servidor local');
    }
  }
}
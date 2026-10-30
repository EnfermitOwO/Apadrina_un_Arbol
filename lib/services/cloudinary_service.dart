import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class CloudinaryService {
  // Tus credenciales oficiales de Cloudinary
  static const String _cloudName = 'azlao9b7';
  static const String _uploadPreset = 'flutter_app';

  static final ImagePicker _picker = ImagePicker();

  /// Abre la galería del dispositivo, selecciona la imagen,
  /// la sube a Cloudinary y regresa la URL pública lista para guardar en MongoDB.
  static Future<String?> subirImagenDesdeGaleria({required bool esPerfil}) async {
    try {
      // 1. Abrir galería del celular
      final XFile? imagen = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: esPerfil ? 500 : 1000,  // Resolución adaptada (perfil más cuadrado/chico, portada más ancha)
        maxHeight: esPerfil ? 500 : 600,
        imageQuality: 75,                // Compresión óptima para que suba volando
      );

      if (imagen == null) return null; // El usuario canceló

      // 2. Preparar petición HTTP POST hacia Cloudinary
      final url = Uri.parse('https://api.cloudinary.com/v1_1/$_cloudName/image/upload');
      
      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = _uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', imagen.path));

      // 3. Enviar la imagen
      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.toBytes();
        final jsonMap = jsonDecode(String.fromCharCodes(responseData));

        // Regresa la URL web pública de la imagen subida
        return jsonMap['secure_url'] as String?;
      } else {
        print('Error en Cloudinary: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Excepción al subir imagen: $e');
      return null;
    }
  }
}
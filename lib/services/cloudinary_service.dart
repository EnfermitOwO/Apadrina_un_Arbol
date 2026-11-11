
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class CloudinaryService {
  static const String _cloudName = 'azlao9b7';
  static const String _uploadPreset = 'flutter_app';

  static final ImagePicker _picker = ImagePicker();

  /// Sube una imagen para foto de perfil o portada.
  static Future<String?> subirImagenDesdeGaleria({
    required bool esPerfil,
  }) async {
    try {
      final XFile? imagen = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: esPerfil ? 500 : 1000,
        maxHeight: esPerfil ? 500 : 600,
        imageQuality: 75,
      );

      if (imagen == null) return null;

      return await _subirArchivo(
        archivo: imagen,
        tipo: 'image',
      );
    } catch (e) {
      print('Excepción al seleccionar imagen: $e');
      return null;
    }
  }

  /// Permite seleccionar una imagen o un video para una publicación.
  /// Regresa la URL y el tipo de archivo.
  static Future<Map<String, String>?> subirMultimediaDesdeGaleria() async {
    try {
      final XFile? archivo = await _picker.pickMedia();

      if (archivo == null) return null;

      final String extension = archivo.name.split('.').last.toLowerCase();

      const extensionesVideo = [
        'mp4',
        'mov',
        'avi',
        'mkv',
        'webm',
      ];

      final bool esVideo = extensionesVideo.contains(extension);
      final String tipo = esVideo ? 'video' : 'image';

      final String? url = await _subirArchivo(
        archivo: archivo,
        tipo: tipo,
      );

      if (url == null) return null;

      return {
        'url': url,
        'tipo': tipo,
      };
    } catch (e) {
      print('Excepción al subir multimedia: $e');
      return null;
    }
  }

  /// Envía el archivo a Cloudinary.
  static Future<String?> _subirArchivo({
    required XFile archivo,
    required String tipo,
  }) async {
    try {
      final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/$_cloudName/$tipo/upload',
      );

      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = _uploadPreset
        ..files.add(
          await http.MultipartFile.fromPath('file', archivo.path),
        );

      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final jsonMap = jsonDecode(responseData);
        return jsonMap['secure_url'] as String?;
      }

      print('Error en Cloudinary: ${response.statusCode}');
      print(responseData);
      return null;
    } catch (e) {
      print('Error al subir archivo a Cloudinary: $e');
      return null;
    }
  }
}

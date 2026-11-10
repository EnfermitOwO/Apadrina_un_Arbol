
class ForoRemoteModel {
  final String id;
  final String emailUsuario;
  final String nombreUsuario;
  final String mensaje;
  final String? imagen;
  final String fecha;
  final List<dynamic> comentarios;

  ForoRemoteModel({
    required this.id,
    required this.emailUsuario,
    required this.nombreUsuario,
    required this.mensaje,
    this.imagen,
    required this.fecha,
    required this.comentarios,
  });

  factory ForoRemoteModel.fromJson(Map<String, dynamic> json) {
    String parsedId = '';

    if (json['_id'] is Map) {
      parsedId = json['_id']['\$oid']?.toString() ?? '';
    } else {
      parsedId = json['_id']?.toString() ?? '';
    }

    final imagenJson = json['imagen'];

    return ForoRemoteModel(
      id: parsedId,
      emailUsuario:
          (json['email_usuario'] ?? '').toString().trim().toLowerCase(),
      nombreUsuario:
          (json['nombre_usuario'] ?? 'Usuario').toString(),
      mensaje: (json['mensaje'] ?? '').toString(),
      imagen: imagenJson == null || imagenJson.toString().isEmpty
          ? null
          : imagenJson.toString(),
      fecha: (json['fecha'] ?? '').toString(),
      comentarios: json['comentarios'] is List
          ? List<dynamic>.from(json['comentarios'])
          : [],
    );
  }
}

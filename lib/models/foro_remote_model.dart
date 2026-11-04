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
    // Manejo seguro del ID por si MongoDB lo manda como mapa o string
    String parsedId = '';
    if (json['_id'] is Map) {
      parsedId = json['_id']['\$oid']?.toString() ?? '';
    } else {
      parsedId = json['_id']?.toString() ?? '';
    }

    // Manejo de la URL de la imagen (si empieza con barra diagonal, la completamos con localhost opcionalmente)
    String? parsedImagen = json['imagen'];
    if (parsedImagen != null && parsedImagen.startsWith('/')) {
      //ip del internet
      parsedImagen = 'http://10.0.2.2$parsedImagen';
    }

    return ForoRemoteModel(
      id: parsedId,
      emailUsuario: json['email_usuario']?.toString() ?? '',
      nombreUsuario: json['nombre_usuario']?.toString() ?? 'Anónimo',
      mensaje: json['mensaje']?.toString() ?? '',
      imagen: parsedImagen,
      fecha: json['fecha']?.toString() ?? '',
      comentarios: json['comentarios'] is List ? json['comentarios'] : [],
    );
  }
}
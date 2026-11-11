
class AmigoModel {
  final String nombreUsuario;
  final String email;
  final String? fotoPerfil;
  final String bio;

  AmigoModel({
    required this.nombreUsuario,
    required this.email,
    this.fotoPerfil,
    required this.bio,
  });

  factory AmigoModel.fromJson(Map<String, dynamic> json) {
    return AmigoModel(
      nombreUsuario: json['nombre_usuario']?.toString() ?? 'Usuario',
      email: json['email']?.toString() ?? '',
      fotoPerfil: json['foto_perfil']?.toString(),
      bio: json['bio']?.toString() ?? '',
    );
  }
}
 
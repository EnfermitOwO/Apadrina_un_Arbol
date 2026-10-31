class ArbolModel {
  final int idArbol;
  final String nombreComun;
  final String nombreCientifico;
  final String descripcion;
  final String imagen;
  final String altura;
  final String epoca;
  final String descripcionLarga;
  final String datosInteresantes;

  ArbolModel({
    required this.idArbol,
    required this.nombreComun,
    required this.nombreCientifico,
    required this.descripcion,
    required this.imagen,
    required this.altura,
    required this.epoca,
    required this.descripcionLarga,
    required this.datosInteresantes,
  });

  factory ArbolModel.fromMap(Map<String, dynamic> map) {
    return ArbolModel(
      idArbol: map['id_arbol'] ?? 0,
      nombreComun: map['nombre_comun'] ?? '',
      nombreCientifico: map['nombre_cientifico'] ?? '',
      descripcion: map['descripcion'] ?? '',
      imagen: map['imagen'] ?? '',
      altura: map['altura'] ?? '',
      epoca: map['epoca'] ?? '',
      descripcionLarga: map['descripcion_larga'] ?? '',
      datosInteresantes: map['datos_interesantes'] ?? '',
    );
  }
}
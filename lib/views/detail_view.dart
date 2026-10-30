import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../main.dart';
import '../widgets/custom_bottom_nav.dart';

class DetalleArbolScreen extends StatelessWidget {
  final Map<String, dynamic> arbol;

  const DetalleArbolScreen({super.key, required this.arbol});

  // Colores extraídos del diseño original
  static const Color verdePrincipal = Color(0xFF3B6B23);
  static const Color verdeBotonClaro = Color(0xFF7CB342);
  static const Color fondoVerdeClaro = Color(0xFFF1F8E9);

  @override
  Widget build(BuildContext context) {
    // Extracción de datos con fallbacks seguros
    final String nombreComun = arbol['nombre_comun'] ?? 'Árbol sin nombre';
    final String nombreCientifico = arbol['nombre_cientifico'] ?? '';
    final String descripcion = arbol['descripcion_larga'] ?? arbol['descripcion'] ?? 'Sin descripción disponible.';
    final String curiosidades = arbol['datos_interesantes'] ?? 'Sin información adicional.';
    final String altura = arbol['altura'] ?? 'No especificada';
    final String epoca = arbol['epoca'] ?? 'No especificada';
    final String imagenUrl = arbol['imagen'] ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Encabezado centrado con flecha de regreso
            _buildAppBar(context),
            const Divider(height: 1, thickness: 1, color: Color(0xFFE0E0E0)),

            // 2. Contenido de la tarjeta del árbol
            Expanded(
              child: Container(
                color: fondoVerdeClaro,
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Imagen del árbol desde Cloudinary (o red)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16.0),
                          child: imagenUrl.isNotEmpty
                              ? Image.network(
                                  imagenUrl,
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      height: 200,
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.park, size: 60, color: Colors.grey),
                                    );
                                  },
                                )
                              : Container(
                                  height: 200,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.park, size: 60, color: Colors.grey),
                                ),
                        ),
                        const SizedBox(height: 16),

                        // Nombre Común
                        Text(
                          nombreComun,
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: verdePrincipal,
                          ),
                        ),

                        // Nombre Científico (si existe)
                        if (nombreCientifico.isNotEmpty) ...[
                          Text(
                            nombreCientifico,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],

                        // Especificaciones (Altura y Época)
                        Row(
                          children: [
                            Chip(
                              avatar: const Icon(Icons.straighten, size: 16, color: verdePrincipal),
                              label: Text('Altura: $altura', style: const TextStyle(fontSize: 12)),
                              backgroundColor: fondoVerdeClaro,
                              side: BorderSide.none,
                            ),
                            const SizedBox(width: 8),
                            Chip(
                              avatar: const Icon(Icons.eco, size: 16, color: verdePrincipal),
                              label: Text('Época: $epoca', style: const TextStyle(fontSize: 12)),
                              backgroundColor: fondoVerdeClaro,
                              side: BorderSide.none,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Descripción
                        Text(
                          'Descripción',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          descripcion,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.black87,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Curiosidades / Datos interesantes
                        Text(
                          'Curiosidades',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          curiosidades,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.black87,
                            height: 1.4,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Botón Adoptar
                        SizedBox(
                          width: double.infinity,
                          height: 45,
                          child: ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('¡Proceso de adopción iniciado para $nombreComun!'),
                                  backgroundColor: verdePrincipal,
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: verdePrincipal,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Text(
                              'Adoptar',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Botón Donar
                        SizedBox(
                          width: double.infinity,
                          height: 45,
                          child: ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('¡Gracias por tu intención de donar!'),
                                  backgroundColor: verdeBotonClaro,
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: verdeBotonClaro,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Text(
                              'Donar',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          }
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: verdePrincipal),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.park,
                  color: verdePrincipal,
                  size: 22,
                ),
                const SizedBox(width: 6),
                Text(
                  'Apadrina un árbol',
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: verdePrincipal,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart'; // <--- Importa tu AuthProvider
import '../views/perfil_view.dart';

class CustomHeader extends StatelessWidget implements PreferredSizeWidget {
  const CustomHeader({super.key});

  @override
  Widget build(BuildContext context) {
    // Usamos context.watch para que el header se actualice solo si cambia el estado de sesión o las fotos
    final authProvider = context.watch<AuthProvider>();
    
    // Verificamos si está logueado y si tiene una foto de perfil guardada en el usuario actual
    final bool isLoggedIn = authProvider.isLoggedIn;
    final currentUser = authProvider.currentUser;
    
    final String? fotoPerfilUrl = currentUser != null ? currentUser['foto_perfil'] : null;

    // Imagen por defecto cuando no hay sesión o no hay foto
    const String defaultImage = 'https://tusnoticiasbc.com/wp-content/uploads/2023/08/poster504x498f8f8f8-pad600x600f8f8f8.u2.jpg';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Avatar de perfil pequeño con navegación al tocarlo
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PerfilView(),
                ),
              );
            },
            child: CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage(
                (isLoggedIn && fotoPerfilUrl != null && fotoPerfilUrl.isNotEmpty)
                    ? fotoPerfilUrl
                    : defaultImage,
              ),
            ),
          ),
          
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.park,
                color: Color(0xFF386623),
                size: 24,
              ),
              const SizedBox(width: 6),
              Text(
                "Apadrina un árbol",
                style: GoogleFonts.poppins(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF386623),
                ),
              ),
            ],
          ),
          
          // Icono de notificación a la derecha
          const Icon(
            Icons.notifications,
            color: Color(0xFF386623),
            size: 27,
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}
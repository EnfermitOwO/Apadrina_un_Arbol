import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../views/perfil_view.dart';

class CustomHeader extends StatelessWidget implements PreferredSizeWidget {
  const CustomHeader({super.key});

  @override
  Widget build(BuildContext context) {
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
            child: const CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage(
                'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ1S4mykNT3niNOaA7ZTB89DgE9Q5jhR_da5c3-MvMDSbp2Ou6hDViKqFFH&s=10',
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
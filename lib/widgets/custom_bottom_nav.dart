import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../views/myprofile_view.dart'; 
import '../views/catalogo.dart';
import '../views/novedades_view.dart'; 

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF2F8ED),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.5),
          child: BottomNavigationBar(
            // Protección .clamp(0, 3): Actualizado a 3 porque ahora tienes 4 elementos (0, 1, 2, 3)
            currentIndex: currentIndex.clamp(0, 3),
            onTap: (index) {
              if (index == 3) {
                // Redirección a Perfil ("Tú")
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyProfileView(),
                  ),
                );
              } else if (index == 2) {
                // 2. Redirección a Novedades
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NovedadesView(), // Reemplaza con el nombre real de tu clase de Novedades
                  ),
                );
              } else if (index == 1) {
                // Redirección al Catálogo
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CatalogoScreen(),
                  ),
                );
              } else if (onTap != null) {
                onTap!(index);
              }
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: const Color(0xFF5D8736),
            unselectedItemColor: Colors.grey.shade600,
            selectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 11),
            unselectedLabelStyle: GoogleFonts.poppins(fontSize: 11),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: "Inicio"),      // ÍNDICE 0
              BottomNavigationBarItem(icon: Icon(Icons.search), label: "Catálogo"),  // ÍNDICE 1
              BottomNavigationBarItem(icon: Icon(Icons.public), label: "Novedades"), // ÍNDICE 2
              BottomNavigationBarItem(icon: Icon(Icons.person), label: "Tú"),        // ÍNDICE 3 (Actualizado)
            ],
          ),
        ),
      ),
    );
  }
}
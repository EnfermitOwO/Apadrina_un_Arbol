import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
      child: SafeArea( // Asegura que respete el borde inferior de los celulares modernos
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.5), // <--- Esto aumenta la altura total de forma segura
          child: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: onTap,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: const Color(0xFF5D8736),
            unselectedItemColor: Colors.grey.shade600,
            selectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 11),
            unselectedLabelStyle: GoogleFonts.poppins(fontSize: 11),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: "Inicio"),
              BottomNavigationBarItem(icon: Icon(Icons.search), label: "Catálogo"),
              BottomNavigationBarItem(icon: Icon(Icons.public), label: "Novedades"),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: "Tú"),
            ],
          ),
        ),
      ),
    );
  }
}
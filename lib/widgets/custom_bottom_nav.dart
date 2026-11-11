
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../views/myprofile_view.dart';
import '../views/catalogo.dart';
import '../views/novedades_view.dart';
import '../main.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    this.onTap,
  });

  void _navegar(BuildContext context, int index) {
    if (index == currentIndex) return;

    Widget pantalla;

    switch (index) {
      case 0:
        if (onTap != null) {
          onTap!(index);
          return;
        }
        pantalla = const HomePage();
        break;
      case 1:
        pantalla = const CatalogoScreen();
        break;
      case 2:
        pantalla = const NovedadesView();
        break;
      case 3:
        pantalla = const MyProfileView();
        break;
      default:
        return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => pantalla),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF2F8ED),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.5),
          child: BottomNavigationBar(
            currentIndex: currentIndex.clamp(0, 3),
            onTap: (index) => _navegar(context, index),
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: const Color(0xFF5D8736),
            unselectedItemColor: Colors.grey,
            selectedLabelStyle: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
            unselectedLabelStyle: GoogleFonts.poppins(
              fontSize: 11,
            ),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Inicio',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search),
                label: 'Catálogo',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.public),
                label: 'Novedades',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Tú',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

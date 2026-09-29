import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NovedadesView extends StatelessWidget {
  const NovedadesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Inicio',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFF558B2F),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Text(
          '¡Bienvenido a la aplicación!',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF33691E),
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomeSection extends StatelessWidget {
  const WelcomeSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Bienvenido",
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "Arbolito",
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    color: const Color(0xFF5D8736),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const CircleAvatar(
            radius: 40,
            backgroundImage: NetworkImage(
              'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ1S4mykNT3niNOaA7ZTB89DgE9Q5jhR_da5c3-MvMDSbp2Ou6hDViKqFFH&s=10',
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';

class AuthHeader extends StatelessWidget {
  final String imageUrl;

  const AuthHeader({
    super.key,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        // Fondo verde con la forma curva
        ClipPath(
          clipper: HeaderClipper(),
          child: Container(
            height: size.height * 0.35,
            width: double.infinity,
            color: const Color(0xFF558B2F),
          ),
        ),

        // Imagen circular
        Positioned(
          top: size.height * 0.13,
          child: Container(
            width: 142,
            height: 142,
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ],
    );
  }
} // <-- ESTE ERA EL QUE FALTABA

class HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    // Comenzamos arriba a la izquierda
    path.moveTo(0, 0);

    // Parte superior
    path.lineTo(size.width, 0);

    // Bajamos por el lado derecho
    path.lineTo(size.width, size.height * 0.70);

    // ─────────────────────────────
    // 1. CURVA - lado derecho
    // ─────────────────────────────
    path.cubicTo(
      size.width * 0.92,
      size.height * 0.62,
      size.width * 0.82,
      size.height * 0.60,
      size.width * 0.73,
      size.height * 0.68,
    );

    // ─────────────────────────────
    // 2. CURVA - derecha hacia centro
    // ─────────────────────────────
    path.cubicTo(
      size.width * 0.64,
      size.height * 0.77,
      size.width * 0.58,
      size.height * 0.82,
      size.width * 0.51,
      size.height * 0.70,
    );

    // ─────────────────────────────
    // 3. CURVA - centro hacia izquierda
    // ─────────────────────────────
    path.cubicTo(
      size.width * 0.44,
      size.height * 0.57,
      size.width * 0.37,
      size.height * 0.48,
      size.width * 0.30,
      size.height * 0.55,
    );

    // ─────────────────────────────
    // 4. CURVA - lado izquierdo
    // ─────────────────────────────
    path.cubicTo(
      size.width * 0.22,
      size.height * 0.64,
      size.width * 0.12,
      size.height * 0.62,
      size.width * 0.07,
      size.height * 0.52,
    );

    // Salida por la izquierda
    path.cubicTo(
      size.width * 0.03,
      size.height * 0.45,
      size.width * 0.01,
      size.height * 0.38,
      0,
      size.height * 0.34,
    );

    // Cerramos
    path.lineTo(0, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/widgets/header.dart';
import '/widgets/custom_text_field.dart';

class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SingleChildScrollView(
        child: Column(
          children: [
            // ==========================================
            // CABECERA
            // ==========================================
            const AuthHeader(
              imageUrl:
                  'https://images.unsplash.com/photo-1542273917363-3b1817f69a2d?auto=format&fit=crop&w=500&q=80',
            ),

            const SizedBox(height: 0),

            // ==========================================
            // TÍTULO
            // ==========================================
            Transform.translate(
              offset: const Offset(0, -18),
              child: Text(
                'Crear cuenta',
                style: GoogleFonts.poppins(
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2E5D18),
                ),
              ),
            ),

            const SizedBox(height: 5),

            // ==========================================
            // FORMULARIO
            // ==========================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  // Nombre
                  const CustomTextField(
                    label: 'Nombre',
                    hintText: 'Liz',
                    prefixIcon: Icons.person,
                  ),

                  const SizedBox(height: 20),

                  // Correo
                  const CustomTextField(
                    label: 'Correo electrónico',
                    hintText: 'liz@gmail.com',
                    prefixIcon: Icons.email,
                  ),

                  const SizedBox(height: 20),

                  // Contraseña
                  const CustomTextField(
                    label: 'Contraseña',
                    hintText: '********',
                    prefixIcon: Icons.lock,
                    isPassword: true,
                    suffixIcon: Icon(
                      Icons.visibility_off,
                      color: Color(0xFF33691E),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // ==========================================
                  // BOTÓN REGISTRARSE
                  // ==========================================
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF558B2F),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {},
                      child: Text(
                        'Registrarme',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // ==========================================
                  // REGRESAR AL LOGIN
                  // ==========================================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '¿Ya tienes una cuenta? ',
                        style: GoogleFonts.poppins(
                          color: Colors.black54,
                          fontSize: 14,
                        ),
                      ),

                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Inicia sesión',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF33691E),
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
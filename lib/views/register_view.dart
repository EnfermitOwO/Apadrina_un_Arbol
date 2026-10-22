import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '/widgets/header.dart';
import '/widgets/custom_text_field.dart';
import '../providers/auth_provider.dart';
import '../services/biometric_service.dart'; // Importamos el servicio biométrico
import 'novedades_view.dart';

class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

  // Método auxiliar para autenticar e iniciar sesión
  Future<void> _handleBiometricRegister(BuildContext context) async {
    bool canAuth = await BiometricService.isBiometricAvailable();

    if (!canAuth) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tu dispositivo no cuenta con autenticación biométrica activa.'),
          ),
        );
      }
      return;
    }

    bool authenticated = await BiometricService.authenticate();

    if (authenticated && context.mounted) {
      // Guardamos sesión en el Provider
      Provider.of<AuthProvider>(context, listen: false).login();

      // Navegamos limpiando la pila de pantallas
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const NovedadesView(),
        ),
        (route) => false,
      );
    }
  }

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
                      onPressed: () {
                        // 1. Inicia sesión en Provider
                        Provider.of<AuthProvider>(context, listen: false).login();

                        // 2. Navega a NovedadesView limpiando la navegación
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NovedadesView(),
                          ),
                          (route) => false,
                        );
                      },
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

                  const SizedBox(height: 20),

                  // ==========================================
                  // OPCIÓN BIOMÉTRICA (HUELLA / FACE ID)
                  // ==========================================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'O regístrate rápidamente con:',
                        style: GoogleFonts.poppins(
                          color: Colors.black54,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        iconSize: 36,
                        icon: const Icon(
                          Icons.fingerprint, // Se adapta automáticamente a Face ID / Huella
                          color: Color(0xFF33691E),
                        ),
                        onPressed: () => _handleBiometricRegister(context),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

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
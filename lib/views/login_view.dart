import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'register_view.dart';
import 'novedades_view.dart';
import '/widgets/header.dart';
import '/widgets/custom_text_field.dart';
import '../providers/auth_provider.dart';
import 'package:provider/provider.dart';
import '../services/biometric_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // Tema general de la aplicación
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),

      home: const LoginView(),
    );
  }
}

class LoginView extends StatelessWidget {
  const LoginView({super.key});

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
                '¡Bienvenido!',
                style: GoogleFonts.poppins(
                  fontSize: 38,
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

                  const SizedBox(height: 12),

                  // ==========================================
                  // OLVIDASTE TU CONTRASEÑA
                  // ==========================================
                  Align(
                    alignment: Alignment.center,
                    child: TextButton(
                      onPressed: () {},
                      child: Text(
                        '¿Olvidaste tu contraseña?',
                        style: GoogleFonts.poppins(
                          color: Colors.black54,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ==========================================
                  // BOTÓN INICIAR SESIÓN
                  // ==========================================
                 // ==========================================
// BOTÓN INICIAR SESIÓN
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
      // Activamos la sesión con el Provider
      Provider.of<AuthProvider>(context, listen: false).login();

      // Navegamos a la siguiente vista
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const NovedadesView(),
        ),
      );
    },
    child: Text(
      'Iniciar sesión',
      style: GoogleFonts.poppins(
        fontSize: 18,
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
),
// Botón de Biometría (Huella / Face ID)
IconButton(
  iconSize: 45,
  icon: const Icon(
    Icons.fingerprint, // O Icons.face si prefieres
    color: Color(0xFF558B2F),
  ),
  onPressed: () async {
    bool canAuth = await BiometricService.isBiometricAvailable();
    
    if (!canAuth) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tu dispositivo no cuenta con autenticación biométrica activa'),
        ),
      );
      return;
    }

    bool authenticated = await BiometricService.authenticate();

    if (authenticated && context.mounted) {
      // 1. Iniciamos sesión en nuestro Provider
      Provider.of<AuthProvider>(context, listen: false).login();

      // 2. Navegamos a la vista principal
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const NovedadesView(),
        ),
      );
    }
  },
),



                  const SizedBox(height: 25),

                  // ==========================================
                  // IR AL REGISTRO
                  // ==========================================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '¿Aún no tienes cuenta? ',
                        style: GoogleFonts.poppins(
                          color: Colors.black54,
                          fontSize: 14,
                        ),
                      ),

                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              transitionDuration: const Duration(milliseconds: 400),
                              pageBuilder: (context, animation, secondaryAnimation) {
                                return const RegisterView();
                              },
                              transitionsBuilder:
                                  (context, animation, secondaryAnimation, child) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: child,
                                );
                              },
                            ),
                          );
                        },

                        child: Text(
                          'Únete aquí',
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
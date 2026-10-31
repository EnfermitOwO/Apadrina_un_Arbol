import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '/widgets/header.dart';
import '/widgets/custom_text_field.dart';
import '../providers/auth_provider.dart';
import '../services/biometric_service.dart';
import 'novedades_view.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  // Controladores para capturar los datos de los inputs
  final TextEditingController _nombreUsuarioController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _nombreUsuarioController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Procesa el registro con validaciones Regex y llamada a MongoDB
  Future<void> _handleRegister() async {
    final nombreUsuario = _nombreUsuarioController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // 1. Validar campos vacíos
    if (nombreUsuario.isEmpty || email.isEmpty || password.isEmpty) {
      _showSnackBar('Por favor llena todos los campos.', Colors.orange);
      return;
    }

    // 2. Validar formato de Correo Electrónico
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(email)) {
      _showSnackBar('Ingresa un correo electrónico válido.', Colors.orange);
      return;
    }

    // 3. Validar Contraseña Segura:
    // Mínimo 8 caracteres, 1 mayúscula, 1 número y 1 carácter especial
    final passwordRegExp = RegExp(
      r'^(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&._-])[A-Za-z\d@$!%*?&._-]{8,}$',
    );

    if (!passwordRegExp.hasMatch(password)) {
      _showSnackBar(
        'La contraseña debe incluir mínimo 8 caracteres, 1 mayúscula, 1 número y 1 carácter especial (@!%*?&._-)',
        Colors.redAccent,
      );
      return;
    }

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // 4. Intentar registro en MongoDB
    String? errorResult = await authProvider.register(nombreUsuario, email, password);

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (errorResult == null) {
      _showSnackBar('¡Cuenta creada e iniciada con éxito!', Colors.green);

      // Redirigir a NovedadesView eliminando las pantallas anteriores de la pila
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const NovedadesView()),
        (route) => false,
      );
    } else if (errorResult == 'CORREO_DUPLICADO') {
      _showSnackBar('El correo electrónico ya está registrado.', Colors.red);
    } else if (errorResult == 'USUARIO_DUPLICADO') {
      _showSnackBar('El nombre de usuario ya está ocupado.', Colors.red);
    } else {
      _showSnackBar('Ocurrió un error al conectar con MongoDB.', Colors.red);
    }
  }

  // Autenticación biométrica rápida (Face ID / Huella)
  Future<void> _handleBiometricRegister(BuildContext context) async {
    bool canAuth = await BiometricService.isBiometricAvailable();

    if (!canAuth) {
      if (context.mounted) {
        _showSnackBar('Tu dispositivo no cuenta con autenticación biométrica activa.', Colors.orange);
      }
      return;
    }

    bool authenticated = await BiometricService.authenticate();

if (authenticated && context.mounted) {
  // Usamos forceLogin para saltarnos la validación de contraseña de texto
  await Provider.of<AuthProvider>(context, listen: false).forceLogin('UsuarioBiometrico');

  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(
      builder: (context) => const NovedadesView(),
    ),
    (route) => false,
  );
}
  }

  void _showSnackBar(String text, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: color,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // CABECERA
            const AuthHeader(
              imageUrl:
                  'https://images.unsplash.com/photo-1542273917363-3b1817f69a2d?auto=format&fit=crop&w=500&q=80',
            ),

            const SizedBox(height: 0),

            // TÍTULO
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

            // FORMULARIO
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  // Nombre de usuario
                  CustomTextField(
                    controller: _nombreUsuarioController,
                    label: 'Nombre de usuario',
                    hintText: 'Liz',
                    prefixIcon: Icons.person,
                  ),

                  const SizedBox(height: 20),

                  // Correo electrónico
                  CustomTextField(
                    controller: _emailController,
                    label: 'Correo electrónico',
                    hintText: 'liz@gmail.com',
                    prefixIcon: Icons.email,
                  ),

                  const SizedBox(height: 20),

                  // Contraseña
                  CustomTextField(
                    controller: _passwordController,
                    label: 'Contraseña',
                    hintText: '********',
                    prefixIcon: Icons.lock,
                    isPassword: true,
                    suffixIcon: const Icon(
                      Icons.visibility_off,
                      color: Color(0xFF33691E),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // BOTÓN REGISTRARSE
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
                      onPressed: _isLoading ? null : _handleRegister,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
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

                  // OPCIÓN BIOMÉTRICA
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
                          Icons.fingerprint,
                          color: Color(0xFF33691E),
                        ),
                        onPressed: () => _handleBiometricRegister(context),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  // REGRESAR AL LOGIN
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
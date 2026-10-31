import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:apadrina_un_arbol/views/myprofile_view.dart';
import '../widgets/theme_provider.dart';
import '../views/arboles_apadrinados.view.dart';
import '../providers/auth_provider.dart'; 
import 'login_view.dart';
import 'register_view.dart';



class PerfilView extends StatelessWidget {
  const PerfilView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context); // <-- Escuchamos si hay sesión
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 28),
          onPressed: () {
            Navigator.of(context).maybePop();
          },
        ),
        title: Text(
          authProvider.isLoggedIn ? 'Mi perfil' : 'Cuenta', // Título dinámico
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 16.0),
        children: [
          // ==========================================
          // 1. SI ESTÁ LOGUEADO: Muestra perfil y árboles
          // ==========================================
          if (authProvider.isLoggedIn) ...[
            _buildOptionTile(
              context: context,
              icon: Icons.person_outline,
              title: 'Mi cuenta',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyProfileView(),
                  ),
                );
              },
            ),
            _buildOptionTile(
              context: context,
              icon: Icons.park_outlined,
              title: 'Mis árboles apadrinados',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ArbolesApadrinadosView(),
                  ),
                );
              },
            ),
            const SizedBox(height: 28),
          ] 
          // ==========================================
          // 2. SI NO ESTÁ LOGUEADO: Muestra Iniciar sesión y Registrarse
          // ==========================================
          else ...[
            _buildOptionTile(
              context: context,
              icon: Icons.login_outlined,
              title: 'Iniciar sesión',
              onTap: () {
               
                 Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginView()));
                
                // (Prueba temporal para simular que entras al dar clic):
                onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const LoginView(), // O la vista de login que tengas
    ),
  );
};
              },
            ),
            _buildOptionTile(
              context: context,
              icon: Icons.person_add_outlined,
              title: 'Registrarse',
              onTap: () {
               
                 Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterView()));
              },
            ),
            const SizedBox(height: 28),
          ],

          // ==========================================
          // AJUSTES GENERALES (Siempre visibles)
          // ==========================================
          Text(
            'Ajustes generales',
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),

          _buildOptionTile(
            context: context,
            icon: Icons.error_outline,
            title: 'Configuración',
            onTap: () {},
          ),
          _buildOptionTile(
            context: context,
            icon: Icons.help_outline,
            title: 'Acerca de nosotros',
            onTap: () {},
          ),
          _buildOptionTile(
            context: context,
            icon: Icons.share_outlined,
            title: 'Compartir aplicación',
            onTap: () {},
          ),

          const SizedBox(height: 12),

          // Switch de Modo Dark & Light
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              Icons.brightness_6_outlined,
              color: theme.colorScheme.primary,
              size: 24,
            ),
            title: Text(
              'Modo\nDark & Light',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
                fontSize: 15,
                height: 1.1,
              ),
            ),
            trailing: Switch(
              value: themeProvider.isDarkMode,
              activeThumbColor: theme.colorScheme.primary,
              activeTrackColor: theme.colorScheme.primary.withValues(alpha: 0.4),
              inactiveThumbColor: Colors.grey.shade400,
              inactiveTrackColor: Colors.grey.shade300,
              onChanged: (bool value) {
                themeProvider.toggleTheme(value);
              },
            ),
          ),

          // ==========================================
          // 3. BOTÓN DE CERRAR SESIÓN (Solo si está logueado)
          // ==========================================
          if (authProvider.isLoggedIn) ...[
            const SizedBox(height: 24),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () {
                authProvider.logout(); // Cierra sesión y actualiza la pantalla
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sesión cerrada correctamente')),
                );
              },
              icon: const Icon(Icons.logout),
              label: const Text(
                'Cerrar sesión',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOptionTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        icon,
        color: theme.colorScheme.primary,
        size: 24,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      onTap: onTap,
    );
  }
}
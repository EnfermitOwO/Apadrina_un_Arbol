import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:apadrina_un_arbol/views/myprofile_view.dart';
import '../widgets/theme_provider.dart';// Asegúrate de que esta ruta apunte a tu theme_provider.dart
import '../views/arboles_apadrinados.view.dart'; // O ajusta la ruta según la estructura de tu proyecto

class PerfilView extends StatelessWidget {
  const PerfilView({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtenemos el proveedor del tema e información del tema actual
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 28),
          onPressed: () {
            Navigator.of(context).maybePop();
          },
        ),
        title: const Text(
          'Perfil',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 16.0),
        children: [
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
  icon: Icons.park_outlined, // Puedes cambiar el icono según corresponda
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
          
          // Switch de Modo Dark & Light conectado al ThemeProvider global
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
                // Modifica el estado globalmente y lo guarda localmente
                themeProvider.toggleTheme(value);
              },
            ),
          ),
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
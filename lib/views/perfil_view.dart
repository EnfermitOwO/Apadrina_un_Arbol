import 'package:flutter/material.dart';
import 'package:apadrina_un_arbol/views/myprofile_view.dart';

class PerfilView extends StatefulWidget {
  const PerfilView({super.key});

  @override
  State<PerfilView> createState() => _PerfilViewState();
}

class _PerfilViewState extends State<PerfilView> {
  // Estado del modo oscuro
  bool isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    // Definimos los colores dinámicos según si está activo el modo oscuro
    final Color colorFondo = isDarkMode ? const Color.fromARGB(255, 49, 47, 47) : Colors.white;
    final Color colorTextoEIconos = isDarkMode ? const Color.fromARGB(255, 153, 240, 153) : const Color(0xFF556B2F);

    return Scaffold(
      backgroundColor: colorFondo,  
      appBar: AppBar(
        backgroundColor: colorFondo,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorTextoEIconos, size: 28),
          onPressed: () {
            Navigator.of(context).maybePop();
          },
        ),
        title: Text(
          'Perfil',
          style: TextStyle(
            color: colorTextoEIconos,
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
            icon: Icons.person_outline,
            title: 'Mi cuenta',
            color: colorTextoEIconos,
            onTap: () {
              // NAVEGACIÓN A LA SECCIÓN DE PERFIL DETALLADO
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MyProfileView(), // Con M y P mayúsculas
                ),
              );
            },
          ),
                  
          
          const SizedBox(height: 28),
          
          Text(
            'Ajustes generales',
            style: TextStyle(
              color: colorTextoEIconos,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          
          _buildOptionTile(
            icon: Icons.error_outline,
            title: 'Configuración',
            color: colorTextoEIconos,
            onTap: () {},
          ),
          _buildOptionTile(
            icon: Icons.help_outline,
            title: 'Acerca de nosotros',
            color: colorTextoEIconos,
            onTap: () {},
          ),
          _buildOptionTile(
            icon: Icons.share_outlined,
            title: 'Compartir aplicación',
            color: colorTextoEIconos,
            onTap: () {},
          ),
          
          const SizedBox(height: 12),
          
          // Switch de Modo Dark & Light
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              Icons.brightness_6_outlined,
              color: colorTextoEIconos,
              size: 24,
            ),
            title: Text(
              'Modo\nDark & Light',
              style: TextStyle(
                color: colorTextoEIconos,
                fontWeight: FontWeight.w600,
                fontSize: 15,
                height: 1.1,
              ),
            ),
            trailing: Switch(
              value: isDarkMode,
              activeThumbColor: colorTextoEIconos,
              activeTrackColor: colorTextoEIconos.withValues(alpha: 0.4),
              inactiveThumbColor: Colors.grey.shade400,
              inactiveTrackColor: Colors.grey.shade300,
              onChanged: (bool value) {
                // Al presionar el botón, actualizamos el estado y la pantalla cambia de color
                setState(() {
                  isDarkMode = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        icon,
        color: color,
        size: 24,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      onTap: onTap,
    );
  }
}
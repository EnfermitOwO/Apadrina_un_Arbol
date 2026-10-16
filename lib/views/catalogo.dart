import 'package:flutter/material.dart';

// Importamos la pantalla principal (main.dart) y los widgets reutilizables
import '../main.dart';
import '../widgets/custom_header.dart';
import '../widgets/custom_bottom_nav.dart';
import 'detail_view.dart';

class CatalogoScreen extends StatefulWidget {
  const CatalogoScreen({super.key});

  @override
  State<CatalogoScreen> createState() => _CatalogoScreenState();
}

class _CatalogoScreenState extends State<CatalogoScreen> {
  // Paleta de colores de la interfaz
  final Color verdePrincipal = const Color(0xFF5D8736);
  final Color verdeClaroFondo = const Color(0xFFEEF7E8);

  // 📌 CONTROLADOR Y LISTA FILTRADA PARA LA BÚSQUEDA
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> _arbolesFiltrados = [];

  // 📌 BASE DE DATOS LOCAL DE ÁRBOLES
  final List<Map<String, String>> arboles = [
    {
      'nombre': 'Duraznillo',
      'altura': 'Altura 6m - 15m',
      'epoca': 'Época: Primavera',
      'imagen': 'https://upload.wikimedia.org/wikipedia/commons/0/00/Solanum_glaucophyllum_1.jpg?utm_source=es.wikipedia.org&utm_campaign=index&utm_content=original',
    },
    {
      'nombre': 'Bignonia amarilla',
      'altura': 'Altura 6m - 15m',
      'epoca': 'Época: Primavera',
      'imagen': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTbKXdHkc4lM6wChGSw4KGsqM5Ti6G5Az0_Yd88Yona0EnqoDVB8fhWqNc&s=10',
    },
    {
      'nombre': 'Guayacán Blanco',
      'altura': 'Altura 5m - 12m',
      'epoca': 'Época: Primavera',
      'imagen': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRrGOgqRoImzxIlPme1IyYj7Y_ySKd9v5nrS4-jJxb3mhPHmCW--KmMJPqK&s=10',
    },
    {
      'nombre': 'Árbol Orquídea',
      'altura': 'Altura 4m - 10m',
      'epoca': 'Época: Verano',
      'imagen': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSBvaFXmVWVQbO4fTsj7oSWlGLgDdBAj2rVGGJB50aWIHjLyYjs3kQyB6ry&s=10',
    },
  ];

  @override
  void initState() {
    super.initState();
    // Al iniciar, la lista filtrada contiene todos los árboles
    _arbolesFiltrados = arboles;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // 📌 FUNCIÓN PARA FILTRAR ÁRBOLES
  void _filtrarArboles(String texto) {
    setState(() {
      if (texto.isEmpty) {
        _arbolesFiltrados = arboles;
      } else {
        _arbolesFiltrados = arboles
            .where((arbol) => arbol['nombre']!
                .toLowerCase()
                .contains(texto.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      
      appBar: const CustomHeader(),
      
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(),
            const SizedBox(height: 12),
            _buildBanner(),
            const SizedBox(height: 16),
            _buildGridArboles(),
          ],
        ),
      ),

      bottomNavigationBar: CustomBottomNav(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          } else if (index == 1) {
            // Ya estás en Catálogo
          }
        },
      ),
    );
  }

  // 📌 BARRA DE BÚSQUEDA FUNCIONAL
  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      onChanged: _filtrarArboles, // Filtra conforme escribes
      decoration: InputDecoration(
        hintText: 'Busca tu árbol',
        hintStyle: TextStyle(color: Colors.grey[600]),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  _filtrarArboles('');
                },
              )
            : Icon(Icons.search, color: verdePrincipal),
        filled: true,
        fillColor: verdeClaroFondo,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // Banner principal
  Widget _buildBanner() {
    return Container(
      height: 160,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: const DecorationImage(
          image: NetworkImage(
            'https://pbs.twimg.com/media/A9xnHQGCcAAsn1D?format=webp&name=large',
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [Colors.black.withValues(alpha: 0.6), Colors.transparent],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Adopta a\nMango',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: verdePrincipal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  ),
                  child: const Text(
                    'Adoptar',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),  
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 📌 GRID DE ÁRBOLES ACTUALIZADO CON LOS RESULTADOS FILTRADOS
  Widget _buildGridArboles() {
    if (_arbolesFiltrados.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 30.0),
          child: Text(
            'No se encontraron árboles.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.82,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
      ),
      itemCount: _arbolesFiltrados.length,
      itemBuilder: (context, index) {
        final item = _arbolesFiltrados[index];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  item['imagen']!,
                  height: 100,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                item['nombre']!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.straighten, size: 14, color: verdePrincipal),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      item['altura']!,
                      style: const TextStyle(fontSize: 11, color: Colors.black87),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(Icons.eco, size: 14, color: verdePrincipal),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      item['epoca']!,
                      style: const TextStyle(fontSize: 11, color: Colors.black87),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 32,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DetalleArbolScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: verdePrincipal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  child: const Text(
                    'Ver más',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
} 
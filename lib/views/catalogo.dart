import 'package:flutter/material.dart';

// Importamos la pantalla principal (main.dart), widgets y el servicio de MongoDB
import '../main.dart';
import '../widgets/custom_header.dart';
import '../widgets/custom_bottom_nav.dart';
import '../mongodb/mongo_service.dart';
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

  // CONTROLADOR Y LISTAS PARA LA BÚSQUEDA Y MONGODB
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _allArboles = [];
  List<Map<String, dynamic>> _arbolesFiltrados = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarArbolesDesdeMongo();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Carga los datos dinámicos desde la colección 'arboles' en MongoDB Atlas
  Future<void> _cargarArbolesDesdeMongo() async {
    try {
      final coleccion = MongoService.getCollection('arboles');
      final resultados = await coleccion.find().toList();

      setState(() {
        _allArboles = resultados;
        _arbolesFiltrados = resultados;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error al cargar árboles desde MongoDB: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  // FUNCIÓN PARA FILTRAR ÁRBOLES EN TIEMPO REAL
  void _filtrarArboles(String texto) {
    setState(() {
      if (texto.isEmpty) {
        _arbolesFiltrados = _allArboles;
      } else {
        _arbolesFiltrados = _allArboles.where((arbol) {
          final nombreComun = (arbol['nombre_comun'] ?? '').toString().toLowerCase();
          final nombreCientifico = (arbol['nombre_cientifico'] ?? '').toString().toLowerCase();
          final query = texto.toLowerCase();
          return nombreComun.contains(query) || nombreCientifico.contains(query);
        }).toList();
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
            _isLoading
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40.0),
                      child: CircularProgressIndicator(color: verdePrincipal),
                    ),
                  )
                : _buildGridArboles(),
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

  // BARRA DE BÚSQUEDA FUNCIONAL
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

  // GRID DE ÁRBOLES ACTUALIZADO CON DATOS REALES DE MONGODB
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
        childAspectRatio: 0.72, // Proporción ajustada para evitar desbordes visuales
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
      ),
      itemCount: _arbolesFiltrados.length,
      itemBuilder: (context, index) {
        final item = _arbolesFiltrados[index];

        final String nombre = item['nombre_comun'] ?? 'Sin Nombre';
        final String altura = item['altura'] != null ? 'Altura ${item['altura']}' : 'Altura N/D';
        final String epoca = item['epoca'] != null ? 'Época: ${item['epoca']}' : 'Época: N/D';
        final String imagenUrl = item['imagen'] ?? '';

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                child: Image.network(
                  imagenUrl,
                  height: 105,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 105,
                    color: Colors.grey.shade200,
                    child: Icon(Icons.image_not_supported, color: Colors.grey.shade400),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nombre,
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
                            altura,
                            style: const TextStyle(fontSize: 11, color: Colors.black87),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
                            epoca,
                            style: const TextStyle(fontSize: 11, color: Colors.black87),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
                              builder: (context) => DetalleArbolScreen(arbol: item),
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
              ),
            ],
          ),
        );
      },
    );
  }
}
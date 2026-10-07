import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Importación de componentes personalizados del proyecto
import '../widgets/custom_header.dart';
import '../widgets/custom_bottom_nav.dart';
import '../widgets/custom_text_field.dart';

class SponsoredTree {
  final String name;
  final String adoptionDate;
  final String imageUrl;

  SponsoredTree({
    required this.name,
    required this.adoptionDate,
    required this.imageUrl,
  });
}

class ArbolesApadrinadosView extends StatefulWidget {
  const ArbolesApadrinadosView({Key? key}) : super(key: key);

  @override
  State<ArbolesApadrinadosView> createState() => _ArbolesApadrinadosViewState();
}

class _ArbolesApadrinadosViewState extends State<ArbolesApadrinadosView> {
  final TextEditingController _searchController = TextEditingController();

  final String _userName = 'Liz';

  final List<SponsoredTree> _allTrees = [
    SponsoredTree(
      name: 'Pato cuack',
      adoptionDate: '12/03/2026',
      imageUrl: 'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?w=500',
    ),
    SponsoredTree(
      name: 'Mango',
      adoptionDate: '18/09/2026',
      imageUrl: 'https://images.unsplash.com/photo-1553279768-865429fa0078?w=500',
    ),
  ];

  List<SponsoredTree> _filteredTrees = [];

  @override
  void initState() {
    super.initState();
    _filteredTrees = _allTrees;
  }

  void _filterTrees(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredTrees = _allTrees;
      } else {
        _filteredTrees = _allTrees
            .where((tree) => tree.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final lightGreenBg = primaryColor.withValues(alpha: 0.15);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      // Usamos tu CustomHeader exacto sin parámetros
      appBar: const CustomHeader(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            //hola
           // Campo de búsqueda
            Container(
              decoration: BoxDecoration(
                color: lightGreenBg,
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _filterTrees,
                style: GoogleFonts.poppins(
                  color: theme.colorScheme.onSurface,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: 'Busca tus árboles',
                  hintStyle: GoogleFonts.poppins(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    fontSize: 14,
                  ),
                  suffixIcon: Icon(Icons.search, color: primaryColor, size: 26),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
              ),
            ),

            const SizedBox(height: 25),

            // Contador de árboles
            Row(
              children: [
                Text(
                  '$_userName, tus árboles apadrinados son: ',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
                Text(
                  '${_filteredTrees.length}',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            // Tarjetas de árboles
            Expanded(
              child: ListView.builder(
                itemCount: _filteredTrees.length,
                itemBuilder: (context, index) {
                  final tree = _filteredTrees[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: lightGreenBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        // Imagen circular del árbol
                        ClipOval(
                          child: Image.network(
                            tree.imageUrl,
                            width: 85,
                            height: 85,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 85,
                              height: 85,
                              color: primaryColor.withValues(alpha: 0.3),
                              child: Icon(Icons.park, size: 40, color: primaryColor),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Información del árbol
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tree.name,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_month_outlined,
                                    size: 16,
                                    color: primaryColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Adoptado: ${tree.adoptionDate}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                height: 32,
                                child: ElevatedButton(
                                  onPressed: () {
                                    // Ver certificado
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryColor,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 14),
                                  ),
                                  child: Text(
                                    'Ver certificado',
                                    style: GoogleFonts.poppins(
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
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 3,
        onTap: (index) {},
      ),
    );
  }
}
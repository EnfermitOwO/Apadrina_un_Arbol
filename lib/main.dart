import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


// O usando import relativo:
import 'views/catalogo.dart';
 // apartado de catalogo
import 'widgets/custom_header.dart';
import 'widgets/custom_bottom_nav.dart';
import 'widgets/welcome_section.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Apadrina un Árbol',
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Lista de textos originales para el carrusel
  final List<String> _bannerTexts = [
    "Prueba nuestro juego",
    "Apadrina un árbol",
    "Ayuda al planeta",
  ];

  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    // Iniciamos en un número gigante en el centro para permitir scroll infinito en ambas direcciones
    _pageController = PageController(
      viewportFraction: 0.78,
      initialPage: 1000000 - (1000000 % 3),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 1. HEADER SEPARADO
              const CustomHeader(),
              const Divider(height: 1),

              // 2. BIENVENIDA SEPARADA
              const WelcomeSection(),

              const SizedBox(height: 10),

              // ==========================
              // CARRUSEL INFINITO (Con vista previa lateral)
              // ==========================
              SizedBox(
                height: 180,
                child: PageView.builder(
                  controller: _pageController,
                  itemBuilder: (context, index) {
                    // Usamos operador módulo (%) para repetir los elementos cíclicamente de forma infinita
                    final actualIndex = index % _bannerTexts.length;
                    return bannerCard(_bannerTexts[actualIndex]);
                  },
                ),
              ),

              const SizedBox(height: 10),

              // PUNTITOS
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.circle, size: 8, color: Colors.grey),
                  SizedBox(width: 6),
                  Icon(Icons.circle, size: 8, color: Color(0xFF5D8736)),
                  SizedBox(width: 6),
                  Icon(Icons.circle, size: 8, color: Colors.grey),
                ],
              ),

              const SizedBox(height: 25),

              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "Apadrina tu árbol hoy mismo",
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF5D8736),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // TARJETAS DE ACCIÓN
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  actionCard(Icons.spa, "Elígelo"),
                  actionCard(Icons.favorite, "Cuida"),
                  actionCard(Icons.park, "Visualiza"),
                ],
              ),

              const SizedBox(height: 30),

              // BANNER CATÁLOGO
           // BANNER CATÁLOGO
GestureDetector(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CatalogoScreen()), // Usa aquí la clase de catalogo.dart
    );
  },
  child: Container(
    height: 120,
    margin: const EdgeInsets.symmetric(horizontal: 20),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: const Color(0xFF5D8736),
      borderRadius: BorderRadius.circular(20),
      image: const DecorationImage(
        image: AssetImage('assets/images/tronky.png'),
        fit: BoxFit.cover,
        colorFilter: ColorFilter.mode(
          Colors.black45,
          BlendMode.darken,
        ),
      ),
    ),
    child: Row(
      children: [
        Expanded(
          child: Text(
            "Explorar\nCatálogo",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
              height: 1.1,
            ),
          ),
        ),
        const Icon(
          Icons.arrow_forward_ios,
          color: Colors.white,
        ),
      ],
    ),
  ),
),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),

      // MENÚ INFERIOR REUTILIZABLE
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 0,
        onTap: (index) {
          // Aquí puedes manejar la navegación entre pantallas si lo deseas
        },
      ),
    );
  }
}

// Widget auxiliar del carrusel con GoogleFonts
Widget bannerCard(String texto) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 6),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      image: const DecorationImage(
        image: AssetImage('assets/images/tronky.png'),
        fit: BoxFit.cover,
        colorFilter: ColorFilter.mode(
          Colors.black26,
          BlendMode.darken,
        ),
      ),
    ),
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Text(
          texto,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            height: 1.1,
          ),
        ),
      ),
    ),
  );
}

// Widget auxiliar de las tarjetas de acción con GoogleFonts
Widget actionCard(IconData icon, String texto) {
  return Container(
    width: 100,
    height: 90,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          blurRadius: 6,
          color: Colors.black.withValues(alpha: 0.06),
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: const Color(0xFF5D8736), size: 30),
        const SizedBox(height: 6),
        Text(
          texto,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    ),
  );
}
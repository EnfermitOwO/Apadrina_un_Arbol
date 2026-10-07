import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'widgets/theme_provider.dart';
import 'views/catalogo.dart';
import 'widgets/custom_header.dart';
import 'widgets/custom_bottom_nav.dart';
import 'widgets/welcome_section.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Apadrina un Árbol',
      theme: ThemeProvider.lightTheme,
      darkTheme: ThemeProvider.darkTheme,
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
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
  final List<String> _bannerTexts = [
    "Prueba nuestro juego",
    "Apadrina un árbol",
    "Ayuda al planeta",
  ];

  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor, // <--- CAMBIO DINÁMICO
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const CustomHeader(),
              Divider(height: 1, color: theme.dividerColor),

              const WelcomeSection(),

              const SizedBox(height: 10),

              // CARRUSEL INFINITO
              SizedBox(
                height: 180,
                child: PageView.builder(
                  controller: _pageController,
                  itemBuilder: (context, index) {
                    final actualIndex = index % _bannerTexts.length;
                    return bannerCard(_bannerTexts[actualIndex]);
                  },
                ),
              ),

              const SizedBox(height: 10),

              // PUNTITOS
              Row(
               mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.circle, size: 8, color: Colors.grey),
                  const SizedBox(width: 6),
                  Icon(Icons.circle, size: 8, color: theme.colorScheme.primary),
                  const SizedBox(width: 6),
                  const Icon(Icons.circle, size: 8, color: Colors.grey),
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
                      color: theme.colorScheme.primary, // <--- CAMBIO DINÁMICO
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // TARJETAS DE ACCIÓN
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  actionCard(context, Icons.spa, "Elígelo"),
                  actionCard(context, Icons.favorite, "Cuida"),
                  actionCard(context, Icons.park, "Visualiza"),
                ],
              ),

              const SizedBox(height: 30),

              // BANNER CATÁLOGO
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CatalogoScreen()),
                  );
                },
                child: Container(
                  height: 120,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
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

      bottomNavigationBar: CustomBottomNav(
        currentIndex: 0,
        onTap: (index) {},
      ),
    );
  }
}

// Widget auxiliar del carrusel
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

// Widget auxiliar de las tarjetas de acción adaptado al tema
Widget actionCard(BuildContext context, IconData icon, String texto) {
  final theme = Theme.of(context);

  return Container(
    width: 100,
    height: 90,
    decoration: BoxDecoration(
      color: theme.colorScheme.surface, // <--- CAMBIO DINÁMICO
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          blurRadius: 6,
          color: Colors.black.withValues(alpha: 0.1),
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Column(
   mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 30),
        const SizedBox(height: 6),
        Text(
          texto,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface, // <--- CAMBIO DINÁMICO
          ),
        ),
      ],
    ),
  );
}
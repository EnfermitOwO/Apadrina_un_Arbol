import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:apadrina_un_arbol/widgets/custom_bottom_nav.dart';
import 'package:apadrina_un_arbol/widgets/post_card.dart';
import 'package:apadrina_un_arbol/widgets/custom_header.dart';

class NovedadesView extends StatefulWidget {
  const NovedadesView({super.key});

  @override
  State<NovedadesView> createState() => _NovedadesViewState();
}

class _NovedadesViewState extends State<NovedadesView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header personalizado
            const CustomHeader(),

            // Pestañas (Para ti / Amigos / Añadir +)
            TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF2E7D32),
              unselectedLabelColor: Colors.grey,
              indicatorColor: const Color(0xFF2E7D32),
              labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
              unselectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.normal, fontSize: 14),
              tabs: const [
                Tab(text: 'Para ti'),
                Tab(text: 'Amigos'),
                Tab(text: 'Añadir +'),
              ],
            ),

            const Divider(height: 1, color: Color(0xFFE0E0E0)),

            // Contenido dinámico según la pestaña seleccionada
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // --- PESTAÑA 1: "Para ti" ---
                  ListView(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: const [
                      PostCard(
                        avatarUrl: 'https://i.imgur.com/7y9XPdK.png',
                        username: 'Michael Scott',
                        text: 'Yo planté este árbol. De nada, Tierra. Aquí va un texto más largo para probar cómo baja de línea automáticamente sin salirse de la pantalla.',
                        imageUrl: 'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?q=80&w=1000&auto=format&fit=crop',
                        initialLikes: 10,
                        comments: '13',
                        shares: '2',
                      ),
                      Divider(height: 24, thickness: 6, color: Color(0xFFF2F4F1)),
                      PostCard(
                        avatarUrl: 'https://i.imgur.com/BoN9kdC.png',
                        username: 'Dewey_',
                        text: 'el futuro es hoy, viste viejo',
                        imageUrl: 'https://images.unsplash.com/photo-1513836279014-a89f7a76ae86?q=80&w=1000&auto=format&fit=crop',
                        initialLikes: 10,
                        comments: '13',
                        shares: '2',
                      ),
                    ],
                  ),

                  // --- PESTAÑA 2: "Amigos" ---
                  ListView(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: const [
                      PostCard(
                        avatarUrl: 'https://i.imgur.com/7y9XPdK.png',
                        username: 'Dwight',
                        text: 'Es una idea ridícula... pero admito que debió ocurrirse a mi primero. Los árboles son míos.',
                        imageUrl: null, // <- Al ser null, la tarjeta se adapta automáticamente a solo texto
                        initialLikes: 10,
                        comments: '13',
                        shares: '2',
                      ),
                      Divider(height: 24, thickness: 6, color: Color(0xFFF2F4F1)),
                      PostCard(
                        avatarUrl: 'https://i.imgur.com/7y9XPdK.png',
                        username: 'Rubí',
                        text: 'Analizando las historias de usuario para el siguiente sprint.',
                        imageUrl: 'https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?q=80&w=1000&auto=format&fit=crop',
                        initialLikes: 15,
                        comments: '3',
                        shares: '0',
                      ),
                    ],
                  ),

                  // --- PESTAÑA 3: "Añadir +" (Con diseño de barra de búsqueda de amigos) ---
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F8E9), // Fondo verde pastel claro
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: TextField(
                            style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
                            decoration: InputDecoration(
                              hintText: 'Buscar nuevos amigos',
                              hintStyle: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
                              prefixIcon: const SizedBox(width: 16),
                              suffixIcon: const Padding(
                                padding: EdgeInsets.only(right: 12.0),
                                child: Icon(Icons.search, color: Color(0xFF388E3C)),
                              ),
                              suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(
        currentIndex: 2,
      ),
    );
  }
}
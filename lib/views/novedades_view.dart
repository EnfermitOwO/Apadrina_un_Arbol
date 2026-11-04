import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:apadrina_un_arbol/widgets/custom_bottom_nav.dart';
import 'package:apadrina_un_arbol/widgets/post_card.dart';
import 'package:apadrina_un_arbol/widgets/custom_header.dart';
import 'package:apadrina_un_arbol/models/foro_remote_model.dart';
import 'package:apadrina_un_arbol/services/foro_service.dart';

class NovedadesView extends StatefulWidget {
  const NovedadesView({super.key});

  @override
  State<NovedadesView> createState() => _NovedadesViewState();
}

class _NovedadesViewState extends State<NovedadesView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<ForoRemoteModel>> _futurePosts;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _futurePosts = ForoService.obtenerPosts(); // Carga de datos reales desde la API/MongoDB
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
                  // --- PESTAÑA 1: "Para ti" (Dinámico con MongoDB) ---
                  FutureBuilder<List<ForoRemoteModel>>(
                    future: _futurePosts,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(color: Color(0xFF388E3C)),
                        );
                      } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                          child: Text(
                            'No hay publicaciones en el foro todavía.',
                            style: GoogleFonts.poppins(color: Colors.grey),
                          ),
                        );
                      }

                      final posts = snapshot.data!;
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          final post = posts[index];
                          return Column(
                            children: [
                              PostCard(
                                avatarUrl: 'https://i.imgur.com/7y9XPdK.png',
                                username: post.nombreUsuario,
                                text: post.mensaje,
                                imageUrl: post.imagen, // Si es null, la tarjeta se adapta automáticamente
                                initialLikes: 10,
                                comments: post.comentarios.length.toString(),
                                shares: '2',
                              ),
                              const Divider(height: 24, thickness: 6, color: Color(0xFFF2F4F1)),
                            ],
                          );
                        },
                      );
                    },
                  ),

                  // --- PESTAÑA 2: "Amigos" (Carga dinámica compartida o filtrada) ---
                  FutureBuilder<List<ForoRemoteModel>>(
                    future: _futurePosts,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(color: Color(0xFF388E3C)),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                          child: Text(
                            'No hay publicaciones de amigos.',
                            style: GoogleFonts.poppins(color: Colors.grey),
                          ),
                        );
                      }

                      final posts = snapshot.data!;
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          final post = posts[index];
                          return Column(
                            children: [
                              PostCard(
                                avatarUrl: 'https://i.imgur.com/BoN9kdC.png',
                                username: post.nombreUsuario,
                                text: post.mensaje,
                                imageUrl: post.imagen,
                                initialLikes: 15,
                                comments: post.comentarios.length.toString(),
                                shares: '1',
                              ),
                              const Divider(height: 24, thickness: 6, color: Color(0xFFF2F4F1)),
                            ],
                          );
                        },
                      );
                    },
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
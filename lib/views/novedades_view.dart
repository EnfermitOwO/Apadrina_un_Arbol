
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:apadrina_un_arbol/widgets/custom_bottom_nav.dart';
import 'package:apadrina_un_arbol/widgets/post_card.dart';
import 'package:apadrina_un_arbol/widgets/custom_header.dart';

import 'package:apadrina_un_arbol/models/foro_remote_model.dart';
import 'package:apadrina_un_arbol/models/amigo_model.dart';

import 'package:apadrina_un_arbol/services/foro_service.dart';
import 'package:apadrina_un_arbol/services/amigos_service.dart';

import 'package:apadrina_un_arbol/providers/auth_provider.dart';

import 'buscar_amigos_view.dart';

class NovedadesView extends StatefulWidget {
  const NovedadesView({super.key});

  @override
  State<NovedadesView> createState() => _NovedadesViewState();
}

class _NovedadesViewState extends State<NovedadesView>
    with SingleTickerProviderStateMixin {

  late TabController _tabController;

  late Future<List<ForoRemoteModel>> _futurePosts;
  late Future<List<AmigoModel>> _futureAmigos;

  String _emailUsuario = '';

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 3, vsync: this);

    _emailUsuario = Provider.of<AuthProvider>(
      context,
      listen: false,
    ).currentUser?['email']?.toString() ?? '';

    _futurePosts = ForoService.obtenerPosts();
    _futureAmigos = _obtenerAmigos();
  }

  Future<List<AmigoModel>> _obtenerAmigos() {
    return AmigosService.obtenerAmigos(
      emailUsuario: _emailUsuario,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Actualizar la lista de amigos
  void _actualizarAmigos() {
    if (_emailUsuario.isNotEmpty) {
      setState(() {
        _futureAmigos = _obtenerAmigos();
      });
    }
  }

  // Construir tarjetas de publicaciones
  Widget _construirLista(
    List<ForoRemoteModel> posts, {
    bool amigos = false,
  }) {
    if (posts.isEmpty) {
      return Center(
        child: Text(
          amigos
              ? 'Tus amigos todavía no tienen publicaciones.'
              : 'No hay publicaciones en el foro todavía.',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];

        return Column(
          children: [
            PostCard(
              avatarUrl: amigos
                  ? 'https://i.imgur.com/BoN9kdC.png'
                  : 'https://i.imgur.com/7y9XPdK.png',
              username: post.nombreUsuario,
              text: post.mensaje,
              imageUrl: post.imagen,
              initialLikes: amigos ? 15 : 10,
              comments: post.comentarios.length.toString(),
              shares: amigos ? '1' : '2',
            ),
            const Divider(
              height: 24,
              thickness: 6,
              color: Color(0xFFF2F4F1),
            ),
          ],
        );
      },
    );
  }

  // Pestaña Para ti
  Widget _pestanaParaTi() {
    return FutureBuilder<List<ForoRemoteModel>>(
      future: _futurePosts,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF388E3C),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Center(
            child: Text(
              'No se pudieron cargar las publicaciones.',
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          );
        }

        return _construirLista(snapshot.data!);
      },
    );
  }

  // Pestaña Amigos
  Widget _pestanaAmigos() {
    return FutureBuilder<List<AmigoModel>>(
      future: _futureAmigos,
      builder: (context, amigosSnapshot) {

        if (amigosSnapshot.connectionState ==
            ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF388E3C),
            ),
          );
        }

        if (amigosSnapshot.hasError ||
            !amigosSnapshot.hasData) {
          return Center(
            child: Text(
              'No se pudo cargar tu lista de amigos.',
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          );
        }

        final correosAmigos = amigosSnapshot.data!
            .map((amigo) => amigo.email.trim().toLowerCase())
            .where((email) => email.isNotEmpty)
            .toSet();

        if (correosAmigos.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Todavía no tienes amigos agregados.\n'
                '¡Busca personas para ver sus publicaciones!',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ),
          );
        }

        return FutureBuilder<List<ForoRemoteModel>>(
          future: _futurePosts,
          builder: (context, postsSnapshot) {

            if (postsSnapshot.connectionState ==
                ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF388E3C),
                ),
              );
            }

            if (postsSnapshot.hasError ||
                !postsSnapshot.hasData) {
              return Center(
                child: Text(
                  'No se pudieron cargar las publicaciones.',
                  style: GoogleFonts.poppins(color: Colors.grey),
                ),
              );
            }

            final publicacionesAmigos =
                postsSnapshot.data!.where((post) {
              return correosAmigos.contains(
                post.emailUsuario.trim().toLowerCase(),
              );
            }).toList();

            return _construirLista(
              publicacionesAmigos,
              amigos: true,
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const CustomHeader(),

            TabBar(
              controller: _tabController,
              onTap: (index) {
                if (index == 1) {
                  _actualizarAmigos();
                }
              },
              labelColor: const Color(0xFF2E7D32),
              unselectedLabelColor: Colors.grey,
              indicatorColor: const Color(0xFF2E7D32),
              labelStyle: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              unselectedLabelStyle: GoogleFonts.poppins(
                fontWeight: FontWeight.normal,
                fontSize: 14,
              ),
              tabs: const [
                Tab(text: 'Para ti'),
                Tab(text: 'Amigos'),
                Tab(text: 'Añadir +'),
              ],
            ),

            const Divider(
              height: 1,
              color: Color(0xFFE0E0E0),
            ),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _pestanaParaTi(),
                  _pestanaAmigos(),
                  const BuscarAmigosView(),
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

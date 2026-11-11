
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:apadrina_un_arbol/widgets/custom_bottom_nav.dart';
import 'package:apadrina_un_arbol/widgets/post_card.dart';

import '../services/cloudinary_service.dart';
import '../providers/auth_provider.dart';
import '../models/amigo_model.dart';
import '../services/amigos_service.dart';
import '../models/foro_remote_model.dart';
import '../services/foro_service.dart';

class MyProfileView extends StatefulWidget {
  const MyProfileView({super.key});

  @override
  State<MyProfileView> createState() => _MyProfileViewState();
}

class _MyProfileViewState extends State<MyProfileView> {
  String _username = 'Usuario';
  String _bio = 'Sin Descripción';
  String? _profileImageUrl;
  String? _bannerImageUrl;

  List<AmigoModel> _amigos = [];
  bool _cargandoAmigos = true;

  List<ForoRemoteModel> _posts = [];
  bool _cargandoPosts = true;

  @override
  void initState() {
    super.initState();
    _cargarDatosUsuario();
    _cargarAmigos();
    _cargarMisPublicaciones();
  }

  // ==========================================
  // DATOS DEL USUARIO
  // ==========================================

  void _cargarDatosUsuario() {
    final authProvider = Provider.of<AuthProvider>(
      context,
      listen: false,
    );

    final user = authProvider.currentUser;

    if (user != null && mounted) {
      setState(() {
        _username = user['nombre_usuario']?.toString() ?? 'Usuario';
        _bio = user['bio']?.toString() ?? 'Sin Descripción';
        _profileImageUrl = user['foto_perfil']?.toString();
        _bannerImageUrl = user['foto_portada']?.toString();
      });
    }
  }

  String _obtenerEmailUsuario() {
    final authProvider = Provider.of<AuthProvider>(
      context,
      listen: false,
    );

    return authProvider.currentUser?['email']
            ?.toString()
            .trim()
            .toLowerCase() ??
        '';
  }

  // ==========================================
  // CARGAR AMIGOS
  // ==========================================

  Future<void> _cargarAmigos() async {
    final email = _obtenerEmailUsuario();

    if (email.isEmpty) {
      if (mounted) {
        setState(() => _cargandoAmigos = false);
      }
      return;
    }

    try {
      final amigos = await AmigosService.obtenerAmigos(
        emailUsuario: email,
      );

      if (!mounted) return;

      setState(() {
        _amigos = amigos;
        _cargandoAmigos = false;
      });
    } catch (e) {
      debugPrint('Error cargando amigos: $e');

      if (mounted) {
        setState(() => _cargandoAmigos = false);
      }
    }
  }

  // ==========================================
  // CARGAR MIS PUBLICACIONES
  // ==========================================

  Future<void> _cargarMisPublicaciones() async {
    final email = _obtenerEmailUsuario();

    if (email.isEmpty) {
      if (mounted) {
        setState(() => _cargandoPosts = false);
      }
      return;
    }

    try {
      final todasLasPublicaciones = await ForoService.obtenerPosts();

      final misPublicaciones = todasLasPublicaciones.where((post) {
        return post.emailUsuario.trim().toLowerCase() == email;
      }).toList();

      if (!mounted) return;

      setState(() {
        _posts = misPublicaciones;
        _cargandoPosts = false;
      });
    } catch (e) {
      debugPrint('Error cargando mis publicaciones: $e');

      if (mounted) {
        setState(() => _cargandoPosts = false);
      }
    }
  }

  // ==========================================
  // SECCIÓN DE AMIGOS
  // ==========================================

  Widget _construirSeccionAmigos() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Mis amigos',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            Text(
              '${_amigos.length} amigos',
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        if (_cargandoAmigos)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(15),
              child: CircularProgressIndicator(
                color: Color(0xFF388E3C),
              ),
            ),
          )
        else if (_amigos.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.people_outline,
                  size: 35,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 6),
                Text(
                  'Todavía no tienes amigos.',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          )
        else
          SizedBox(
            height: 105,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _amigos.length,
              itemBuilder: (context, index) {
                final amigo = _amigos[index];

                final tieneFoto = amigo.fotoPerfil != null &&
                    amigo.fotoPerfil!.isNotEmpty;

                return Container(
                  width: 78,
                  margin: const EdgeInsets.only(right: 14),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 29,
                        backgroundColor:
                            theme.colorScheme.primary.withValues(alpha: 0.15),
                        backgroundImage: tieneFoto
                            ? NetworkImage(amigo.fotoPerfil!)
                            : null,
                        child: !tieneFoto
                            ? Icon(
                                Icons.person,
                                color: theme.colorScheme.primary,
                                size: 30,
                              )
                            : null,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        amigo.nombreUsuario,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  // ==========================================
  // EDITAR PERFIL
  // ==========================================

  void _showEditProfileModal() {
    final TextEditingController nameController =
        TextEditingController(text: _username);
    final TextEditingController bioController =
        TextEditingController(text: _bio);

    final theme = Theme.of(context);

    String? tempProfileUrl = _profileImageUrl;
    String? tempBannerUrl = _bannerImageUrl;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(modalContext).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Editar Perfil',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),

                    const SizedBox(height: 15),

                    TextField(
                      controller: nameController,
                      style: TextStyle(color: theme.colorScheme.onSurface),
                      decoration: InputDecoration(
                        labelText: 'Nombre de usuario',
                        labelStyle: TextStyle(
                          color: theme.colorScheme.primary,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: theme.colorScheme.primary,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    TextField(
                      controller: bioController,
                      style: TextStyle(color: theme.colorScheme.onSurface),
                      decoration: InputDecoration(
                        labelText: 'Descripción / Biografía',
                        labelStyle: TextStyle(
                          color: theme.colorScheme.primary,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: theme.colorScheme.primary,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    ListTile(
                      leading: Icon(
                        Icons.image,
                        color: theme.colorScheme.primary,
                      ),
                      title: Text(
                        'Cambiar foto de portada',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      onTap: () async {
                        final url =
                            await CloudinaryService.subirImagenDesdeGaleria(
                          esPerfil: false,
                        );

                        if (url != null && modalContext.mounted) {
                          setModalState(() => tempBannerUrl = url);
                        }
                      },
                    ),

                    ListTile(
                      leading: Icon(
                        Icons.account_circle,
                        color: theme.colorScheme.primary,
                      ),
                      title: Text(
                        'Cambiar foto de perfil',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      onTap: () async {
                        final url =
                            await CloudinaryService.subirImagenDesdeGaleria(
                          esPerfil: true,
                        );

                        if (url != null && modalContext.mounted) {
                          setModalState(() => tempProfileUrl = url);
                        }
                      },
                    ),

                    const SizedBox(height: 10),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        minimumSize: const Size(double.infinity, 45),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () async {
                        final nuevoNombre = nameController.text.trim();
                        final nuevaBio = bioController.text.trim();

                        if (nuevoNombre.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('El nombre no puede estar vacío'),
                            ),
                          );
                          return;
                        }

                        final authProvider = Provider.of<AuthProvider>(
                          context,
                          listen: false,
                        );

                        try {
                          await authProvider.actualizarPerfil(
                            nombreUsuarioActual: _username,
                            nuevoNombre: nuevoNombre,
                            nuevaBio: nuevaBio,
                            fotoPerfilUrl: tempProfileUrl,
                            fotoPortadaUrl: tempBannerUrl,
                          );

                          if (!mounted || !modalContext.mounted) return;

                          setState(() {
                            _username = nuevoNombre;
                            _bio = nuevaBio;
                            _profileImageUrl = tempProfileUrl;
                            _bannerImageUrl = tempBannerUrl;
                          });

                          Navigator.pop(modalContext);
                        } catch (e) {
                          debugPrint('Error actualizando perfil: $e');

                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'No se pudieron guardar los cambios',
                                ),
                              ),
                            );
                          }
                        }
                      },
                      child: const Text(
                        'Guardar Cambios',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ==========================================
  // CREAR PUBLICACIÓN
  // ==========================================

  void _showCreatePostModal() {
    String? selectedPostImageUrl;
    bool publicando = false;

    final commentController = TextEditingController();
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setModalState) {
            return AlertDialog(
              backgroundColor: theme.scaffoldBackgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              title: Text(
                'Nueva Publicación',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: publicando
                          ? null
                          : () async {
                              final url = await CloudinaryService
                                  .subirImagenDesdeGaleria(
                                esPerfil: false,
                              );

                              if (url != null && dialogContext.mounted) {
                                setModalState(() {
                                  selectedPostImageUrl = url;
                                });
                              }
                            },
                      child: Container(
                        height: 140,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.grey.shade300,
                          ),
                          image: selectedPostImageUrl != null
                              ? DecorationImage(
                                  image: NetworkImage(selectedPostImageUrl!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: selectedPostImageUrl == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_a_photo,
                                    size: 36,
                                    color: theme.colorScheme.primary,
                                  ),
                                  const SizedBox(height: 5),
                                  const Text(
                                    'Seleccionar Foto (Opcional)',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              )
                            : Stack(
                                children: [
                                  Positioned(
                                    top: 5,
                                    right: 5,
                                    child: GestureDetector(
                                      onTap: publicando
                                          ? null
                                          : () {
                                              setModalState(() {
                                                selectedPostImageUrl = null;
                                              });
                                            },
                                      child: const CircleAvatar(
                                        radius: 14,
                                        backgroundColor: Colors.black54,
                                        child: Icon(
                                          Icons.close,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    TextField(
                      controller: commentController,
                      maxLines: 3,
                      enabled: !publicando,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Escribe un comentario...',
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: theme.colorScheme.primary,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: publicando
                      ? null
                      : () => Navigator.pop(dialogContext),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: publicando
                      ? null
                      : () async {
                          final mensaje = commentController.text.trim();

                          if (mensaje.isEmpty &&
                              selectedPostImageUrl == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Escribe algo o selecciona una imagen',
                                ),
                              ),
                            );
                            return;
                          }

                          final authProvider = Provider.of<AuthProvider>(
                            context,
                            listen: false,
                          );

                          final user = authProvider.currentUser;

                          final email = user?['email']
                                  ?.toString()
                                  .trim()
                                  .toLowerCase() ??
                              '';

                          final nombre = user?['nombre_usuario']
                                  ?.toString()
                                  .trim() ??
                              _username;

                          if (email.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'No se pudo identificar tu usuario',
                                ),
                              ),
                            );
                            return;
                          }

                          setModalState(() {
                            publicando = true;
                          });

                          final resultado = await ForoService.crearPost(
                            emailUsuario: email,
                            nombreUsuario: nombre,
                            mensaje: mensaje,
                            imagen: selectedPostImageUrl,
                          );

                          if (!mounted || !dialogContext.mounted) return;

                          if (resultado) {
                            Navigator.pop(dialogContext);

                            await _cargarMisPublicaciones();

                            if (!mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  '¡Publicación compartida correctamente!',
                                ),
                                backgroundColor: Color(0xFF388E3C),
                              ),
                            );
                          } else {
                            setModalState(() {
                              publicando = false;
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'No se pudo publicar. Intenta nuevamente.',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                  child: publicando
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Publicar',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      commentController.dispose();
    });
  }

  // ==========================================
  // MOSTRAR MIS PUBLICACIONES
  // ==========================================

  Widget _construirMisPublicaciones() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Mis publicaciones',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            IconButton(
              onPressed: _cargarMisPublicaciones,
              tooltip: 'Actualizar publicaciones',
              icon: Icon(
                Icons.refresh,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),

        if (_cargandoPosts)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(
                color: Color(0xFF388E3C),
              ),
            ),
          )
        else if (_posts.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 25),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.article_outlined,
                    size: 38,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Todavía no has realizado publicaciones.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ..._posts.map((post) {
            final tieneImagen =
                post.imagen != null && post.imagen!.isNotEmpty;

            return Column(
              children: [
                PostCard(
                  avatarUrl: _profileImageUrl ?? '',
                  username: post.nombreUsuario,
                  text: post.mensaje,
                  imageUrl: tieneImagen ? post.imagen : null,
                  initialLikes: 0,
                  comments: post.comentarios.length.toString(),
                  shares: '0',
                  date: post.fecha,
                ),

                const Divider(
                  height: 1,
                  thickness: 0.8,
                  color: Color(0xFFEAEAEA),
                ),
              ],
            );
          }),
      ],
    );
  }

  // ==========================================
  // INTERFAZ DEL PERFIL
  // ==========================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 170,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                    image: _bannerImageUrl != null &&
                            _bannerImageUrl!.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(_bannerImageUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                ),

                Positioned(
                  top: 40,
                  left: 15,
                  child: CircleAvatar(
                    backgroundColor:
                        theme.scaffoldBackgroundColor.withValues(alpha: 0.8),
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: theme.colorScheme.primary,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),

                Positioned(
                  bottom: -35,
                  left: 20,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor:
                          theme.colorScheme.primary.withValues(alpha: 0.2),
                      backgroundImage: _profileImageUrl != null &&
                              _profileImageUrl!.isNotEmpty
                          ? NetworkImage(_profileImageUrl!)
                          : null,
                      child: _profileImageUrl == null ||
                              _profileImageUrl!.isEmpty
                          ? Icon(
                              Icons.person,
                              size: 45,
                              color: theme.colorScheme.primary,
                            )
                          : null,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 45),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _username,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    _bio,
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.onSurface
                          .withValues(alpha: 0.7),
                    ),
                  ),

                  const SizedBox(height: 10),

                  ElevatedButton(
                    onPressed: _showEditProfileModal,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 8,
                      ),
                    ),
                    child: const Text(
                      'Editar Perfil',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),

                  const SizedBox(height: 22),

                  _construirSeccionAmigos(),

                  const SizedBox(height: 22),

                  _construirMisPublicaciones(),
                ],
              ),
            ),

            const SizedBox(height: 10),

            Center(
              child: IconButton(
                iconSize: 52,
                icon: Icon(
                  Icons.add_circle,
                  color: theme.colorScheme.primary,
                ),
                onPressed: _showCreatePostModal,
              ),
            ),

            const SizedBox(height: 20),
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

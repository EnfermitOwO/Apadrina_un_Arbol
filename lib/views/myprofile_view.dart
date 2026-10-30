import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/custom_bottom_nav.dart';
import '../models/post_model.dart';
import '../services/cloudinary_service.dart';
import '../providers/auth_provider.dart';

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

  final List<Post> _posts = [];

  @override
  void initState() {
    super.initState();
    _cargarDatosUsuario();
  }

  /// Carga los datos iniciales desde el AuthProvider (MongoDB)
  void _cargarDatosUsuario() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    if (user != null) {
      setState(() {
        _username = user['nombre_usuario'] ?? 'Usuario';
        _bio = user['bio'] ?? 'Sin Descripción';
        _profileImageUrl = user['foto_perfil'];
        _bannerImageUrl = user['foto_portada'];
      });
    }
  }

  void _showEditProfileModal() {
    final TextEditingController nameController = TextEditingController(text: _username);
    final TextEditingController bioController = TextEditingController(text: _bio);
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
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
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
                        labelStyle: TextStyle(color: theme.colorScheme.primary),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: theme.colorScheme.primary),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: bioController,
                      style: TextStyle(color: theme.colorScheme.onSurface),
                      decoration: InputDecoration(
                        labelText: 'Descripción / Biografía',
                        labelStyle: TextStyle(color: theme.colorScheme.primary),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: theme.colorScheme.primary),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ListTile(
                      leading: Icon(Icons.image, color: theme.colorScheme.primary),
                      title: Text(
                        'Cambiar foto de portada',
                        style: TextStyle(color: theme.colorScheme.onSurface),
                      ),
                      onTap: () async {
                        // Sube la foto directamente a Cloudinary y obtiene la URL
                        final url = await CloudinaryService.subirImagenDesdeGaleria(esPerfil: false);
                        if (url != null) {
                          setModalState(() => tempBannerUrl = url);
                        }
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.account_circle, color: theme.colorScheme.primary),
                      title: Text(
                        'Cambiar foto de perfil',
                        style: TextStyle(color: theme.colorScheme.onSurface),
                      ),
                      onTap: () async {
                        // Sube la foto directamente a Cloudinary y obtiene la URL
                        final url = await CloudinaryService.subirImagenDesdeGaleria(esPerfil: true);
                        if (url != null) {
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

                        // Guardar en MongoDB a través del AuthProvider
                        final authProvider = Provider.of<AuthProvider>(context, listen: false);
                        await authProvider.actualizarPerfil(
                          nombreUsuarioActual: _username,
                          nuevoNombre: nuevoNombre,
                          nuevaBio: nuevaBio,
                          fotoPerfilUrl: tempProfileUrl,
                          fotoPortadaUrl: tempBannerUrl,
                        );

                        setState(() {
                          _username = nuevoNombre;
                          _bio = nuevaBio;
                          _profileImageUrl = tempProfileUrl;
                          _bannerImageUrl = tempBannerUrl;
                        });

                        if (context.mounted) Navigator.pop(context);
                      },
                      child: const Text('Guardar Cambios', style: TextStyle(color: Colors.white)),
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

  void _showCreatePostModal() {
    String? selectedPostImageUrl;
    final TextEditingController commentController = TextEditingController();
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: theme.scaffoldBackgroundColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              title: Text(
                'Nueva Publicación',
                style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final url = await CloudinaryService.subirImagenDesdeGaleria(esPerfil: false);
                        if (url != null) {
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
                          border: Border.all(color: Colors.grey.shade300),
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
                                  Icon(Icons.add_a_photo, size: 36, color: theme.colorScheme.primary),
                                  const SizedBox(height: 5),
                                  const Text(
                                    'Seleccionar Foto (Opcional)',
                                    style: TextStyle(color: Colors.grey, fontSize: 13),
                                  ),
                                ],
                              )
                            : Stack(
                                children: [
                                  Positioned(
                                    top: 5,
                                    right: 5,
                                    child: GestureDetector(
                                      onTap: () {
                                        setModalState(() {
                                          selectedPostImageUrl = null;
                                        });
                                      },
                                      child: const CircleAvatar(
                                        radius: 14,
                                        backgroundColor: Colors.black54,
                                        child: Icon(Icons.close, size: 16, color: Colors.white),
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
                      style: TextStyle(color: theme.colorScheme.onSurface),
                      decoration: InputDecoration(
                        hintText: 'Escribe un comentario...',
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: theme.colorScheme.primary),
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
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    final text = commentController.text.trim();
                    if (text.isNotEmpty || selectedPostImageUrl != null) {
                      setState(() {
                        // _posts.insert(0, Post(...));
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('OK', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

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
                    image: _bannerImageUrl != null && _bannerImageUrl!.isNotEmpty
                        ? DecorationImage(image: NetworkImage(_bannerImageUrl!), fit: BoxFit.cover)
                        : null,
                  ),
                ),
                Positioned(
                  top: 40,
                  left: 15,
                  child: CircleAvatar(
                    backgroundColor: theme.scaffoldBackgroundColor.withValues(alpha: 0.8),
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: theme.colorScheme.primary),
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
                      backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.2),
                      backgroundImage: _profileImageUrl != null && _profileImageUrl!.isNotEmpty
                          ? NetworkImage(_profileImageUrl!)
                          : null,
                      child: _profileImageUrl == null || _profileImageUrl!.isEmpty
                          ? Icon(Icons.person, size: 45, color: theme.colorScheme.primary)
                          : null,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 45),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _showEditProfileModal,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    ),
                    child: const Text('Editar Perfil', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: IconButton(
                iconSize: 52,
                icon: Icon(Icons.add_circle, color: theme.colorScheme.primary),
                onPressed: _showCreatePostModal,
              ),
            ),
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _posts.length,
              itemBuilder: (context, index) {
                return const SizedBox.shrink();
              },
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
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../widgets/custom_bottom_nav.dart';
import '../models/post_model.dart';

class MyProfileView extends StatefulWidget {
  const MyProfileView({Key? key}) : super(key: key);

  @override
  State<MyProfileView> createState() => _MyProfileViewState();
}

class _MyProfileViewState extends State<MyProfileView> {
  final ImagePicker _picker = ImagePicker();

  File? _profileImage;
  File? _bannerImage;

  String _username = 'Usuario';
  String _bio = 'Sin Descripción';

  final List<Post> _posts = [];

  Future<File?> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      return File(image.path);
    }
    return null;
  }

  void _showEditProfileModal() {
    final TextEditingController nameController = TextEditingController(text: _username);
    final TextEditingController bioController = TextEditingController(text: _bio);
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
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
                    final img = await _pickImage();
                    if (img != null) {
                      setState(() => _bannerImage = img);
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
                    final img = await _pickImage();
                    if (img != null) {
                      setState(() => _profileImage = img);
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
                  onPressed: () {
                    setState(() {
                      _username = nameController.text.trim();
                      _bio = bioController.text.trim();
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Guardar Cambios', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCreatePostModal() {
    File? selectedPostImage;
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
                        final img = await _pickImage();
                        if (img != null) {
                          setModalState(() {
                            selectedPostImage = img;
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
                          image: selectedPostImage != null
                              ? DecorationImage(
                                  image: FileImage(selectedPostImage!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: selectedPostImage == null
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
                                          selectedPostImage = null;
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
                    if (text.isNotEmpty || selectedPostImage != null) {
                      setState(() {
                        _posts.insert(
                          0,
                          Post(
                            image: selectedPostImage,
                            comment: text,
                          ),
                        );
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
            // Stack original con bordes redondeados, botón flotante y foto alineada a la izquierda
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
                    image: _bannerImage != null
                        ? DecorationImage(image: FileImage(_bannerImage!), fit: BoxFit.cover)
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
                      backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                      child: _profileImage == null
                          ? Icon(Icons.person, size: 45, color: theme.colorScheme.primary)
                          : null,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 45),
            // Información del usuario (Alineado a la izquierda como en tu captura)
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
            // Botón de publicar centrado
            Center(
              child: IconButton(
                iconSize: 52,
                icon: Icon(Icons.add_circle, color: theme.colorScheme.primary),
                onPressed: _showCreatePostModal,
              ),
            ),
            const SizedBox(height: 10),
            // Publicaciones
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _posts.length,
              itemBuilder: (context, index) {
                final post = _posts[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.2),
                            backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                            child: _profileImage == null
                                ? Icon(Icons.person, size: 20, color: theme.colorScheme.primary)
                                : null,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _username,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (post.comment.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            post.comment,
                            style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface),
                          ),
                        ),
                      if (post.image != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            post.image!,
                            width: double.infinity,
                            height: 220,
                            fit: BoxFit.cover,
                          ),
                        ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.favorite, color: theme.colorScheme.primary, size: 20),
                          const SizedBox(width: 4),
                          Text('0', style: TextStyle(color: theme.colorScheme.primary)),
                          const SizedBox(width: 20),
                          Icon(Icons.chat_bubble_outline, color: theme.colorScheme.primary, size: 20),
                          const SizedBox(width: 4),
                          Text('0', style: TextStyle(color: theme.colorScheme.primary)),
                          const SizedBox(width: 20),
                          Icon(Icons.reply, color: theme.colorScheme.primary, size: 20),
                          const SizedBox(width: 4),
                          Text('0', style: TextStyle(color: theme.colorScheme.primary)),
                        ],
                      ),
                    ],
                  ),
                );
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
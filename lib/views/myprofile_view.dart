import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../widgets/custom_bottom_nav.dart';
import '../models/post_model.dart';

class MyProfileView extends StatefulWidget {
  const MyProfileView({super.key});

  @override
  State<MyProfileView> createState() => _MyProfileViewState();
}

class _MyProfileViewState extends State<MyProfileView> {
  final ImagePicker _picker = ImagePicker();

  File? _profileImage;
  File? _bannerImage;
 
  // Datos del usuario editables
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

  // Modal para editar foto de perfil, portada, nombre y descripción
  void _showEditProfileModal() {
    final TextEditingController nameController = TextEditingController(text: _username);
    final TextEditingController bioController = TextEditingController(text: _bio);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
                const Text(
                  'Editar Perfil',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF556B2F),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Nombre de usuario',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: bioController,
                  decoration: InputDecoration(
                    labelText: 'Descripción / Biografía',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 10),
                ListTile(
                  leading: const Icon(Icons.image, color: Color(0xFF556B2F)),
                  title: const Text('Cambiar foto de portada'),
                  onTap: () async {
                    final img = await _pickImage();
                    if (img != null) {
                      setState(() => _bannerImage = img);
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.account_circle, color: Color(0xFF556B2F)),
                  title: const Text('Cambiar foto de perfil'),
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
                    backgroundColor: const Color(0xFF556B2F),
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

  // Modal para crear nueva publicación (foto opcional)
  void _showCreatePostModal() {
    File? selectedPostImage;
    final TextEditingController commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              title: const Text(
                'Nueva Publicación',
                style: TextStyle(color: Color(0xFF556B2F), fontWeight: FontWeight.bold),
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
                          color: Colors.grey[200],
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
                                children: const [
                                  Icon(Icons.add_a_photo, size: 36, color: Color(0xFF556B2F)),
                                  SizedBox(height: 5),
                                  Text(
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
                      decoration: InputDecoration(
                        hintText: 'Escribe un comentario...',
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Color(0xFF556B2F)),
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
                    backgroundColor: const Color(0xFF556B2F),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    final text = commentController.text.trim();
                    // Permite publicar si hay texto O si hay foto seleccionada
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
    const Color colorVerde = Color(0xFF556B2F);

    return Scaffold(
      backgroundColor: Colors.white,
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
                    color: Colors.grey.shade300,
                    image: _bannerImage != null
                        ? DecorationImage(image: FileImage(_bannerImage!), fit: BoxFit.cover)
                        : null,
                  ),
                ),
                Positioned(
                  top: 40,
                  left: 15,
                  child: CircleAvatar(
                    backgroundColor: Colors.white.withValues(alpha: 0.7),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: colorVerde),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -35,
                  left: 20,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.grey.shade300,
                      backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                      child: _profileImage == null
                          ? const Icon(Icons.person, size: 45, color: Colors.white)
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
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colorVerde),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _bio,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _showEditProfileModal,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorVerde,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    ),
                    child: const Text('Editar Perfil', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
            const Divider(height: 30, thickness: 1),
            Center(
              child: IconButton(
                iconSize: 52,
                icon: const Icon(Icons.add_circle, color: colorVerde),
                onPressed: _showCreatePostModal,
              ),
            ),
            const SizedBox(height: 10),
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
                            backgroundColor: Colors.grey.shade300,
                            backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                            child: _profileImage == null
                                ? const Icon(Icons.person, size: 20, color: Colors.white)
                                : null,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _username,
                            style: const TextStyle(fontWeight: FontWeight.bold, color: colorVerde),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (post.comment.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(post.comment, style: const TextStyle(fontSize: 14)),
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
                        children: const [
                          Icon(Icons.favorite, color: colorVerde, size: 20),
                          SizedBox(width: 4),
                          Text('0', style: TextStyle(color: colorVerde)),
                          SizedBox(width: 20),
                          Icon(Icons.chat_bubble_outline, color: colorVerde, size: 20),
                          SizedBox(width: 4),
                          Text('0', style: TextStyle(color: colorVerde)),
                          SizedBox(width: 20),
                          Icon(Icons.reply, color: colorVerde, size: 20),
                          SizedBox(width: 4),
                          Text('0', style: TextStyle(color: colorVerde)),
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
import 'dart:io';

class Post {
  final File? image;
  final String comment;

  Post({
    this.image,
    required this.comment,
  });
}
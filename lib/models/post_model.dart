
class Post {
  final String? imageUrl;
  final String comment;
  final String username;

  Post({
    this.imageUrl,
    required this.comment,
    this.username = 'Usuario',
  });
}

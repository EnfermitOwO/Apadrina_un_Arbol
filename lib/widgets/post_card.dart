
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PostCard extends StatefulWidget {
  final String avatarUrl;
  final String username;
  final String text;
  final String? imageUrl;
  final int initialLikes;
  final String comments;
  final String shares;
  final String? date;

  const PostCard({
    super.key,
    required this.avatarUrl,
    required this.username,
    required this.text,
    this.imageUrl,
    required this.initialLikes,
    required this.comments,
    required this.shares,
    this.date,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard>
    with AutomaticKeepAliveClientMixin {
  late bool isLiked;
  late int currentLikes;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    isLiked = false;
    currentLikes = widget.initialLikes;
  }

  void _toggleLike() {
    setState(() {
      isLiked = !isLiked;
      currentLikes += isLiked ? 1 : -1;
    });
  }

  Widget _construirAvatar() {
    return CircleAvatar(
      radius: 21,
      backgroundColor: const Color(0xFFE8F5E9),
      child: widget.avatarUrl.isEmpty
          ? const Icon(
              Icons.person,
              color: Color(0xFF388E3C),
              size: 25,
            )
          : ClipOval(
              child: Image.network(
                widget.avatarUrl,
                width: 42,
                height: 42,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.person,
                    color: Color(0xFF388E3C),
                    size: 25,
                  );
                },
              ),
            ),
    );
  }

  Widget _construirAccion({
    required IconData icon,
    required String cantidad,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 19, color: color),
            const SizedBox(width: 6),
            Text(
              cantidad,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final tieneImagen =
        widget.imageUrl != null && widget.imageUrl!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 13,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _construirAvatar(),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nombre y fecha
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        widget.username,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                      ),
                    ),

                    if (widget.date != null &&
                        widget.date!.isNotEmpty) ...[
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          '· ${widget.date}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                // Texto de la publicación
                if (widget.text.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    widget.text,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                  ),
                ],

                // Imagen de la publicación
                if (tieneImagen) ...[
                  const SizedBox(height: 11),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(
                      widget.imageUrl!,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 150,
                          width: double.infinity,
                          alignment: Alignment.center,
                          color: const Color(0xFFF2F4F1),
                          child: const Icon(
                            Icons.broken_image_outlined,
                            color: Colors.grey,
                            size: 35,
                          ),
                        );
                      },
                    ),
                  ),
                ],

                const SizedBox(height: 8),

                // Acciones
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _construirAccion(
                      icon: isLiked
                          ? Icons.favorite
                          : Icons.favorite_border,
                      cantidad: '$currentLikes',
                      color: isLiked
                          ? Colors.red
                          : Colors.grey.shade600,
                      onTap: _toggleLike,
                    ),

                    _construirAccion(
                      icon: Icons.chat_bubble_outline,
                      cantidad: widget.comments,
                      color: Colors.grey.shade600,
                    ),

                    _construirAccion(
                      icon: Icons.repeat,
                      cantidad: widget.shares,
                      color: Colors.grey.shade600,
                    ),

                    Icon(
                      Icons.share_outlined,
                      size: 18,
                      color: Colors.grey.shade600,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

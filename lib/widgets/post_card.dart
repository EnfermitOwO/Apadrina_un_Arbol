import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PostCard extends StatefulWidget {
  final String avatarUrl;
  final String username;
  final String text;
  final String? imageUrl; // Ahora es opcional (puede ser null)
  final int initialLikes;
  final String comments;
  final String shares;

  const PostCard({
    super.key,
    required this.avatarUrl,
    required this.username,
    required this.text,
    this.imageUrl, // Ya no es 'required'
    required this.initialLikes,
    required this.comments,
    required this.shares,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> with AutomaticKeepAliveClientMixin {
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
      if (isLiked) {
        currentLikes++;
      } else {
        currentLikes--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage(widget.avatarUrl),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.username,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.text,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // MOSTRAR IMAGEN SOLO SI EXISTE
          if (widget.imageUrl != null) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                widget.imageUrl!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ],
          
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                onTap: _toggleLike,
                child: Row(
                  children: [
                    Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      color: isLiked ? Colors.red : const Color(0xFF388E3C),
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$currentLikes',
                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.chat_bubble, color: Color(0xFF388E3C), size: 20),
                  const SizedBox(width: 6),
                  Text(
                    widget.comments,
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700]),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.share, color: Color(0xFF388E3C), size: 20),
                  const SizedBox(width: 6),
                  Text(
                    widget.shares,
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700]),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
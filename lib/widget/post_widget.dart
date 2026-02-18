import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:here/models/post.dart';
import 'package:here/models/post_type.dart';
import 'package:here/providers/post_provider.dart';

// FIXED: Renamed from PostCard to PostWidget to match your other files
class PostWidget extends StatelessWidget {
  final Post post;
  final bool showActions;

  const PostWidget({
    super.key,
    required this.post,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      color: colors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PostHeader(post: post), 
          const SizedBox(height: 8),
          _PostBody(post: post),   
          if (showActions) ...[
            const SizedBox(height: 12),
            _PostFooter(post: post), 
          ],
          const SizedBox(height: 12),
          Divider(height: 1, thickness: 0.5, color: colors.outlineVariant.withOpacity(0.5)),
        ],
      ),
    );
  }
}

// --- HEADER ---
class _PostHeader extends StatelessWidget {
  final Post post;
  const _PostHeader({required this.post});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(post.userProfileImage),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.userName,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  // Using DateTime formatting or post.createdAt.toString()
                  "${post.createdAt.day}/${post.createdAt.month}/${post.createdAt.year}",
                  style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

// --- BODY ---
class _PostBody extends StatelessWidget {
  final Post post;
  const _PostBody({required this.post});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (post.content.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              post.content,
              style: GoogleFonts.plusJakartaSans(fontSize: 14, height: 1.4),
            ),
          ),
        const SizedBox(height: 8),
        _buildMediaContent(context),
      ],
    );
  }

  Widget _buildMediaContent(BuildContext context) {
    switch (post.type) {
      case PostType.image:
        return _ImageMedia(url: post.imageUrl!);
      case PostType.multiImage:
        return _MultiImageMedia(urls: post.imageUrls!);
      case PostType.video:
        return _VideoPlaceholder(url: post.imageUrl!);
      default:
        return const SizedBox.shrink();
    }
  }
}

// --- FOOTER ---
class _PostFooter extends StatelessWidget {
  final Post post;
  const _PostFooter({required this.post});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final provider = context.read<PostProvider>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.thumb_up_alt_rounded, size: 14, color: colors.primary),
              const SizedBox(width: 4),
              Text('${post.likes}', style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant)),
              const Spacer(),
              Text('${post.comments} comments • ${post.shares} shares', 
                style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant)),
            ],
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _ActionBtn(
                icon: post.isLiked ? Icons.thumb_up_alt_rounded : Icons.thumb_up_off_alt, 
                label: 'Like', 
                active: post.isLiked,
                onTap: () => provider.toggleLike(post.id),
              ),
              _ActionBtn(icon: Icons.chat_bubble_outline, label: 'Comment', onTap: () {}),
              _ActionBtn(icon: Icons.share_outlined, label: 'Share', onTap: () {}),
            ],
          ),
        ],
      ),
    );
  }
}

// --- MEDIA HELPERS ---

class _ImageMedia extends StatelessWidget {
  final String url;
  const _ImageMedia({required this.url});

  @override
  Widget build(BuildContext context) {
    // FIXED: Image.network doesn't take constraints. Wrapped in Container.
    return Container(
      constraints: const BoxConstraints(maxHeight: 500),
      width: double.infinity,
      child: Image.network(
        url,
        fit: BoxFit.cover,
      ),
    );
  }
}

class _MultiImageMedia extends StatelessWidget {
  final List<String> urls;
  const _MultiImageMedia({required this.urls});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: urls.length > 4 ? 4 : urls.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemBuilder: (context, index) {
        return Image.network(urls[index], fit: BoxFit.cover);
      },
    );
  }
}

class _VideoPlaceholder extends StatelessWidget {
  final String url;
  const _VideoPlaceholder({required this.url});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.network(url, fit: BoxFit.cover, width: double.infinity),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: Colors.black38, shape: BoxShape.circle),
            child: const Icon(Icons.play_arrow, color: Colors.white, size: 40),
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  
  const _ActionBtn({
    required this.icon, 
    required this.label, 
    required this.onTap,
    this.active = false
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant;
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:here/notification.dart'; // Add this with your other imports
import 'package:here/widgets/post_widget.dart'; // Fixed: widgets (plural)
import 'package:here/widgets/story_widget.dart'; // Fixed: widgets (plural)
import 'package:here/providers/post_provider.dart';
import 'package:here/providers/story_provider.dart'; 

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    
    return Scaffold(
      backgroundColor: colors.background,
      appBar: _buildAppBar(context, colors),
      body: Consumer<PostProvider>(
        builder: (context, postProvider, child) {
          if (postProvider.isLoading && postProvider.posts.isEmpty) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
              ),
            );
          }

          if (postProvider.hasError && postProvider.posts.isEmpty) {
            return _buildErrorState(context, colors, postProvider);
          }

          if (!postProvider.hasPosts) {
            return _buildEmptyState(context, colors);
          }

          return RefreshIndicator(
            onRefresh: () async {
              await Future.wait([
                postProvider.loadPosts(refresh: true),
                Provider.of<StoryProvider>(context, listen: false).loadStories(),
              ]);
            },
            color: colors.primary,
            backgroundColor: colors.surface,
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 16),
              itemCount: postProvider.posts.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Column(
                    children: [
                      const SizedBox(height: 10),
                      const StoryWidget(),
                      const SizedBox(height: 5),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18.0),
                        child: Divider(color: colors.outline),
                      ),
                    ],
                  );
                }
                
                final post = postProvider.posts[index - 1];
                return Column(
                  children: [
                    PostWidget(post: post),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18.0),
                      child: Divider(color: colors.outline),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, ColorScheme colors) {
    return AppBar(
      backgroundColor: colors.surface,
      elevation: 0,
      title: Row(
        children: [
          Image.asset(
            'images/logo.png',
            height: 30,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 30,
                width: 30,
                color: colors.primary,
                child: Icon(Icons.person, color: colors.onPrimary, size: 20),
              );
            },
          ),
          const SizedBox(width: 10),
          Text(
            'Socio Network',
            style: GoogleFonts.lato(
              color: colors.onSurface,
              fontSize: 16,
              letterSpacing: 1,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
  // Notification Icon
  GestureDetector(
    onTap: () {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const NotificationsPage(), // Your notification.dart
        ),
      );
    },
    child: Container(
      margin: const EdgeInsets.only(right: 20),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        shape: BoxShape.circle,
      ),
      child: Stack(
        children: [
          Icon(
            Icons.notifications_outlined,
            color: colors.onSurface,
            size: 20,
          ),
          // Optional: Show notification badge if there are unread
          // Positioned(
          //   right: 0,
          //   top: 0,
          //   child: Container(
          //     width: 8,
          //     height: 8,
          //     decoration: BoxDecoration(
          //       color: colors.primary,
          //       shape: BoxShape.circle,
          //     ),
          //   ),
          // ),
        ],
      ),
    ),
  ),
],
    );
  }

  Widget _buildErrorState(BuildContext context, ColorScheme colors, PostProvider postProvider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: colors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: GoogleFonts.lato(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colors.onBackground,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              postProvider.errorMessage ?? 'Failed to load posts',
              style: GoogleFonts.lato(
                fontSize: 14,
                color: colors.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => postProvider.loadPosts(refresh: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ColorScheme colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.feed_outlined,
              size: 80,
              color: colors.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No Posts Yet',
              style: GoogleFonts.lato(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colors.onBackground,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Be the first to share something!',
              style: GoogleFonts.lato(
                fontSize: 14,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Create post feature coming soon!'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: colors.primary,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Text('Create Post'),
            ),
          ],
        ),
      ),
    );
  }
}
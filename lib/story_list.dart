import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:here/providers/story_provider.dart';
// FIXED: Changed 'widgets' to 'widget' to match your project structure
import 'package:here/widget/story_viewer.dart'; 
// FIXED: Added the model import so 'Story' is recognized as a type
import 'package:here/models/story.dart'; 

class StoryList extends StatelessWidget {
  const StoryList({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    
    return Scaffold(
      // FIXED: Changed .background to .surface (Flutter 3.27+ standard)
      backgroundColor: colors.surface, 
      body: Consumer<StoryProvider>(
        builder: (context, storyProvider, child) {
          if (storyProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final groupedStories = storyProvider.getStoriesGroupedByUser();
          
          if (groupedStories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // FIXED: Changed 'stories_outlined' to 'history' (or 'auto_stories')
                  Icon(
                    Icons.history, 
                    size: 64,
                    color: colors.onSurface.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No stories yet',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      color: colors.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: groupedStories.length,
            itemBuilder: (context, index) {
              final entry = groupedStories[index];
              final userId = entry.key;
              final userStories = entry.value;
              final firstStory = userStories.first;
              final hasUnviewed = storyProvider.hasUnviewedStories(userId);
              
              return _buildStoryTile(
                context,
                colors: colors,
                storyProvider: storyProvider,
                userId: userId,
                userStories: userStories,
                firstStory: firstStory,
                hasUnviewed: hasUnviewed,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStoryTile(
    BuildContext context, {
    required ColorScheme colors,
    required StoryProvider storyProvider,
    required String userId,
    required List<Story> userStories,
    required Story firstStory,
    required bool hasUnviewed,
  }) {
    return GestureDetector(
      onTap: () {
        storyProvider.markUserStoriesAsViewed(userId);
        Navigator.push(
          context,
          MaterialPageRoute(
            // FIXED: This will now find StoryViewer thanks to correct import
            builder: (context) => StoryViewer(
              userId: userId,
              initialStoryIndex: 0,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colors.shadow.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: hasUnviewed ? colors.primary : colors.outline,
                      width: hasUnviewed ? 3 : 2,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 32,
                    backgroundImage: NetworkImage(firstStory.userImage),
                    onBackgroundImageError: (_, __) => Icon(
                      Icons.person,
                      color: colors.onSurface,
                    ),
                  ),
                ),
                if (firstStory.isMyStory)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: colors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: colors.surface, width: 2),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.add,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        firstStory.userName,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: hasUnviewed ? FontWeight.bold : FontWeight.w600,
                          color: colors.onSurface,
                        ),
                      ),
                      if (hasUnviewed) ...[
                        const SizedBox(width: 8),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: colors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${userStories.length} story${userStories.length > 1 ? 'ies' : 'y'}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: colors.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _getTimeText(userStories.last.timestamp),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: colors.onSurface.withOpacity(0.4),
                    ),
                  ),
                ],
              ),
            ),
            if (userStories.length > 1)
              SizedBox(
                width: 60,
                height: 40,
                child: Stack(
                  children: List.generate(
                    userStories.take(3).length,
                    (index) {
                      final story = userStories[index];
                      return Positioned(
                        left: index * 15.0,
                        child: Container(
                          width: 30,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: colors.surface, width: 2),
                            image: DecorationImage(
                              image: NetworkImage(story.mediaUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getTimeText(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${(difference.inDays / 7).floor()}w ago';
    }
  }
}

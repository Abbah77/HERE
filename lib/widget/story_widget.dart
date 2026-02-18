import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:here/providers/story_provider.dart';
import 'package:here/widget/story_viewer.dart';
// Ensure this file exists at this EXACT location relative to lib
import 'package:here/create_story_page.dart'; 

class StoryWidget extends StatelessWidget {
  const StoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Consumer<StoryProvider>(
      builder: (context, storyProvider, child) {
        if (storyProvider.isLoading && storyProvider.stories.isEmpty) {
          return const _LoadingSkeleton();
        }

        // Logic: Group stories by user to avoid duplicate circles
        final groupedStories = storyProvider.getStoriesGroupedByUser();

        return Container(
          height: 110,
          color: colors.surface,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: groupedStories.length,
            itemBuilder: (context, index) {
              final entry = groupedStories[index];
              final userId = entry.key;
              final userStories = entry.value;
              final firstStory = userStories.first;
              final hasUnviewed = storyProvider.hasUnviewedStories(userId);

              return _StoryCircle(
                userId: userId,
                userName: firstStory.userName,
                userImage: firstStory.userImage,
                hasUnviewed: hasUnviewed,
                isMyStory: firstStory.isMyStory,
                onTap: () {
                  if (firstStory.isMyStory && !hasUnviewed) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CreateStoryPage()),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => StoryViewer(userId: userId)),
                    );
                  }
                },
              );
            },
          ),
        );
      },
    );
  }
}

class _StoryCircle extends StatelessWidget {
  final String userId;
  final String userName;
  final String userImage;
  final bool hasUnviewed;
  final bool isMyStory;
  final VoidCallback onTap;

  const _StoryCircle({
    required this.userId,
    required this.userName,
    required this.userImage,
    required this.hasUnviewed,
    required this.isMyStory,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(2.5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: hasUnviewed
                        ? LinearGradient(
                            colors: [colors.primary, colors.tertiary, colors.secondary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    border: !hasUnviewed 
                        ? Border.all(color: colors.outlineVariant.withOpacity(0.5), width: 1) 
                        : null,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      radius: 28,
                      backgroundColor: colors.surface,
                      backgroundImage: NetworkImage(userImage),
                    ),
                  ),
                ),
                if (isMyStory && !hasUnviewed)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: colors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: colors.surface, width: 2),
                      ),
                      child: const Icon(Icons.add, size: 18, color: Colors.white),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              isMyStory ? 'You' : userName.split(' ').first,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: hasUnviewed ? FontWeight.bold : FontWeight.w500,
                color: hasUnviewed ? colors.onSurface : colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      height: 110,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: List.generate(5, (index) => Padding(
          padding: const EdgeInsets.only(right: 16),
          child: CircleAvatar(
            radius: 32, 
            backgroundColor: colors.onSurface.withOpacity(0.05)
          ),
        )),
      ),
    );
  }
}

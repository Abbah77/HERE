import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:here/providers/story_provider.dart';
import 'package:here/widget/story_viewer.dart';
import 'package:here/create_story_page.dart';

class StoryWidget extends StatelessWidget {
  const StoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Consumer<StoryProvider>(
      builder: (context, storyProvider, child) {
        final friendEntries = storyProvider.getStoriesGroupedByUser();
        final myStories = storyProvider.getStoriesByUser('current_user');
        final hasMyStories = myStories.isNotEmpty;
        final myUnviewed = storyProvider.hasUnviewedStories('current_user');

        return Container(
          height: 110,
          color: colors.surface,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: friendEntries.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return _StoryCircle(
                  userId: 'current_user',
                  userName: 'You',
                  userImage: 'https://cdn.now.howstuffworks.com/media-content/0b7f4e9b-f59c-4024-9f06-b3dc12850ab7-1920-1080.jpg',
                  hasUnviewed: myUnviewed,
                  hasStories: hasMyStories,
                  isMyStory: true,
                  onTap: () {
                    if (hasMyStories) {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const StoryViewer(userId: 'current_user')));
                    } else {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateStoryPage()));
                    }
                  },
                  onAddTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateStoryPage())),
                );
              }

              final entry = friendEntries[index - 1];
              final userId = entry.key;
              final firstStory = entry.value.first;

              return _StoryCircle(
                userId: userId,
                userName: firstStory.userName,
                userImage: firstStory.userImage,
                hasUnviewed: storyProvider.hasUnviewedStories(userId),
                hasStories: true,
                isMyStory: false,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => StoryViewer(userId: userId))),
              );
            },
          ),
        );
      },
    );
  }
}

class _StoryCircle extends StatelessWidget {
  final String userId, userName, userImage;
  final bool hasUnviewed, hasStories, isMyStory;
  final VoidCallback onTap;
  final VoidCallback? onAddTap;

  const _StoryCircle({
    required this.userId, required this.userName, required this.userImage,
    required this.hasUnviewed, required this.hasStories, required this.isMyStory,
    required this.onTap, this.onAddTap,
  });

  void _showUserMenu(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(color: colors.surface, borderRadius: const BorderRadius.vertical(top: Radius.circular(20))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: colors.outlineVariant, borderRadius: BorderRadius.circular(2))),
            ListTile(
              leading: Icon(Icons.add_circle_outline, color: colors.primary),
              title: const Text('Add to your story'),
              onTap: () { Navigator.pop(context); onAddTap?.call(); },
            ),
            if (hasStories)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
                title: const Text('Delete active stories', style: TextStyle(color: Colors.redAccent)),
                onTap: () {
                  context.read<StoryProvider>().deleteStory('current_user');
                  Navigator.pop(context);
                },
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    
    // --- RING DECORATION LOGIC ---
    Decoration ringDecoration;
    if (hasStories && hasUnviewed) {
      ringDecoration = BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: [colors.primary, colors.tertiary, colors.secondary]),
      );
    } else if (hasStories && !hasUnviewed) {
      ringDecoration = BoxDecoration(shape: BoxShape.circle, border: Border.all(color: colors.outlineVariant, width: 2));
    } else {
      ringDecoration = BoxDecoration(shape: BoxShape.circle, border: Border.all(color: colors.outlineVariant.withOpacity(0.2), width: 1));
    }

    return GestureDetector(
      onTap: onTap,
      onLongPress: isMyStory ? () => _showUserMenu(context) : null,
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(3.0),
                  decoration: ringDecoration,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(color: colors.surface, shape: BoxShape.circle),
                    child: CircleAvatar(radius: 28, backgroundImage: NetworkImage(userImage)),
                  ),
                ),
                if (isMyStory)
                  Positioned(
                    bottom: 2, right: 2,
                    child: GestureDetector(
                      onTap: onAddTap ?? onTap,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(color: colors.primary, shape: BoxShape.circle, border: Border.all(color: colors.surface, width: 2)),
                        child: const Icon(Icons.add, size: 16, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(isMyStory ? 'You' : userName.split(' ').first, style: TextStyle(fontSize: 11, fontWeight: hasUnviewed ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }
}

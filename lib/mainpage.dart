import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:here/providers/post_provider.dart';
import 'package:here/providers/story_provider.dart';
import 'package:here/widget/post_widget.dart';
import 'package:here/widget/story_widget.dart';
import 'package:here/search_page.dart';
import 'package:here/notification.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  void initState() {
    super.initState();
    // Rule: Trigger data fetch on mount without blocking UI
    Future.microtask(() {
      context.read<PostProvider>().loadPosts();
      context.read<StoryProvider>().loadStories();
    });
  }

  // Logic: Handle pull-to-refresh
  Future<void> _onRefresh() async {
    await Future.wait([
      context.read<PostProvider>().loadPosts(refresh: true),
      context.read<StoryProvider>().loadStories(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        edgeOffset: 110, // Starts below the AppBar
        color: colors.primary,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildSliverAppBar(context, colors),
            
            // Story Section
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: StoryWidget(),
              ),
            ),

            // Feed Section
            Consumer<PostProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading && provider.posts.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator.adaptive()),
                  );
                }

                if (provider.hasError && provider.posts.isEmpty) {
                  return _buildSliverError(colors, provider);
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final post = provider.posts[index];
                      return PostWidget(post: post);
                    },
                    childCount: provider.posts.length,
                  ),
                );
              },
            ),
            
            // Bottom Padding for navigation bar clearance
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, ColorScheme colors) {
    return SliverAppBar(
      floating: true,
      pinned: false,
      snap: true,
      backgroundColor: colors.surface,
      elevation: 0,
      centerTitle: false,
      title: Row(
        children: [
          Icon(Icons.bubble_chart, color: colors.primary, size: 28),
          const SizedBox(width: 10),
          Text(
            'Here',
            style: GoogleFonts.plusJakartaSans(
              color: colors.onSurface,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
      actions: [
        // Search Button
        IconButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SearchPage()),
          ),
          icon: Icon(Icons.search_rounded, color: colors.onSurface),
        ),
        // Notification Button
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NotificationPage()),
          ),
          child: Container(
            margin: const EdgeInsets.only(right: 16, left: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colors.surfaceVariant.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.notifications_none_rounded, color: colors.onSurface, size: 22),
          ),
        ),
      ],
    );
  }

  Widget _buildSliverError(ColorScheme colors, PostProvider provider) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_rounded, size: 48, color: colors.outline),
            const SizedBox(height: 16),
            const Text('Something went wrong'),
            TextButton(
              onPressed: () => provider.loadPosts(),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

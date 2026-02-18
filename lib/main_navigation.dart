import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:here/providers/post_provider.dart';
import 'package:here/providers/story_provider.dart';
import 'package:here/mainpage.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation>
    with SingleTickerProviderStateMixin {
  late final MainPage _homePage;
  bool _isRefreshing = false;
  late final AnimationController _iconController;

  @override
  void initState() {
    super.initState();
    _homePage = const MainPage();
    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _iconController.repeat(); // for spinner rotation
  }

  @override
  void dispose() {
    _iconController.dispose();
    super.dispose();
  }

  Future<void> _refreshHome() async {
    if (_isRefreshing) return;

    setState(() => _isRefreshing = true);

    final postProvider = context.read<PostProvider>();
    final storyProvider = context.read<StoryProvider>();

    // Load stories and posts
    await Future.wait([
      storyProvider.loadStories(),
      postProvider.loadPosts(refresh: true),
    ]);

    // Scroll feed to top
    _homePage.scrollToTop();

    setState(() => _isRefreshing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: _isRefreshing
                ? RotationTransition(
                    turns: _iconController,
                    child: const Icon(Icons.home),
                  )
                : const Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
        ],
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) {
            _refreshHome();
          }
        },
      ),
      body: _homePage,
    );
  }
}
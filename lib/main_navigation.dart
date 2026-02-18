import 'package:flutter/material.dart';
import 'package:here/mainpage.dart'; 
import 'package:here/friends_page.dart';
import 'package:here/explore_page.dart';
import 'package:here/chat_list_page.dart';
import 'package:here/profile.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  
  /// FIXED: Changed to a generic GlobalKey to prevent compilation errors 
  /// regarding 'MainPageState' not being found.
  final GlobalKey<dynamic> _homeKey = GlobalKey();

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      MainPage(key: _homeKey), 
      const FriendsPage(),
      const ExplorePage(),
      const ChatListPage(),
      const ProfilePage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      /// IndexedStack keeps our pages alive so we don't lose scroll position
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          if (index == 0 && _currentIndex == 0) {
            /// We check if the method exists at runtime to avoid crashes.
            /// This handles the "Tap Home to scroll to top" logic.
            try {
              _homeKey.currentState?.scrollToTop();
            } catch (e) {
              debugPrint("Scroll to top failed: $e");
            }
          } else {
            setState(() => _currentIndex = index);
          }
        },
        backgroundColor: colors.surface,
        elevation: 0,
        indicatorColor: colors.primary.withOpacity(0.1),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Friends',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'Chat',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:here/providers/auth_provider.dart';
import 'package:here/providers/post_provider.dart';
import 'package:here/widget/post_widget.dart'; 

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  bool _isEditingBio = false;
  final TextEditingController _bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    final postProvider = Provider.of<PostProvider>(context);
    
    if (user == null) {
      return Scaffold(
        backgroundColor: colors.surface, 
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_off_outlined, size: 64, color: colors.onSurface.withOpacity(0.3)),
              const SizedBox(height: 16),
              Text('No user data', style: GoogleFonts.plusJakartaSans(fontSize: 18, color: colors.onSurface)),
            ],
          ),
        ),
      );
    }

    // Logic Fix: Filter posts for the current user
    final userPosts = postProvider.posts.where((p) => p.userId == user.id).toList();
    
    // Logic Fix: Filter for 'Liked' posts as a substitute for Bookmarks 
    // or use an empty list if your model doesn't support bookmarks yet.
    final savedPosts = postProvider.posts.where((p) => p.isLiked).toList();

    return Scaffold(
      backgroundColor: colors.surface,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 280,
              floating: false,
              pinned: true,
              backgroundColor: colors.surface,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [colors.primary.withOpacity(0.1), colors.surface],
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const SizedBox(height: kToolbarHeight + 20),
                      _buildAvatar(user.profileImage, colors),
                      const SizedBox(height: 12),
                      Text(user.name, style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.bold, color: colors.onSurface)),
                      const SizedBox(height: 4),
                      Text(user.email, style: GoogleFonts.plusJakartaSans(fontSize: 14, color: colors.onSurface.withOpacity(0.6))),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: _buildStatsRow(user, colors),
            ),
            SliverToBoxAdapter(
              child: _buildBioSection(user, authProvider, colors),
            ),
            SliverPersistentHeader(
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  indicatorColor: colors.primary,
                  indicatorWeight: 3,
                  labelColor: colors.primary,
                  unselectedLabelColor: colors.onSurface.withOpacity(0.6),
                  tabs: const [Tab(text: 'Posts'), Tab(text: 'Liked')],
                ),
              ),
              pinned: true,
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildPostList(userPosts, 'No posts yet', Icons.post_add_outlined, colors),
            _buildPostList(savedPosts, 'No liked posts', Icons.favorite_border_rounded, colors),
          ],
        ),
      ),
    );
  }

  // --- REFACTORED COMPONENTS ---

  Widget _buildAvatar(String url, ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: colors.primary, width: 2)),
      child: CircleAvatar(radius: 50, backgroundImage: NetworkImage(url)),
    );
  }

  Widget _buildStatsRow(dynamic user, ColorScheme colors) {
    return Container(
      color: colors.surface,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(colors, value: user.posts.toString(), label: 'Posts'),
          _buildStatItem(colors, value: _formatCount(user.followers), label: 'Followers'),
          _buildStatItem(colors, value: _formatCount(user.following), label: 'Following'),
        ],
      ),
    );
  }

  Widget _buildPostList(List<dynamic> list, String emptyMsg, IconData icon, ColorScheme colors) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: colors.onSurface.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text(emptyMsg, style: GoogleFonts.plusJakartaSans(fontSize: 16, color: colors.onSurface.withOpacity(0.6))),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) => PostWidget(post: list[index]),
    );
  }

  // Bio Section helper to keep build method clean
  Widget _buildBioSection(dynamic user, AuthProvider auth, ColorScheme colors) {
    return Container(
      color: colors.surface,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Bio', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: colors.onSurface)),
              if (!_isEditingBio)
                IconButton(
                  icon: Icon(Icons.edit_outlined, size: 18, color: colors.primary),
                  onPressed: () => setState(() => _isEditingBio = true),
                ),
            ],
          ),
          if (_isEditingBio)
            _buildBioEditor(auth, colors)
          else
            Text(
              user.bio.isEmpty ? 'No bio yet' : user.bio,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: colors.onSurface.withOpacity(user.bio.isEmpty ? 0.4 : 0.8),
                fontStyle: user.bio.isEmpty ? FontStyle.italic : FontStyle.normal,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBioEditor(AuthProvider auth, ColorScheme colors) {
    return Column(
      children: [
        TextField(
          controller: _bioController,
          maxLines: 3,
          style: TextStyle(color: colors.onSurface),
          decoration: InputDecoration(
            filled: true,
            fillColor: colors.surfaceVariant,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(onPressed: () => setState(() => _isEditingBio = false), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                await auth.updateProfile(bio: _bioController.text);
                setState(() => _isEditingBio = false);
              },
              child: const Text('Save'),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildStatItem(ColorScheme colors, {required String value, required String label}) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.bold, color: colors.onSurface)),
        Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 13, color: colors.onSurface.withOpacity(0.6))),
      ],
    );
  }

  String _formatCount(int count) {
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  _SliverAppBarDelegate(this._tabBar);
  @override double get minExtent => _tabBar.preferredSize.height;
  @override double get maxExtent => _tabBar.preferredSize.height;
  @override Widget build(context, shrink, overlaps) => Container(color: Theme.of(context).colorScheme.surface, child: _tabBar);
  @override bool shouldRebuild(_SliverAppBarDelegate old) => false;
}

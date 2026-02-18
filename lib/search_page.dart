import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:here/providers/post_provider.dart';
// Ensure this widget exists and has no internal errors
import 'package:here/widget/post_widget.dart';
import 'package:here/models/post.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    
    // Using watch to react to changes in the post list
    final allPosts = context.watch<PostProvider>().posts;

    // Filtering logic
    final List<Post> filteredPosts = allPosts.where((post) {
      final lowercaseQuery = _query.toLowerCase();
      return post.content.toLowerCase().contains(lowercaseQuery) || 
             post.userName.toLowerCase().contains(lowercaseQuery);
    }).toList();

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: colors.onSurface, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              // Using surfaceVariant as requested for older SDK support
              color: colors.surfaceVariant.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _query = val),
              autofocus: true,
              textAlignVertical: TextAlignVertical.center,
              style: GoogleFonts.plusJakartaSans(fontSize: 14, color: colors.onSurface),
              decoration: InputDecoration(
                hintText: 'Search people, posts...',
                hintStyle: TextStyle(color: colors.onSurface.withOpacity(0.5)),
                prefixIcon: Icon(Icons.search, size: 18, color: colors.primary),
                border: InputBorder.none,
                isDense: true,
                suffixIcon: _query.isNotEmpty 
                  ? IconButton(
                      icon: Icon(Icons.cancel, size: 18, color: colors.onSurface.withOpacity(0.4)),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                    )
                  : null,
              ),
            ),
          ),
        ),
      ),
      body: _query.isEmpty 
          ? _buildTrending(colors) 
          : _buildResults(filteredPosts, colors),
    );
  }

  Widget _buildTrending(ColorScheme colors) {
    final suggestions = ['Flutter', 'Design', 'Travel', 'Photography'];
    
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trending Topics',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: suggestions.map((tag) => ActionChip(
              label: Text(tag, style: TextStyle(fontSize: 13, color: colors.onSurface)),
              onPressed: () {
                _searchController.text = tag;
                setState(() => _query = tag);
              },
              backgroundColor: colors.surfaceVariant.withOpacity(0.3),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              side: BorderSide(color: colors.outline.withOpacity(0.1)),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildResults(List<Post> results, ColorScheme colors) {
    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 60, color: colors.onSurface.withOpacity(0.2)),
            const SizedBox(height: 16),
            Text(
              'No matches for "$_query"', 
              style: TextStyle(color: colors.onSurface.withOpacity(0.5)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: results.length,
      padding: const EdgeInsets.only(top: 8),
      itemBuilder: (context, index) {
        // Explicitly passing the Post object to avoid type errors
        return PostWidget(post: results[index]);
      },
    );
  }
}

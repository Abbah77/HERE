import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:here/providers/story_provider.dart';
import 'package:here/models/story.dart';

class StoryViewer extends StatefulWidget {
  final String userId;
  final int initialStoryIndex;

  const StoryViewer({
    super.key,
    required this.userId,
    this.initialStoryIndex = 0,
  });

  @override
  State<StoryViewer> createState() => _StoryViewerState();
}

class _StoryViewerState extends State<StoryViewer> with TickerProviderStateMixin {
  late PageController _pageController;
  late List<Story> _userStories;
  int _currentIndex = 0;
  late AnimationController _progressController;
  
  @override
  void initState() {
    super.initState();
    // Initialize stories from provider immediately
    _userStories = context.read<StoryProvider>().getStoriesByUser(widget.userId);
    _currentIndex = widget.initialStoryIndex;
    _pageController = PageController(initialPage: widget.initialStoryIndex);
    
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..forward();
    
    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _nextStory();
      }
    });

    // Rule: Mark stories as viewed as soon as the viewer opens
    _markAsViewed();
  }

  // Logic: Tells the provider to turn the ring grey for this user
  void _markAsViewed() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StoryProvider>().markUserStoriesAsViewed(widget.userId);
    });
  }

  void _nextStory() {
    if (_currentIndex < _userStories.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  void _previousStory() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final story = _userStories[_currentIndex];
    
    return Scaffold(
      backgroundColor: Colors.black, // Stories look best on pure black
      body: GestureDetector(
        onTapDown: (details) {
          final screenWidth = MediaQuery.of(context).size.width;
          if (details.globalPosition.dx < screenWidth / 3) {
            _previousStory();
          } else {
            _nextStory();
          }
        },
        child: Stack(
          children: [
            // 1. Story Content
            PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _userStories.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                  _progressController.reset();
                  _progressController.forward();
                });
              },
              itemBuilder: (context, index) => _buildStoryContent(_userStories[index], colors),
            ),
            
            // 2. Progress Indicators
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              left: 10,
              right: 10,
              child: Row(
                children: List.generate(_userStories.length, (index) {
                  return Expanded(
                    child: Container(
                      height: 2.5,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: index == _currentIndex
                          ? AnimatedBuilder(
                              animation: _progressController,
                              builder: (context, child) {
                                return LinearProgressIndicator(
                                  value: _progressController.value,
                                  backgroundColor: Colors.transparent,
                                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                );
                              },
                            )
                          : Container(
                              color: index < _currentIndex ? Colors.white : Colors.transparent,
                            ),
                    ),
                  );
                }),
              ),
            ),
            
            // 3. User Header
            Positioned(
              top: MediaQuery.of(context).padding.top + 25,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundImage: NetworkImage(story.userImage),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          story.userName,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        Text(
                          _getTimeAgo(story.timestamp),
                          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoryContent(Story story, ColorScheme colors) {
    switch (story.mediaType) {
      case StoryMediaType.image:
        return Image.network(
          story.mediaUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        );
      case StoryMediaType.video:
        return Container(
          color: Colors.black,
          child: const Center(child: Icon(Icons.play_circle_outline, color: Colors.white, size: 80)),
        );
      case StoryMediaType.text:
        return Container(
          color: story.color != null ? Color(int.parse(story.color!)) : colors.primary,
          padding: const EdgeInsets.all(40),
          child: Center(
            child: Text(
              story.caption ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
            ),
          ),
        );
    }
  }

  String _getTimeAgo(DateTime timestamp) {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

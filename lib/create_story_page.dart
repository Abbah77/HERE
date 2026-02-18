import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:here/models/story.dart';
import 'package:here/providers/story_provider.dart';

class CreateStoryPage extends StatefulWidget {
  const CreateStoryPage({super.key});

  @override
  State<CreateStoryPage> createState() => _CreateStoryPageState();
}

class _CreateStoryPageState extends State<CreateStoryPage> {
  final TextEditingController _textController = TextEditingController();
  // Fixed: Defaulting to a standard hex format string
  String _selectedColor = '0xFF6B6B'; 

  final List<String> _colors = [
    '0xFF6B6B', // Coral
    '0xFF4ECDC4', // Mint
    '0xFF45B7D1', // Sky
    '0xFF96CEB4', // Sage
    '0xFFFFEEAD'  // Cream
  ];

  void _submitStory() async {
    if (_textController.text.trim().isEmpty) return;

    final success = await context.read<StoryProvider>().addStory(
      mediaUrl: '', 
      mediaType: StoryMediaType.text,
      caption: _textController.text,
      color: _selectedColor,
    );

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Story posted!'), 
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Parsing helper to ensure we don't crash on color hex strings
    final bgColor = Color(int.parse(_selectedColor));

    return Scaffold(
      // Keep using withOpacity as Codemagic/Older SDK doesn't like .withValues
      backgroundColor: bgColor.withOpacity(0.95),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton(
              onPressed: _submitStory,
              child: const Text(
                'Post', 
                style: TextStyle(
                  color: Colors.white, 
                  fontWeight: FontWeight.bold, 
                  fontSize: 16
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: TextField(
                  controller: _textController,
                  maxLines: null,
                  textAlign: TextAlign.center,
                  cursorColor: Colors.white,
                  style: const TextStyle(
                    color: Colors.white, 
                    fontSize: 32, 
                    fontWeight: FontWeight.bold
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Type something...',
                    hintStyle: TextStyle(color: Colors.white60),
                    border: InputBorder.none,
                  ),
                  autofocus: true,
                ),
              ),
            ),
          ),
          _buildColorPicker(),
        ],
      ),
    );
  }

  Widget _buildColorPicker() {
    return Container(
      padding: const EdgeInsets.only(bottom: 40, top: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _colors.map((colorStr) {
          final colorValue = Color(int.parse(colorStr));
          final isSelected = _selectedColor == colorStr;

          return GestureDetector(
            onTap: () => setState(() => _selectedColor = colorStr),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 8),
              width: isSelected ? 42 : 35,
              height: isSelected ? 42 : 35,
              decoration: BoxDecoration(
                color: colorValue,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.white : Colors.white24,
                  width: isSelected ? 3 : 1,
                ),
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2), 
                    blurRadius: 10, 
                    spreadRadius: 1
                  )
                ] : [],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:here/profile.dart';
import 'package:here/models/connection.dart';

class Connections extends StatefulWidget {
  const Connections({super.key});

  @override
  State<Connections> createState() => _ConnectionsState();
}

class _ConnectionsState extends State<Connections> with TickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';
  
  // FIX: Using 'role' instead of 'category' to match standard Flutter models
  // and removing 'const' so dynamic URLs work smoothly
  final List<Connection> _allConnections = [
    Connection(
      id: '1',
      name: 'Alan Patterson',
      role: 'Software Engineer', // This likely maps to 'category' in your list
      company: 'Google',
      imageUrl: 'https://bloximages.newyork1.vip.townnews.com/roanoke.com/content/tncms/assets/v3/editorial/d/da/ddac1f83-ffae-5e84-a8e5-e71f8ff18119/5f3176da21b5c.image.jpg',
      isOnline: true,
    ),
    Connection(
      id: '2',
      name: 'Adam Mathew',
      role: 'Life Science Engineer',
      company: 'Microsoft',
      imageUrl: 'https://ggsc.s3.amazonaws.com/images/made/images/uploads/Six_Ways_to_Speak_Up_Against_Bad_Behavior_350_235_s_c1.jpg',
      isOnline: false,
    ),
    Connection(
      id: '3',
      name: 'Amaz Benzos',
      role: 'Simple Guy',
      company: 'Amazon',
      imageUrl: 'https://i.insider.com/5f46d58ccd2fec00296a46b9',
      isOnline: true,
    ),
    Connection(
      id: '4',
      name: 'Birat Kholi',
      role: 'Leg Square Engineer',
      company: 'Cricket',
      imageUrl: 'https://resize.indiatvnews.com/en/resize/newbucket/1200_-/2019/11/virat-kohli-1574240907.jpg',
      isOnline: false,
    ),
  ];

  final List<String> _categories = ['All', 'Engineer', 'Design', 'Other'];

  List<Connection> get _filteredConnections {
    return _allConnections.where((c) {
      final matchesSearch = c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                            c.role.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCat = _selectedCategory == 'All' || c.role.contains(_selectedCategory);
      return matchesSearch && matchesCat;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: const Duration(milliseconds: 600), vsync: this);
    _fadeAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeIn);
    _animationController.forward();
    _searchController.addListener(() => setState(() => _searchQuery = _searchController.text));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0, 
        backgroundColor: Colors.white, 
        leading: const BackButton(color: Colors.black)
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            _buildTopSection(),
            _buildSearchBar(),
            _buildFilterBar(),
            const SizedBox(height: 10),
            Expanded(child: _buildList()),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Connections', style: GoogleFonts.lato(fontSize: 24, fontWeight: FontWeight.bold)),
              Text('${_filteredConnections.length} Active Contacts', style: const TextStyle(color: Colors.grey)),
            ],
          ),
          FloatingActionButton.small(
            onPressed: () {},
            backgroundColor: Colors.orange,
            child: const Icon(Icons.add, color: Colors.white),
          )
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search people...',
          prefixIcon: const Icon(Icons.search, size: 20),
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: _categories.map((cat) {
          final isSelected = _selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(cat),
              selected: isSelected,
              onSelected: (val) => setState(() => _selectedCategory = cat),
              selectedColor: Colors.orange,
              labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildList() {
    final list = _filteredConnections;
    if (list.isEmpty) return const Center(child: Text("No one found"));

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      itemCount: list.length,
      separatorBuilder: (context, index) => const Divider(indent: 70, height: 1),
      itemBuilder: (context, index) => ConnectionTile(connection: list[index]),
    );
  }
}

class ConnectionTile extends StatelessWidget {
  final Connection connection;
  const ConnectionTile({super.key, required this.connection});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const Profile())),
      leading: CircleAvatar(
        radius: 26,
        backgroundImage: NetworkImage(connection.imageUrl),
        child: connection.isOnline 
          ? Align(
              alignment: Alignment.bottomRight,
              child: Container(
                width: 12, height: 12, 
                decoration: BoxDecoration(
                  color: Colors.green, 
                  shape: BoxShape.circle, 
                  border: Border.all(color: Colors.white, width: 2)
                ),
              ),
            )
          : null,
      ),
      title: Text(connection.name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text("${connection.role} • ${connection.company ?? 'Remote'}"),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
    );
  }
}

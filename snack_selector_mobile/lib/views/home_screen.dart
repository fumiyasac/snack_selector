import 'package:flutter/material.dart';
import 'recipe_list_screen.dart';
import 'swipe_screen.dart';
import 'favorites_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    RecipeListScreen(),
    SwipeScreen(),
    FavoritesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFFFF8BA7),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.cookie_outlined),
            activeIcon: Icon(Icons.cookie),
            label: '一覧',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.swipe_outlined),
            activeIcon: Icon(Icons.swipe),
            label: 'Swipe',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            activeIcon: Icon(Icons.favorite),
            label: 'お気に入り',
          ),
        ],
      ),
    );
  }
}

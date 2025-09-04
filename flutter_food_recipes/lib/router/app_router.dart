import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/explore_screen.dart';
import '../screens/favorites_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/recipe_detail_screen.dart';
import '../screens/create_recipe_screen.dart';
import '../services/mock_recipe_service.dart';

/// App router configuration using GoRouter
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // ShellRoute for bottom navigation
    ShellRoute(
      builder: (context, state, child) => BottomNavWrapper(child: child),
      routes: [
        GoRoute(path: '/', builder: (context, state) => const ExploreScreen()),
        GoRoute(
          path: '/favorites',
          builder: (context, state) => const FavoritesScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),

    // Recipe Detail screen
    GoRoute(
      path: '/recipe/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        final recipe = MockRecipeService.getAllRecipes().firstWhere(
          (r) => r.id == id,
        );
        return RecipeDetailScreen(recipe: recipe);
      },
    ),

    // Create Recipe screen
    GoRoute(path: '/create', builder: (context, state) => CreateRecipeScreen()),
  ],
);

/// Bottom navigation wrapper
class BottomNavWrapper extends StatefulWidget {
  final Widget child;
  const BottomNavWrapper({required this.child, super.key});

  @override
  State<BottomNavWrapper> createState() => _BottomNavWrapperState();
}

class _BottomNavWrapperState extends State<BottomNavWrapper> {
  int _currentIndex = 0;

  final List<String> _routes = ['/', '/favorites', '/profile'];

  void _onTap(int index) {
    if (index != _currentIndex) {
      setState(() => _currentIndex = index);
      // Navigate to the selected route
      context.go(_routes[index]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTap,
        selectedItemColor: Colors.orangeAccent,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explore'),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/recipe.dart';
import '../services/favorites_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<String> favoriteIds = [];
  List<Recipe> favoriteRecipes = [];
  bool isLoading = true;
  String? errorMessage;

  final String baseUrl =
      "http://localhost:3000"; // ✅ change to 10.0.2.2 for emulator

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      favoriteIds = await FavoritesService.loadFavorites();

      // fetch recipes from backend
      final response = await http.get(Uri.parse("$baseUrl/api/recipes"));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final allRecipes = data.map((json) => Recipe.fromJson(json)).toList();

        favoriteRecipes = allRecipes
            .where((r) => favoriteIds.contains(r.id))
            .toList();
      } else {
        errorMessage = "Failed to fetch recipes: ${response.statusCode}";
      }
    } catch (e) {
      errorMessage = e.toString();
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _toggleFavorite(String recipeId) async {
    setState(() {
      if (favoriteIds.contains(recipeId)) {
        favoriteIds.remove(recipeId);
        favoriteRecipes.removeWhere((r) => r.id == recipeId);
      } else {
        favoriteIds.add(recipeId);
        // no direct add, reload from API to sync
        _loadFavorites();
      }
    });
    await FavoritesService.saveFavorites(favoriteIds);
  }

  void _navigateToRecipeDetail(Recipe recipe) {
    context.go('/recipe/${recipe.id}');
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(child: Text("Error: $errorMessage"));
    }

    if (favoriteRecipes.isEmpty) {
      return const Center(
        child: Text(
          'No favorite recipes yet.',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: favoriteRecipes.length,
      itemBuilder: (context, index) {
        final recipe = favoriteRecipes[index];
        return GestureDetector(
          onTap: () => _navigateToRecipeDetail(recipe),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            shadowColor: Colors.orangeAccent.withOpacity(0.3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag: recipe.id,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: recipe.imageUrl.isNotEmpty
                        ? Image.network(
                            "$baseUrl${recipe.imageUrl}",
                            width: double.infinity,
                            height: 150,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.broken_image, size: 80),
                          )
                        : const Icon(Icons.fastfood, size: 100),
                  ),
                ),
                ListTile(
                  title: Text(
                    recipe.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(recipe.category),
                  trailing: IconButton(
                    icon: Icon(
                      favoriteIds.contains(recipe.id)
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: Colors.red,
                    ),
                    onPressed: () => _toggleFavorite(recipe.id),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

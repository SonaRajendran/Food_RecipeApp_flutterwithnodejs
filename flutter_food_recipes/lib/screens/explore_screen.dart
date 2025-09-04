import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../services/favorites_service.dart';
import 'recipe_detail_screen.dart';
import 'create_recipe_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  List<Recipe> allRecipes = [];
  List<String> favoriteIds = [];
  bool showFavoritesOnly = false;
  String searchQuery = "";
  String selectedCategory = "All";
  bool isLoading = true;
  String? errorMessage;

  // Change depending on platform
  final String baseUrl = "http://localhost:3000";

  final List<String> categories = [
    "All",
    "Breakfast",
    "Lunch",
    "Dinner",
    "Dessert",
  ];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    _fetchRecipes();
  }

  Future<void> _loadFavorites() async {
    try {
      favoriteIds = await FavoritesService.loadFavorites();
    } catch (e) {
      favoriteIds = [];
    }
    setState(() {});
  }

  Future<void> _fetchRecipes() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await http.get(Uri.parse("$baseUrl/api/recipes"));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        allRecipes = data.map((json) => Recipe.fromJson(json)).toList();
      } else {
        errorMessage = "Failed to load recipes: ${response.statusCode}";
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
      } else {
        favoriteIds.add(recipeId);
      }
    });
    await FavoritesService.saveFavorites(favoriteIds);
  }

  List<Recipe> _getFilteredRecipes() {
    List<Recipe> recipes = List.from(allRecipes);

    if (selectedCategory != "All") {
      recipes = recipes.where((r) => r.category == selectedCategory).toList();
    }

    if (showFavoritesOnly) {
      recipes = recipes.where((r) => favoriteIds.contains(r.id)).toList();
    }

    if (searchQuery.isNotEmpty) {
      recipes = recipes
          .where(
            (r) => r.title.toLowerCase().contains(searchQuery.toLowerCase()),
          )
          .toList();
    }

    return recipes;
  }

  void _navigateToCreateRecipe() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateRecipeScreen()),
    );
    _fetchRecipes(); // reload after creating new recipe
  }

  @override
  Widget build(BuildContext context) {
    final recipes = _getFilteredRecipes();

    return Scaffold(
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: "Search recipes...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
              onChanged: (value) => setState(() {
                searchQuery = value;
              }),
            ),
          ),

          // Category Filter
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = selectedCategory == category;
                return GestureDetector(
                  onTap: () => setState(() {
                    selectedCategory = category;
                  }),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.orangeAccent
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        category,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Favorites Toggle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                const Text("Show Favorites Only"),
                const Spacer(),
                Switch(
                  value: showFavoritesOnly,
                  onChanged: (value) => setState(() {
                    showFavoritesOnly = value;
                  }),
                ),
              ],
            ),
          ),

          // Recipe List
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : errorMessage != null
                ? Center(child: Text("Error: $errorMessage"))
                : recipes.isEmpty
                ? const Center(child: Text("No recipes found."))
                : ListView.builder(
                    itemCount: recipes.length,
                    itemBuilder: (context, index) {
                      final recipe = recipes[index];
                      final isFavorite = favoriteIds.contains(recipe.id);

                      return Card(
                        margin: const EdgeInsets.all(8),
                        child: ListTile(
                          leading: recipe.imageUrl.isNotEmpty
                              ? Image.network(
                                  "$baseUrl${recipe.imageUrl}",
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      const Icon(Icons.broken_image),
                                )
                              : const Icon(Icons.fastfood),
                          title: Text(recipe.title),
                          subtitle: Text(recipe.description),
                          trailing: IconButton(
                            icon: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: Colors.red,
                            ),
                            onPressed: () => _toggleFavorite(recipe.id),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    RecipeDetailScreen(recipe: recipe),
                              ),
                            ).then((_) => _loadFavorites());
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),

      // Floating Action Button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToCreateRecipe,
        icon: const Icon(Icons.add),
        label: const Text("Create Recipe"),
      ),
    );
  }
}

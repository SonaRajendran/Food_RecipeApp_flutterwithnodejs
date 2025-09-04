import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/recipe.dart';
import '../services/mock_recipe_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String query = "";
  List<Recipe> allRecipes = MockRecipeService.getAllRecipes();
  late List<Recipe> filteredRecipes;

  @override
  void initState() {
    super.initState();
    filteredRecipes = allRecipes;
  }

  void updateSearch(String value) {
    setState(() {
      query = value.toLowerCase();
      filteredRecipes = allRecipes
          .where(
            (recipe) =>
                recipe.title.toLowerCase().contains(query) ||
                recipe.description.toLowerCase().contains(query),
          )
          .toList();
    });
  }

  void _navigateToRecipeDetail(String recipeId) {
    context.go('/recipe/$recipeId');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Search Recipes")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: "Search recipes...",
                border: OutlineInputBorder(),
              ),
              onChanged: updateSearch,
            ),
          ),
          Expanded(
            child: filteredRecipes.isEmpty
                ? const Center(child: Text("No recipes found"))
                : ListView.builder(
                    itemCount: filteredRecipes.length,
                    itemBuilder: (context, index) {
                      final recipe = filteredRecipes[index];
                      return ListTile(
                        leading: Image.network(
                          recipe.imageUrl,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                        title: Text(recipe.title),
                        subtitle: Text(recipe.description),
                        onTap: () {
                          _navigateToRecipeDetail(recipe.id);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

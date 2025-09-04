import '../models/recipe.dart';

class MockRecipeService {
  // 🔹 In-memory list of recipes
  static final List<Recipe> _recipes = List.from(Recipe.mockRecipes);

  /// Get all recipes
  static List<Recipe> getAllRecipes() => List.from(_recipes);

  /// Get recipes by category
  static List<Recipe> getRecipesByCategory(String category) {
    if (category == "All") return getAllRecipes();
    return _recipes.where((r) => r.category == category).toList();
  }

  /// Get favorite recipes by IDs
  static List<Recipe> getFavorites(List<String> favoriteIds) {
    return _recipes.where((r) => favoriteIds.contains(r.id)).toList();
  }

  /// Add a new recipe
  static void addRecipe(Recipe recipe) {
    _recipes.add(recipe);
  }

  /// Get recipes created by a specific user
  static List<Recipe> getRecipesByUser(String createdBy) {
    return _recipes.where((r) => r.createdBy == createdBy).toList();
  }
}

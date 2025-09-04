// lib/providers/recipe_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/recipe.dart';
import '../services/mock_recipe_service.dart'; // 👈 Import the service

final recipeProvider = FutureProvider<List<Recipe>>((ref) async {
  // later we fetch from backend, for now mock data
  await Future.delayed(const Duration(seconds: 2)); // fake loading
  return MockRecipeService.getAllRecipes(); // 👈 Use the correct service method
});

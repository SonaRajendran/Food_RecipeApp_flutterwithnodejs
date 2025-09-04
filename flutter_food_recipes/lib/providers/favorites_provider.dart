import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/recipe.dart';

/// StateNotifier to manage favorite recipes
class FavoritesNotifier extends StateNotifier<List<Recipe>> {
  FavoritesNotifier() : super([]);

  void toggleFavorite(Recipe recipe) {
    if (state.contains(recipe)) {
      state = state.where((r) => r.id != recipe.id).toList();
    } else {
      state = [...state, recipe];
    }
  }

  bool isFavorite(Recipe recipe) {
    return state.any((r) => r.id == recipe.id);
  }
}

/// Provider for favorites list
final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, List<Recipe>>(
      (ref) => FavoritesNotifier(),
    );

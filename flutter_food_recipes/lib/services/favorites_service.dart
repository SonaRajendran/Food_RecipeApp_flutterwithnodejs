import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService {
  static const String _favoritesKey = "favorite_recipes";

  /// Load favorite recipe IDs from SharedPreferences
  static Future<List<String>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteList = prefs.getStringList(_favoritesKey);
    return favoriteList ?? [];
  }

  /// Save favorite recipe IDs to SharedPreferences
  static Future<void> saveFavorites(List<String> favoriteIds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoritesKey, favoriteIds);
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe.dart';

class RecipeService {
  static const String baseUrl = 'http://localhost:3000/api/recipes';

  // Get all recipes
  static Future<List<Recipe>> fetchRecipes() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data
          .map(
            (e) => Recipe(
              id: e['id'].toString(),
              title: e['title'],
              description: e['description'],
              imageUrl: e['image_url'],
              ingredients: List<String>.from(jsonDecode(e['ingredients'])),
              steps: List<String>.from(jsonDecode(e['steps'])),
              category: e['category'],
              createdBy: e['created_by'],
            ),
          )
          .toList();
    } else {
      throw Exception('Failed to load recipes');
    }
  }

  // Create a new recipe
  static Future<Recipe> createRecipe(Recipe recipe) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': recipe.title,
        'description': recipe.description,
        'image_url': recipe.imageUrl,
        'ingredients': jsonEncode(recipe.ingredients),
        'steps': jsonEncode(recipe.steps),
        'category': recipe.category,
        'created_by': recipe.createdBy,
      }),
    );

    if (response.statusCode == 201) {
      final e = jsonDecode(response.body);
      return Recipe(
        id: e['id'].toString(),
        title: e['title'],
        description: e['description'],
        imageUrl: e['image_url'],
        ingredients: List<String>.from(jsonDecode(e['ingredients'])),
        steps: List<String>.from(jsonDecode(e['steps'])),
        category: e['category'],
        createdBy: e['created_by'],
      );
    } else {
      throw Exception('Failed to create recipe');
    }
  }
}

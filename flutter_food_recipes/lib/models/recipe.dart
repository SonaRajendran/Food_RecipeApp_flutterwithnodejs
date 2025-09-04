import 'dart:convert';

class Recipe {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final List<String> ingredients;
  final List<String> steps;
  final String category;
  final String createdBy;

  Recipe({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.ingredients,
    required this.steps,
    required this.category,
    required this.createdBy,
  });

  // 🔹 Convert JSON to Recipe
  factory Recipe.fromJson(Map<String, dynamic> json) {
    List<String> parseList(dynamic value) {
      if (value is String) {
        return List<String>.from(jsonDecode(value));
      } else if (value is List) {
        return List<String>.from(value);
      } else {
        return [];
      }
    }

    return Recipe(
      id: json['id'].toString(),
      title: json['title'],
      description: json['description'],
      imageUrl: json['image_url'] ?? '',
      ingredients: parseList(json['ingredients']),
      steps: parseList(json['steps']),
      category: json['category'],
      createdBy: json['created_by'],
    );
  }

  // 🔹 Convert Recipe to JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'ingredients': ingredients,
      'steps': steps,
      'category': category,
      'created_by': createdBy,
    };
  }

  // 🔹 Mock Data
  static List<Recipe> mockRecipes = [
    Recipe(
      id: "1",
      title: "Spaghetti Carbonara",
      description: "A classic Italian pasta with creamy sauce.",
      imageUrl: "https://picsum.photos/400/300?random=1",
      ingredients: [
        "200g spaghetti",
        "2 eggs",
        "100g pancetta",
        "50g parmesan cheese",
        "Salt & black pepper",
      ],
      steps: [
        "Boil spaghetti until al dente.",
        "Fry pancetta until crispy.",
        "Mix eggs with parmesan.",
        "Combine spaghetti, pancetta, and egg mix.",
        "Serve hot with pepper.",
      ],
      category: "Dinner",
      createdBy: "John Doe",
    ),
    Recipe(
      id: "2",
      title: "Chicken Curry",
      description: "Spicy and flavorful chicken curry.",
      imageUrl: "https://picsum.photos/400/300?random=2",
      ingredients: [
        "500g chicken",
        "2 onions",
        "2 tomatoes",
        "3 garlic cloves",
        "Spices (turmeric, chili, cumin)",
      ],
      steps: [
        "Fry onions and garlic.",
        "Add tomatoes and spices.",
        "Cook chicken until tender.",
        "Simmer for 20 minutes.",
        "Serve with rice.",
      ],
      category: "Lunch",
      createdBy: "Jane Smith",
    ),
    Recipe(
      id: "3",
      title: "Avocado Salad",
      description: "Healthy salad with avocado and fresh veggies.",
      imageUrl: "https://picsum.photos/400/300?random=3",
      ingredients: [
        "2 avocados",
        "1 cucumber",
        "1 tomato",
        "Lemon juice",
        "Olive oil",
      ],
      steps: [
        "Chop all veggies.",
        "Mix in a bowl.",
        "Drizzle lemon juice and olive oil.",
        "Add salt and pepper.",
        "Serve fresh.",
      ],
      category: "Breakfast",
      createdBy: "Alice Brown",
    ),
  ];
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../models/recipe.dart';
import '../services/mock_recipe_service.dart';
import '../services/profile_service.dart';

const String _baseUrl =
    "http://localhost:3000"; // Use http://10.0.2.2:3000 for emulator

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String userName = "John Doe";
  String userEmail = "johndoe@example.com";
  String? _profileImageUrl;
  bool isLoading = false;

  String searchQuery = '';
  String selectedCategory = 'All';
  final List<String> categories = ['All', 'Lunch', 'Dinner', 'Dessert'];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => isLoading = true);
    final profile = await ProfileService.getProfile();
    if (profile != null) {
      setState(() {
        userName = profile['name']!;
        userEmail = profile['email']!;
        _profileImageUrl = profile['profile_image_url']!.isNotEmpty
            ? profile['profile_image_url']
            : null;
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  List<Recipe> get myRecipes {
    var recipes = MockRecipeService.getAllRecipes()
        .where((r) => r.createdBy == userName)
        .toList();

    if (selectedCategory != 'All') {
      recipes = recipes.where((r) => r.category == selectedCategory).toList();
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

  void _navigateToCreateRecipe() {
    context.go('/create');
  }

  void _navigateToRecipeDetail(String recipeId) {
    context.go('/recipe/$recipeId');
  }

  Future<void> _editProfile() async {
    final nameController = TextEditingController(text: userName);
    final emailController = TextEditingController(text: userEmail);

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Profile"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Name"),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "Email"),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _pickAndUploadImage,
                icon: const Icon(Icons.upload),
                label: const Text("Change Profile Picture"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              setState(() => isLoading = true);
              final success = await ProfileService.updateProfile(
                nameController.text,
                emailController.text,
              );
              if (success) {
                setState(() {
                  userName = nameController.text;
                  userEmail = emailController.text;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Profile updated successfully")),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Failed to update profile")),
                );
              }
              setState(() => isLoading = false);
              context.pop();
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() => isLoading = true);
      final newUrl = await ProfileService.uploadProfileImage(image);
      if (newUrl != null) {
        setState(() {
          _profileImageUrl = newUrl;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile image uploaded successfully")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to upload profile image")),
        );
      }
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final recipes = myRecipes;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.orangeAccent,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  CircleAvatar(
                    radius: 50,
                    backgroundImage:
                        _profileImageUrl != null && _profileImageUrl!.isNotEmpty
                        ? NetworkImage("$_baseUrl$_profileImageUrl")
                        : null,
                    child: _profileImageUrl == null
                        ? Text(
                            userName.isNotEmpty
                                ? userName[0].toUpperCase()
                                : '',
                            style: const TextStyle(
                              fontSize: 30,
                              color: Colors.white,
                            ),
                          )
                        : null,
                    backgroundColor: Colors.grey[300],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    userEmail,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                    child: ListTile(
                      leading: const Icon(Icons.favorite, color: Colors.red),
                      title: const Text("Favorites"),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        context.go('/favorites');
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                    child: ListTile(
                      leading: const Icon(Icons.edit, color: Colors.orange),
                      title: const Text("Edit Profile"),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: _editProfile,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                    child: ListTile(
                      leading: const Icon(Icons.logout, color: Colors.red),
                      title: const Text("Logout"),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Logged out successfully"),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "My Recipes",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  recipes.isEmpty
                      ? const Center(
                          child: Text('No recipes created by you yet.'),
                        )
                      : ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: recipes.length,
                          itemBuilder: (context, index) {
                            final recipe = recipes[index];
                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 3,
                              child: ListTile(
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    recipe.imageUrl,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(
                                              Icons.image_not_supported,
                                            ),
                                  ),
                                ),
                                title: Text(recipe.title),
                                subtitle: Text(recipe.category),
                                onTap: () {
                                  _navigateToRecipeDetail(recipe.id);
                                },
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateRecipe,
        backgroundColor: Colors.orangeAccent,
        child: const Icon(Icons.add),
      ),
    );
  }
}

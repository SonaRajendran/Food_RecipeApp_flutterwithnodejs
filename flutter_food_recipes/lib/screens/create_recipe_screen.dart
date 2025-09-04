import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CreateRecipeScreen extends StatefulWidget {
  const CreateRecipeScreen({super.key});

  @override
  State<CreateRecipeScreen> createState() => _CreateRecipeScreenState();
}

class _CreateRecipeScreenState extends State<CreateRecipeScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _createdByController = TextEditingController(
    text: "User",
  );

  final List<TextEditingController> _ingredientControllers = [];
  final List<TextEditingController> _stepControllers = [];

  String selectedCategory = "Breakfast";
  final List<String> categories = ["Breakfast", "Lunch", "Dinner", "Dessert"];

  XFile? _pickedImage;

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _ingredientControllers.add(TextEditingController());
    _stepControllers.add(TextEditingController());
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final userName = prefs.getString('profile_name') ?? 'User';
    setState(() {
      _createdByController.text = userName;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _createdByController.dispose();
    for (var c in _ingredientControllers) {
      c.dispose();
    }
    for (var c in _stepControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _pickedImage = picked;
      });
    }
  }

  Future<void> _createRecipe() async {
    if (!_formKey.currentState!.validate()) return;

    final uri = Uri.parse("http://localhost:3000/api/recipes");

    try {
      http.Response response;

      if (kIsWeb) {
        // For web, send JSON POST request
        final body = jsonEncode({
          "title": _titleController.text,
          "description": _descriptionController.text,
          "category": selectedCategory,
          "createdBy": _createdByController.text,
          "ingredients": _ingredientControllers.map((c) => c.text).toList(),
          "steps": _stepControllers.map((c) => c.text).toList(),
          // Image upload for web can be handled separately if needed
        });

        response = await http.post(
          uri,
          headers: {"Content-Type": "application/json"},
          body: body,
        );
      } else {
        // For mobile/desktop, use multipart request
        final request = http.MultipartRequest("POST", uri);

        request.fields["title"] = _titleController.text;
        request.fields["description"] = _descriptionController.text;
        request.fields["category"] = selectedCategory;
        request.fields["createdBy"] = _createdByController.text;
        request.fields["ingredients"] = jsonEncode(
          _ingredientControllers.map((c) => c.text).toList(),
        );
        request.fields["steps"] = jsonEncode(
          _stepControllers.map((c) => c.text).toList(),
        );

        if (_pickedImage != null) {
          request.files.add(
            await http.MultipartFile.fromPath("image", _pickedImage!.path),
          );
        }

        final streamedResponse = await request.send();
        response = await http.Response.fromStream(streamedResponse);
      }

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Recipe created successfully")),
        );
        Navigator.pop(context);
      } else {
        throw Exception("Failed: ${response.body}");
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Widget _buildImagePreview() {
    if (_pickedImage == null) return const SizedBox.shrink();

    return kIsWeb
        ? Image.network(
            _pickedImage!.path,
            height: 150,
            width: double.infinity,
            fit: BoxFit.cover,
          )
        : Image.file(
            File(_pickedImage!.path),
            height: 150,
            width: double.infinity,
            fit: BoxFit.cover,
          );
  }

  Widget _buildDynamicTextFields(
    List<TextEditingController> controllers,
    String label,
  ) {
    return Column(
      children: controllers.asMap().entries.map((entry) {
        int index = entry.key;
        final controller = entry.value;
        return Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: controller,
                decoration: InputDecoration(labelText: "$label ${index + 1}"),
                validator: (value) =>
                    value == null || value.isEmpty ? "Required" : null,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                setState(() {
                  controllers.add(TextEditingController());
                });
              },
            ),
          ],
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Recipe")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: "Title"),
                validator: (v) => v == null || v.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: "Description"),
                maxLines: 3,
                validator: (v) => v == null || v.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: const InputDecoration(labelText: "Category"),
                items: categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => selectedCategory = v!),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _createdByController,
                decoration: const InputDecoration(labelText: "Created By"),
              ),
              const SizedBox(height: 12),

              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.upload),
                label: const Text("Pick Image"),
              ),
              const SizedBox(height: 12),
              _buildImagePreview(),
              const SizedBox(height: 16),

              const Text(
                "Ingredients",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              _buildDynamicTextFields(_ingredientControllers, "Ingredient"),

              const SizedBox(height: 16),
              const Text(
                "Steps",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              _buildDynamicTextFields(_stepControllers, "Step"),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _createRecipe,
                  child: const Text("Create Recipe"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../models/category.dart';
import '../../services/category_service.dart';

class CategoryView extends StatefulWidget {
  const CategoryView({super.key});

  @override
  State<CategoryView> createState() => _CategoryViewState();
}

class _CategoryViewState extends State<CategoryView> {
  final CategoryService _categoryService = CategoryService();
  final TextEditingController _nameController = TextEditingController();
  bool _isProductive = true;

  List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final categories = await _categoryService.getCategories();
    setState(() {
      _categories = categories;
    });
  }

  Future<void> _addCategory() async {
    if (_nameController.text.isEmpty) return;
    final category = Category(
      id: 0,
      name: _nameController.text,
      isProductive: _isProductive,
    );
    await _categoryService.addCategory(category);
    _nameController.clear();
    _loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Categories'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Category Name'),
                  ),
                ),
                const SizedBox(width: 10),
                DropdownButton<bool>(
                  value: _isProductive,
                  items: const [
                    DropdownMenuItem(value: true, child: Text('Productive')),
                    DropdownMenuItem(value: false, child: Text('Unproductive')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _isProductive = value!;
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addCategory,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                return ListTile(
                  title: Text(category.name),
                  trailing: Text(category.isProductive ? 'Productive' : 'Unproductive'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

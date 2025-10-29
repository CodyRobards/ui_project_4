import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  bool _isDarkMode = false;

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recipe Keeper',
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepOrange,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: HomePage(
        isDarkMode: _isDarkMode,
        onToggleTheme: _toggleTheme,
      ),
    );
  }
}

class Recipe {
  const Recipe({
    required this.id,
    required this.name,
    required this.instructions,
    required this.ingredients,
  });

  final int id;
  final String name;
  final String instructions;
  final List<String> ingredients;
}

class HomePage extends StatefulWidget {
  const HomePage({
    required this.isDarkMode,
    required this.onToggleTheme,
    super.key,
  });

  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  int _nextRecipeId = 0;
  final List<Recipe> _recipes = [];
  final Map<int, int> _cart = {};

  void _addRecipe(String name, String instructions, List<String> ingredients) {
    setState(() {
      _recipes.add(
        Recipe(
          id: _nextRecipeId++,
          name: name,
          instructions: instructions,
          ingredients: List.unmodifiable(ingredients),
        ),
      );
    });
  }

  void _deleteRecipe(Recipe recipe) {
    setState(() {
      _recipes.removeWhere((r) => r.id == recipe.id);
      _cart.remove(recipe.id);
    });
  }

  void _incrementRecipe(Recipe recipe) {
    setState(() {
      _cart.update(recipe.id, (value) => value + 1, ifAbsent: () => 1);
    });
  }

  void _decrementRecipe(Recipe recipe) {
    setState(() {
      final currentCount = _cart[recipe.id];
      if (currentCount == null) {
        return;
      }
      if (currentCount <= 1) {
        _cart.remove(recipe.id);
      } else {
        _cart[recipe.id] = currentCount - 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final pageTitles = ['View Recipes', 'Add Recipe', 'Shopping Cart'];

    return Scaffold(
      appBar: AppBar(
        title: Text(pageTitles[_selectedIndex]),
        actions: [
          IconButton(
            onPressed: widget.onToggleTheme,
            icon: Icon(
              widget.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            ),
            tooltip: widget.isDarkMode ? 'Switch to light mode' : 'Switch to dark mode',
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          ViewRecipesPage(
            recipes: _recipes,
            onDelete: _deleteRecipe,
          ),
          AddRecipePage(
            onSave: _addRecipe,
          ),
          ShoppingCartPage(
            recipes: _recipes,
            cart: _cart,
            onIncrement: _incrementRecipe,
            onDecrement: _decrementRecipe,
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'Recipes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Add',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
        ],
      ),
    );
  }
}

class AddRecipePage extends StatefulWidget {
  const AddRecipePage({
    required this.onSave,
    super.key,
  });

  final void Function(String name, String instructions, List<String> ingredients)
      onSave;

  @override
  State<AddRecipePage> createState() => _AddRecipePageState();
}

class _AddRecipePageState extends State<AddRecipePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();
  final TextEditingController _ingredientController = TextEditingController();
  final List<String> _ingredients = [];

  void _addIngredient() {
    final text = _ingredientController.text.trim();
    if (text.isEmpty) {
      return;
    }

    setState(() {
      _ingredients.add(text);
      _ingredientController.clear();
    });
  }

  void _removeIngredient(int index) {
    setState(() {
      _ingredients.removeAt(index);
    });
  }

  void _saveRecipe() {
    final name = _nameController.text.trim();
    final instructions = _instructionsController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a recipe name.')),
      );
      return;
    }

    if (_ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one ingredient.')),
      );
      return;
    }

    widget.onSave(name, instructions, List<String>.from(_ingredients));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Saved "$name" to your cookbook.')),
    );

    setState(() {
      _nameController.clear();
      _instructionsController.clear();
      _ingredientController.clear();
      _ingredients.clear();
    });
    FocusScope.of(context).unfocus();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _instructionsController.dispose();
    _ingredientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Recipe name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _instructionsController,
            maxLines: 6,
            decoration: const InputDecoration(
              labelText: 'Cooking instructions',
              alignLabelWithHint: true,
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ingredientController,
                  decoration: const InputDecoration(
                    labelText: 'Ingredient',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _addIngredient(),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _addIngredient,
                icon: const Icon(Icons.add),
                label: const Text('Add'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Ingredients (${_ingredients.length})',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          if (_ingredients.isEmpty)
            const Text('No ingredients yet. Start by adding one above.')
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _ingredients.length,
              itemBuilder: (context, index) {
                final ingredient = _ingredients[index];
                return Card(
                  child: ListTile(
                    title: Text(ingredient),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _removeIngredient(index),
                      tooltip: 'Remove ingredient',
                    ),
                  ),
                );
              },
            ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _saveRecipe,
              icon: const Icon(Icons.save_alt),
              label: const Text('Save recipe'),
            ),
          ),
        ],
      ),
    );
  }
}

class ViewRecipesPage extends StatelessWidget {
  const ViewRecipesPage({
    required this.recipes,
    required this.onDelete,
    super.key,
  });

  final List<Recipe> recipes;
  final void Function(Recipe recipe) onDelete;

  void _showRecipeDetails(BuildContext context, Recipe recipe) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                recipe.name,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              Text(
                'Ingredients',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ...recipe.ingredients.map((ingredient) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.check_circle_outline),
                    title: Text(ingredient),
                  )),
              const SizedBox(height: 12),
              Text(
                'Instructions',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                recipe.instructions.isEmpty
                    ? 'No instructions provided.'
                    : recipe.instructions,
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (recipes.isEmpty) {
      return const Center(
        child: Text('No recipes yet. Add a new recipe to get started.'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        final recipe = recipes[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            title: Text(recipe.name),
            subtitle: Text('${recipe.ingredients.length} ingredient(s)'),
            onTap: () => _showRecipeDetails(context, recipe),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete recipe',
              onPressed: () => onDelete(recipe),
            ),
          ),
        );
      },
    );
  }
}

class ShoppingCartPage extends StatelessWidget {
  const ShoppingCartPage({
    required this.recipes,
    required this.cart,
    required this.onIncrement,
    required this.onDecrement,
    super.key,
  });

  final List<Recipe> recipes;
  final Map<int, int> cart;
  final void Function(Recipe recipe) onIncrement;
  final void Function(Recipe recipe) onDecrement;

  Map<String, int> _buildShoppingList() {
    final Map<String, int> shoppingList = {};
    for (final entry in cart.entries) {
      final recipe = recipes.firstWhere(
        (recipe) => recipe.id == entry.key,
        orElse: () =>
            const Recipe(id: -1, name: '', instructions: '', ingredients: []),
      );
      if (recipe.id == -1) continue;
      for (final ingredient in recipe.ingredients) {
        shoppingList.update(
          ingredient,
          (value) => value + entry.value,
          ifAbsent: () => entry.value,
        );
      }
    }
    return shoppingList;
  }

  @override
  Widget build(BuildContext context) {
    final shoppingList = _buildShoppingList();

    if (recipes.isEmpty) {
      return const Center(
        child: Text('Add recipes to start building your shopping list.'),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recipes',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: recipes.length,
              itemBuilder: (context, index) {
                final recipe = recipes[index];
                final count = cart[recipe.id] ?? 0;
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    title: Text(recipe.name),
                    subtitle: Text('In cart: $count'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          tooltip: 'Remove one',
                          onPressed: count > 0 ? () => onDecrement(recipe) : null,
                        ),
                        Text('$count'),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          tooltip: 'Add one',
                          onPressed: () => onIncrement(recipe),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Shopping list',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: shoppingList.isEmpty
                ? const Center(
                    child: Text('Select recipes to build your shopping list.'),
                  )
                : ListView(
                    children: shoppingList.entries.map((entry) {
                      final ingredient = entry.key;
                      final quantity = entry.value;
                      return ListTile(
                        leading: const Icon(Icons.checklist_rtl),
                        title: Text(ingredient),
                        trailing: Text('x$quantity'),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

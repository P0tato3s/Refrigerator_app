import 'package:flutter/material.dart';
import '../data/food_store.dart';
import '../models/food_item.dart';
import '../services/recipe_match_service.dart';

class RecipesPage extends StatefulWidget {
  final FoodStore store;

  const RecipesPage({super.key, required this.store});

  @override
  State<RecipesPage> createState() => _RecipesPageState();
}

class _RecipesPageState extends State<RecipesPage> {
  final TextEditingController searchCtrl = TextEditingController();
  String searchQuery = "";
  String selectedFilter = "All";
  late final Stream<List<FoodItem>> _itemsStream;

  // Cache variables to prevent FutureBuilder from resetting during search/hot reload
  List<FoodItem>? _cachedItems;
  Future<List<MatchedRecipe>>? _cachedRecipesFuture;

  @override
  void initState() {
    super.initState();
    _itemsStream = widget.store.watchItems();
  }

  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }

  void _clearSearch() {
    setState(() {
      searchCtrl.clear();
      searchQuery = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Recipes"),
      ),
      body: StreamBuilder<List<FoodItem>>(
        stream: _itemsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  "Error loading recipes.\n\n${snapshot.error}",
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final items = snapshot.data ?? [];

          // Only generate a new Future if the stream actually gave us new items.
          // This allows our search bar's setState to filter the list in real-time
          // without triggering a loading spinner every time you type a letter!
          if (_cachedItems != items || _cachedRecipesFuture == null) {
            _cachedItems = items;
            _cachedRecipesFuture = RecipeMatchService.attachImages(
              RecipeMatchService.matchRecipes(items),
            );
          }

          return FutureBuilder<List<MatchedRecipe>>(
            future: _cachedRecipesFuture, // Use the cached future
            builder: (context, recipeSnapshot) {
              if (recipeSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (recipeSnapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      "Error loading recipe images.\n\n${recipeSnapshot.error}",
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              final matchedRecipes = recipeSnapshot.data ?? [];

              final filteredRecipes = matchedRecipes.where((recipeMatch) {
                final recipe = recipeMatch.recipe;

                final matchesFilter =
                    selectedFilter == "All" || recipe.category == selectedFilter;

                final q = searchQuery.toLowerCase();
                final matchesSearch = q.isEmpty ||
                    recipe.name.toLowerCase().contains(q) ||
                    recipe.category.toLowerCase().contains(q) ||
                    recipe.ingredients.any(
                          (ingredient) => ingredient.toLowerCase().contains(q),
                    );

                return matchesFilter && matchesSearch;
              }).toList();

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _RecipeSearchBar(
                    controller: searchCtrl,
                    onChanged: (value) {
                      setState(() => searchQuery = value.trim());
                    },
                    onClear: _clearSearch,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 42,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _RecipeFilterChip(
                          label: "All",
                          selected: selectedFilter == "All",
                          onTap: () => setState(() => selectedFilter = "All"),
                        ),
                        const SizedBox(width: 8),
                        _RecipeFilterChip(
                          label: "Breakfast",
                          selected: selectedFilter == "Breakfast",
                          onTap: () =>
                              setState(() => selectedFilter = "Breakfast"),
                        ),
                        const SizedBox(width: 8),
                        _RecipeFilterChip(
                          label: "Lunch",
                          selected: selectedFilter == "Lunch",
                          onTap: () => setState(() => selectedFilter = "Lunch"),
                        ),
                        const SizedBox(width: 8),
                        _RecipeFilterChip(
                          label: "Dinner",
                          selected: selectedFilter == "Dinner",
                          onTap: () => setState(() => selectedFilter = "Dinner"),
                        ),
                        const SizedBox(width: 8),
                        _RecipeFilterChip(
                          label: "Healthy",
                          selected: selectedFilter == "Healthy",
                          onTap: () =>
                              setState(() => selectedFilter = "Healthy"),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    "Recipes Based on Your Fridge",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    items.isEmpty
                        ? "Add ingredients to get recipe recommendations."
                        : "Recommended from what you currently have.",
                    style: const TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 12),
                  if (items.isEmpty)
                    const _EmptyRecipeState(
                      message: "Your fridge is empty. Add food items first.",
                    )
                  else if (filteredRecipes.isEmpty)
                    const _EmptyRecipeState(
                      message:
                      "No matching recipes found for your current search.",
                    )
                  else
                    GridView.builder(
                      itemCount: filteredRecipes.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        childAspectRatio: 0.70,
                      ),
                      itemBuilder: (context, index) {
                        final recipeMatch = filteredRecipes[index];
                        return _RecipeCard(
                          recipeMatch: recipeMatch,
                          onTap: () => _openRecipeDetails(context, recipeMatch),
                        );
                      },
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  void _openRecipeDetails(
      BuildContext context,
      MatchedRecipe recipeMatch,
      ) {
    final recipe = recipeMatch.recipe;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipe.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Chip(label: Text("Match: ${recipeMatch.matchPercent}%")),
                    Chip(label: Text(recipe.time)),
                    Chip(label: Text(recipe.calories)),
                    Chip(label: Text(recipe.category)),
                  ],
                ),
                const SizedBox(height: 18),
                const Text(
                  "Matched Ingredients",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  recipeMatch.matchedIngredients.isEmpty
                      ? "None"
                      : recipeMatch.matchedIngredients.join(", "),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Missing Ingredients",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  recipeMatch.missingIngredients.isEmpty
                      ? "You have everything needed."
                      : recipeMatch.missingIngredients.join(", "),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Steps",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(recipe.steps),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RecipeSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _RecipeSearchBar({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: "Search recipes",
        prefixIcon: const Icon(Icons.search),
        suffixIcon: controller.text.isEmpty
            ? IconButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("More recipe filters coming soon"),
              ),
            );
          },
          icon: const Icon(Icons.tune),
        )
            : IconButton(
          onPressed: onClear,
          icon: const Icon(Icons.close),
        ),
      ),
    );
  }
}

class _RecipeFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RecipeFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}

class _RecipeCard extends StatelessWidget {
  final MatchedRecipe recipeMatch;
  final VoidCallback onTap;

  const _RecipeCard({
    required this.recipeMatch,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final recipe = recipeMatch.recipe;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: recipe.imageUrl != null && recipe.imageUrl!.isNotEmpty
                  ? ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18),
                ),
                child: Image.network(
                  recipe.imageUrl!,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    return _fallbackImage();
                  },
                ),
              )
                  : _fallbackImage(),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Match: ${recipeMatch.matchPercent}%",
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${recipe.time} • ${recipe.calories}",
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fallbackImage() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFF0F0F2),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(18),
        ),
      ),
      child: const Icon(Icons.restaurant_menu, size: 42),
    );
  }
}

class _EmptyRecipeState extends StatelessWidget {
  final String message;

  const _EmptyRecipeState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.restaurant_menu, size: 40),
            const SizedBox(height: 12),
            const Text(
              "No recipes found",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
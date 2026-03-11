import 'package:flutter/material.dart';

class RecipesPage extends StatelessWidget {
  const RecipesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final recipes = [
      {
        "name": "Egg Fried Rice",
        "match": "90%",
        "time": "15 min",
        "calories": "420 cal",
      },
      {
        "name": "Chicken Salad",
        "match": "80%",
        "time": "20 min",
        "calories": "350 cal",
      },
      {
        "name": "Strawberry Yogurt Bowl",
        "match": "95%",
        "time": "5 min",
        "calories": "210 cal",
      },
      {
        "name": "Spinach Omelette",
        "match": "85%",
        "time": "10 min",
        "calories": "300 cal",
      },
      {
        "name": "Milk Smoothie",
        "match": "75%",
        "time": "8 min",
        "calories": "250 cal",
      },
      {
        "name": "Pasta",
        "match": "70%",
        "time": "25 min",
        "calories": "500 cal",
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Recipes"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: "Search recipes",
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.tune),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: const [
                _RecipeFilterChip(label: "All", selected: true),
                SizedBox(width: 8),
                _RecipeFilterChip(label: "Breakfast"),
                SizedBox(width: 8),
                _RecipeFilterChip(label: "Lunch"),
                SizedBox(width: 8),
                _RecipeFilterChip(label: "Dinner"),
                SizedBox(width: 8),
                _RecipeFilterChip(label: "Healthy"),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            "Recommended Recipes",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            itemCount: recipes.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 0.74,
            ),
            itemBuilder: (context, index) {
              final recipe = recipes[index];

              return _RecipeCard(
                name: recipe["name"]!,
                match: recipe["match"]!,
                time: recipe["time"]!,
                calories: recipe["calories"]!,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _RecipeFilterChip extends StatelessWidget {
  final String label;
  final bool selected;

  const _RecipeFilterChip({
    required this.label,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) {},
    );
  }
}

class _RecipeCard extends StatelessWidget {
  final String name;
  final String match;
  final String time;
  final String calories;

  const _RecipeCard({
    required this.name,
    required this.match,
    required this.time,
    required this.calories,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFF0F0F2),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(18),
                  ),
                ),
                child: const Icon(
                  Icons.restaurant_menu,
                  size: 42,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Match: $match",
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "$time • $calories",
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
}
import 'package:flutter/material.dart';

class RecipesPage extends StatelessWidget {
  const RecipesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final recipes = [
      "Egg Fried Rice",
      "Chicken Salad",
      "Strawberry Yogurt Bowl",
      "Spinach Omelette",
      "Milk Smoothie",
      "Pasta",
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Recipes")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: recipes.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 0.85,
          ),
          itemBuilder: (context, i) => Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F0F2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.image_outlined, size: 42),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    recipes[i],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  const Text("Match: 80%", style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
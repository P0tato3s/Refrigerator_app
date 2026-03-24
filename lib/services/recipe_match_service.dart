import '../models/food_item.dart';
import '../models/recipe_item.dart';
import '../data/recipe_seed.dart';
import 'image_service.dart';

class MatchedRecipe {
  final RecipeItem recipe;
  final int matchPercent;
  final List<String> matchedIngredients;
  final List<String> missingIngredients;

  const MatchedRecipe({
    required this.recipe,
    required this.matchPercent,
    required this.matchedIngredients,
    required this.missingIngredients,
  });
}

class RecipeMatchService {
  static String _normalize(String value) {
    return value.trim().toLowerCase();
  }

  static List<MatchedRecipe> matchRecipes(List<FoodItem> fridgeItems) {
    final fridgeSet = fridgeItems
        .map((e) => _normalize(e.name))
        .where((e) => e.isNotEmpty)
        .toSet();

    final matches = recipeSeed.map((recipe) {
      final recipeIngredients = recipe.ingredients.map(_normalize).toList();

      final matched = recipeIngredients
          .where((ingredient) => fridgeSet.contains(ingredient))
          .toList();

      final missing = recipeIngredients
          .where((ingredient) => !fridgeSet.contains(ingredient))
          .toList();

      final percent =
      ((matched.length / recipeIngredients.length) * 100).round();

      return MatchedRecipe(
        recipe: recipe,
        matchPercent: percent,
        matchedIngredients: matched,
        missingIngredients: missing,
      );
    }).where((match) => match.matchPercent > 0).toList();

    matches.sort((a, b) {
      final scoreCompare = b.matchPercent.compareTo(a.matchPercent);
      if (scoreCompare != 0) return scoreCompare;
      return a.recipe.name.compareTo(b.recipe.name);
    });

    return matches;
  }

  static Future<List<MatchedRecipe>> attachImages(
      List<MatchedRecipe> matches,
      ) async {
    final results = <MatchedRecipe>[];

    for (final match in matches) {
      String? imageUrl = match.recipe.imageUrl;

      imageUrl ??= await ImageService.fetchFoodImage(match.recipe.name);

      results.add(
        MatchedRecipe(
          recipe: match.recipe.copyWith(imageUrl: imageUrl),
          matchPercent: match.matchPercent,
          matchedIngredients: match.matchedIngredients,
          missingIngredients: match.missingIngredients,
        ),
      );
    }

    return results;
  }
}
import 'package:flutter/material.dart';
import '../models/food_item.dart';
import '../data/food_store.dart';
import '../services/auth_service.dart';

import 'add_item_page.dart';
import 'inventory_page.dart';
import 'recipes_page.dart';
import 'item_detail_page.dart';

class HomePage extends StatefulWidget {
  final FoodStore store;

  const HomePage({super.key, required this.store});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int navIndex = 0;
  String selectedCategory = "All";
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: navIndex,
        children: [
          StreamBuilder<List<FoodItem>>(
            stream: widget.store.watchItems(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SafeArea(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasError) {
                return SafeArea(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        "Error loading items:\n${snapshot.error}",
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                );
              }

              final items = snapshot.data ?? [];

              final categories = <String>{
                "All",
                ...items.map((e) => e.category),
              }.toList();

              return _HomeTab(
                store: widget.store,
                items: items,
                categories: categories,
                selectedCategory: selectedCategory,
                searchQuery: searchQuery,
                onSelectCategory: (c) => setState(() => selectedCategory = c),
                onSearchChanged: (value) =>
                    setState(() => searchQuery = value.trim()),
                onOpenInventory: () => setState(() => navIndex = 1),
              );
            },
          ),
          InventoryPage(store: widget.store),
          const RecipesPage(),
          const _ProfilePlaceholderPage(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddItemPage(store: widget.store),
          ),
        ),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        height: 64,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavIcon(
              icon: Icons.home_outlined,
              selectedIcon: Icons.home,
              selected: navIndex == 0,
              onTap: () => setState(() => navIndex = 0),
            ),
            _NavIcon(
              icon: Icons.list_alt_outlined,
              selectedIcon: Icons.list_alt,
              selected: navIndex == 1,
              onTap: () => setState(() => navIndex = 1),
            ),
            const SizedBox(width: 38),
            _NavIcon(
              icon: Icons.restaurant_menu_outlined,
              selectedIcon: Icons.restaurant_menu,
              selected: navIndex == 2,
              onTap: () => setState(() => navIndex = 2),
            ),
            _NavIcon(
              icon: Icons.person_outline,
              selectedIcon: Icons.person,
              selected: navIndex == 3,
              onTap: () => setState(() => navIndex = 3),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  final FoodStore store;
  final List<FoodItem> items;
  final List<String> categories;
  final String selectedCategory;
  final String searchQuery;
  final ValueChanged<String> onSelectCategory;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onOpenInventory;

  const _HomeTab({
    required this.store,
    required this.items,
    required this.categories,
    required this.selectedCategory,
    required this.searchQuery,
    required this.onSelectCategory,
    required this.onSearchChanged,
    required this.onOpenInventory,
  });

  @override
  Widget build(BuildContext context) {
    final filtered = items.where((item) {
      final matchesCategory =
          selectedCategory == "All" || item.category == selectedCategory;

      final matchesSearch = searchQuery.isEmpty ||
          item.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          item.category.toLowerCase().contains(searchQuery.toLowerCase());

      return matchesCategory && matchesSearch;
    }).toList();

    return SafeArea(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _Header(
            title: "My Fridge",
            subtitle: "What are we cooking today?",
            onProfile: () {},
            onBell: () {},
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: _SearchBar(
              hint: "Search items",
              onChanged: onSearchChanged,
            ),
          ),
          SizedBox(
            height: 46,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final c = categories[index];
                final isSelected = c == selectedCategory;

                return ChoiceChip(
                  label: Text(c),
                  selected: isSelected,
                  onSelected: (_) => onSelectCategory(c),
                );
              },
              separatorBuilder: (context, index) =>
              const SizedBox(width: 10),
              itemCount: categories.length,
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    searchQuery.isEmpty ? "Inventory" : "Results",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: onOpenInventory,
                  child: const Text("See all"),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 90),
            child: filtered.isEmpty
                ? const _EmptyState()
                : GridView.builder(
              itemCount: filtered.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.78,
              ),
              itemBuilder: (context, index) => FoodCard(
                item: filtered[index],
                store: store,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onProfile;
  final VoidCallback onBell;

  const _Header({
    required this.title,
    required this.subtitle,
    required this.onProfile,
    required this.onBell,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: const BoxDecoration(
        color: Color(0xFFDCE9E2),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(26),
          bottomRight: Radius.circular(26),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onProfile,
            child: const CircleAvatar(radius: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 13)),
              ],
            ),
          ),
          IconButton(
            onPressed: onBell,
            icon: const Icon(Icons.notifications_none),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final String hint;
  final ValueChanged<String> onChanged;

  const _SearchBar({
    required this.hint,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.tune),
        ),
      ),
    );
  }
}

class FoodCard extends StatelessWidget {
  final FoodItem item;
  final FoodStore store;

  const FoodCard({
    super.key,
    required this.item,
    required this.store,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final days = item.daysUntilExpiry(now);

    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ItemDetailPage(
            item: item,
            store: store,
          ),
        ),
      ),
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18),
                ),
                child: item.photoUrl != null && item.photoUrl!.isNotEmpty
                    ? Image.network(
                  item.photoUrl!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: const Color(0xFFF0F0F2),
                      child: const Center(
                        child: Icon(Icons.image_outlined, size: 42),
                      ),
                    );
                  },
                )
                    : Container(
                  color: const Color(0xFFF0F0F2),
                  child: const Center(
                    child: Icon(Icons.image_outlined, size: 42),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "${item.quantity} ${item.unit} • ${item.category}",
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 10),
                  _ExpiryPill(daysUntil: days),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpiryPill extends StatelessWidget {
  final int daysUntil;

  const _ExpiryPill({required this.daysUntil});

  @override
  Widget build(BuildContext context) {
    String text;
    IconData icon;

    if (daysUntil < 0) {
      text = "Expired";
      icon = Icons.error_outline;
    } else if (daysUntil <= 3) {
      text = "Soon ($daysUntil d)";
      icon = Icons.timer_outlined;
    } else {
      text = "Fresh";
      icon = Icons.check_circle_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F9),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final bool selected;
  final VoidCallback onTap;

  const _NavIcon({
    required this.icon,
    required this.selectedIcon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(selected ? selectedIcon : icon),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: const [
            Icon(Icons.kitchen_outlined, size: 40),
            SizedBox(height: 12),
            Text(
              "No items found.",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 6),
            Text(
              "Try another category or add a new item with the + button.",
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfilePlaceholderPage extends StatelessWidget {
  const _ProfilePlaceholderPage();

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    final user = auth.currentUser;

    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person_outline, size: 72),
              const SizedBox(height: 16),
              const Text(
                'Profile',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                user?.email ?? 'No email found',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () async {
                  await auth.signOut();
                },
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
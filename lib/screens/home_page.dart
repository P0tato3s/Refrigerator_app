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
        elevation: 3,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddItemPage(store: widget.store),
          ),
        ),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: navIndex,
        onDestinationSelected: (index) {
          setState(() => navIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: "Home",
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: "Inventory",
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu_outlined),
            selectedIcon: Icon(Icons.restaurant_menu),
            label: "Recipes",
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
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

    final expiringSoon =
        items.where((item) => item.daysUntilExpiry(DateTime.now()) <= 3).length;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        children: [
          _Header(
            totalItems: items.length,
            expiringSoon: expiringSoon,
          ),
          const SizedBox(height: 18),
          _SearchBar(
            hint: "Search items",
            onChanged: onSearchChanged,
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 42,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (context, index) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final c = categories[index];
                final isSelected = c == selectedCategory;

                return ChoiceChip(
                  label: Text(c),
                  selected: isSelected,
                  onSelected: (_) => onSelectCategory(c),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Text(
                  searchQuery.isEmpty ? "My Inventory" : "Search Results",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              TextButton(
                onPressed: onOpenInventory,
                child: const Text("See all"),
              ),
            ],
          ),
          const SizedBox(height: 12),
          filtered.isEmpty
              ? const _EmptyState()
              : GridView.builder(
            itemCount: filtered.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.72,
            ),
            itemBuilder: (context, index) => FoodCard(
              item: filtered[index],
              store: store,
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final int totalItems;
  final int expiringSoon;

  const _Header({
    required this.totalItems,
    required this.expiringSoon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFDFF3E8),
            Color(0xFFCDEBDA),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.kitchen_outlined, size: 26),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "My Fridge",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Track freshness and cook smarter",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.notifications_none),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: "Items",
                  value: "$totalItems",
                  icon: Icons.inventory_2_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  label: "Expiring Soon",
                  value: "$expiringSoon",
                  icon: Icons.schedule_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, size: 22),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
            ],
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
        suffixIcon: Container(
          margin: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F2F4),
            borderRadius: BorderRadius.circular(14),
          ),
          child: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.tune),
          ),
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
    final days = item.daysUntilExpiry(DateTime.now());

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ItemDetailPage(
            item: item,
            store: store,
          ),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 6,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(22),
                ),
                child: item.photoUrl != null && item.photoUrl!.isNotEmpty
                    ? Image.network(
                  item.photoUrl!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (_, __, ___) => _imageFallback(),
                )
                    : _imageFallback(),
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${item.quantity} ${item.unit} • ${item.category}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                    const Spacer(),
                    _ExpiryBadge(daysUntil: days),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageFallback() {
    return Container(
      color: const Color(0xFFF1F3F5),
      child: const Center(
        child: Icon(Icons.fastfood_outlined, size: 38),
      ),
    );
  }
}

class _ExpiryBadge extends StatelessWidget {
  final int daysUntil;

  const _ExpiryBadge({required this.daysUntil});

  @override
  Widget build(BuildContext context) {
    String text;
    Color bg;
    Color fg;
    IconData icon;

    if (daysUntil < 0) {
      text = "Expired";
      bg = const Color(0xFFFFE5E5);
      fg = const Color(0xFFC62828);
      icon = Icons.error_outline;
    } else if (daysUntil <= 3) {
      text = "$daysUntil d left";
      bg = const Color(0xFFFFF0D9);
      fg = const Color(0xFFB26A00);
      icon = Icons.schedule_outlined;
    } else {
      text = "Fresh";
      bg = const Color(0xFFE3F6EA);
      fg = const Color(0xFF2E7D32);
      icon = Icons.check_circle_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: fg),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Column(
        children: [
          Icon(Icons.kitchen_outlined, size: 42),
          SizedBox(height: 12),
          Text(
            "No items found",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Try another category or add a new item with the + button.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54),
          ),
        ],
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircleAvatar(
                  radius: 34,
                  child: Icon(Icons.person_outline, size: 34),
                ),
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
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
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
      ),
    );
  }
}
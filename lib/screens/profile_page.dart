import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/food_store.dart';
import '../models/food_item.dart';
import '../services/auth_service.dart';

class ProfilePage extends StatefulWidget {
  final FoodStore store;

  const ProfilePage({
    super.key,
    required this.store,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final Stream<List<FoodItem>> _itemsStream;

  bool expiryAlertsEnabled = true;
  bool recipeSuggestionsEnabled = true;
  bool categoryHintsEnabled = true;

  static const List<String> supportedCategories = [
    "Produce",
    "Dairy",
    "Meat",
    "Seafood",
    "Grains",
    "Bakery",
    "Frozen",
    "Canned",
    "Condiments",
    "Snacks",
    "Drinks",
    "Spices",
    "Prepared Meals",
    "Desserts",
    "Other",
  ];

  static const List<String> supportedUnits = [
    "pcs",
    "box",
    "bag",
    "carton",
    "bottle",
    "can",
    "jar",
    "pack",
    "lbs",
    "oz",
    "g",
    "kg",
    "ml",
    "L",
    "cups",
  ];

  @override
  void initState() {
    super.initState();
    _itemsStream = widget.store.watchItems();
  }

  Future<void> _showEmailDialog(String email) async {
    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Account Email"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("This account is currently signed in with:"),
              const SizedBox(height: 12),
              SelectableText(
                email,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: email));
                if (!mounted) return;

                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Email copied")),
                );
              },
              child: const Text("Copy"),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Done"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _sendPasswordReset(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Password reset email sent to $email")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not send reset email: $e")),
      );
    }
  }

  Future<void> _showPasswordDialog(String email) async {
    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Reset Password"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "We will send a password reset link to:",
              ),
              const SizedBox(height: 12),
              Text(
                email,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Cancel"),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.pop(dialogContext);

                try {
                  await FirebaseAuth.instance
                      .sendPasswordResetEmail(email: email);

                  if (!mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Password reset email sent"),
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Error: $e"),
                    ),
                  );
                }
              },
              child: const Text("Send Email"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showNotificationSettings() async {
    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Notification Settings",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text("Expiry Alerts"),
                    subtitle: const Text(
                      "Warn when food is expiring soon",
                    ),
                    value: expiryAlertsEnabled,
                    onChanged: (value) {
                      setSheetState(() => expiryAlertsEnabled = value);
                      setState(() => expiryAlertsEnabled = value);
                    },
                  ),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Notification settings updated"),
                        ),
                      );
                    },
                    child: const Text("Save"),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showRecipePreferences() async {
    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Recipe Recommendations",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text("Enable Suggestions"),
                    subtitle: const Text(
                      "Recommend recipes based on your fridge items",
                    ),
                    value: recipeSuggestionsEnabled,
                    onChanged: (value) {
                      setSheetState(() => recipeSuggestionsEnabled = value);
                      setState(() => recipeSuggestionsEnabled = value);
                    },
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Current behavior:",
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Recipes are matched from ingredients you already have, and ranked by match percentage.",
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Recipe preferences updated"),
                        ),
                      );
                    },
                    child: const Text("Save"),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showCategoriesAndUnits() async {
    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Categories & Units"),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text("Category Hints"),
                    subtitle: const Text(
                      "Show structured organization options in forms",
                    ),
                    value: categoryHintsEnabled,
                    onChanged: (value) {
                      setState(() => categoryHintsEnabled = value);
                      Navigator.pop(dialogContext);
                      _showCategoriesAndUnits();
                    },
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Supported Categories",
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: supportedCategories
                        .map((c) => Chip(label: Text(c)))
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Supported Units",
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: supportedUnits
                        .map((u) => Chip(label: Text(u)))
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Done"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAboutDialog() async {
    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("About This App"),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Refrigerator App",
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 8),
              Text("Version: 1.0.0 Demo"),
              SizedBox(height: 8),
              Text(
                "Features:\n"
                    "• Multi-user login\n"
                    "• Fridge inventory tracking\n"
                    "• Expiration status\n"
                    "• Recipe recommendations based on your fridge\n"
                    "• Image previews from API",
              ),
            ],
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    final user = auth.currentUser;
    final email = user?.email ?? "No email found";
    final displayName = email.contains('@') ? email.split('@').first : email;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
      ),
      body: StreamBuilder<List<FoodItem>>(
        stream: _itemsStream,
        builder: (context, snapshot) {
          final items = snapshot.data ?? [];

          final expiringSoon = items
              .where((item) {
            final days = item.daysUntilExpiry(DateTime.now());
            return days >= 0 && days <= 3;
          })
              .length;

          final expired = items
              .where((item) => item.daysUntilExpiry(DateTime.now()) < 0)
              .length;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
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
                    const CircleAvatar(
                      radius: 38,
                      child: Icon(Icons.person_outline, size: 36),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      email,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      alignment: WrapAlignment.center,
                      children: const [
                        _ProfileTag(label: "Fridge Tracker"),
                        _ProfileTag(label: "Recipe Matching"),
                        _ProfileTag(label: "Expiry Alerts"),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _ProfileStatCard(
                      label: "Items",
                      value: items.length.toString(),
                      icon: Icons.inventory_2_outlined,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ProfileStatCard(
                      label: "Soon",
                      value: expiringSoon.toString(),
                      icon: Icons.schedule_outlined,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ProfileStatCard(
                      label: "Expired",
                      value: expired.toString(),
                      icon: Icons.error_outline,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const _SectionTitle("Account"),
              const SizedBox(height: 10),
              _ProfileTile(
                icon: Icons.email_outlined,
                title: "Email",
                subtitle: email,
                onTap: () => _showEmailDialog(email),
              ),
              _ProfileTile(
                icon: Icons.lock_outline,
                title: "Password",
                subtitle: "Send a password reset email",
                onTap: () => _showPasswordDialog(email),
              ),
              const SizedBox(height: 20),
              const _SectionTitle("Preferences"),
              const SizedBox(height: 10),
              _ProfileTile(
                icon: Icons.notifications_none,
                title: "Notifications",
                subtitle: expiryAlertsEnabled
                    ? "Expiry alerts enabled"
                    : "Expiry alerts disabled",
                onTap: _showNotificationSettings,
              ),
              _ProfileTile(
                icon: Icons.restaurant_menu_outlined,
                title: "Recipe Recommendations",
                subtitle: recipeSuggestionsEnabled
                    ? "Smart suggestions enabled"
                    : "Smart suggestions disabled",
                onTap: _showRecipePreferences,
              ),
              _ProfileTile(
                icon: Icons.category_outlined,
                title: "Categories & Units",
                subtitle: "View supported organization options",
                onTap: _showCategoriesAndUnits,
              ),
              const SizedBox(height: 20),
              const _SectionTitle("About"),
              const SizedBox(height: 10),
              _ProfileTile(
                icon: Icons.info_outline,
                title: "App Details",
                subtitle: "Version, features, and project summary",
                onTap: _showAboutDialog,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () async {
                  await auth.signOut();
                },
                icon: const Icon(Icons.logout),
                label: const Text("Logout"),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _ProfileTag extends StatelessWidget {
  final String label;

  const _ProfileTag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ProfileStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _ProfileStatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(icon),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
import 'dart:ui' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() => runApp(const FoodApp());

// ---------- Mouse drag scroll enable (web/desktop preview fix) ----------
class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };
}

// ---------- Model ----------
class Food {
  final String name, desc, image, emoji, category;
  final double price, rating;
  const Food(this.name, this.desc, this.image, this.emoji, this.category,
      this.price, this.rating);
}

String _u(String id) =>
    'https://images.unsplash.com/photo-$id?auto=format&fit=crop&w=600&q=70';

final List<Food> foods = [
  Food('Beef Burger', 'Juicy beef patty with cheese, lettuce and special sauce',
      _u('1568901346375-23c9450c58cd'), '🍔', 'Fast Food', 250, 4.5),
  Food('Pepperoni Pizza', 'Wood-fired crust with mozzarella and pepperoni',
      _u('1513104890138-7c749659a591'), '🍕', 'Fast Food', 480, 4.7),
  Food('Chicken Biryani', 'Aromatic basmati rice cooked with spiced chicken',
      _u('1563379091339-03b21ab4a4f8'), '🍛', 'Rice & Noodles', 220, 4.8),
  Food('Creamy Pasta', 'Italian pasta in rich white sauce with herbs',
      _u('1621996346565-e3dbc646d9a9'), '🍝', 'Fast Food', 320, 4.3),
  Food('Fried Chicken', 'Crispy golden chicken with secret spice mix',
      _u('1626645738196-c2a7c87a8f58'), '🍗', 'Fast Food', 280, 4.4),
  Food('Salmon Sushi', 'Fresh salmon rolls served with soy and wasabi',
      _u('1579871494447-9811cf80d66c'), '🍣', 'Healthy', 550, 4.6),
  Food('Street Tacos', 'Soft tortillas with grilled meat and fresh salsa',
      _u('1565299585323-38d6b0865b47'), '🌮', 'Fast Food', 260, 4.2),
  Food('Green Salad', 'Fresh greens, cherry tomato, olives and dressing',
      _u('1512621776951-a57141f2eefd'), '🥗', 'Healthy', 180, 4.1),
  Food('Chowmein Noodles', 'Stir-fried noodles with vegetables and chicken',
      _u('1569718212165-3a8278d5f624'), '🍜', 'Rice & Noodles', 200, 4.4),
  Food('Club Sandwich', 'Triple-layer toasted sandwich with egg and chicken',
      _u('1528735602780-2552fd46c7af'), '🥪', 'Fast Food', 190, 4.0),
];

// ---------- App + Theme ----------
class FoodApp extends StatefulWidget {
  const FoodApp({super.key});
  @override
  State<FoodApp> createState() => _FoodAppState();
}

class _FoodAppState extends State<FoodApp> {
  bool isDark = false;

  ThemeData _buildTheme(Brightness b) {
    final isLight = b == Brightness.light;
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFFFF6B35), // primary color
      brightness: b,
    );
    final base = ThemeData(
      useMaterial3: true,
      brightness: b,
      colorScheme: scheme,
      scaffoldBackgroundColor:
          isLight ? const Color(0xFFFFF8F3) : const Color(0xFF121212),
    );
    // custom font + text styles
    final text = GoogleFonts.poppinsTextTheme(base.textTheme);
    return base.copyWith(
      textTheme: text.copyWith(
        titleMedium: text.titleMedium
            ?.copyWith(fontSize: 16, fontWeight: FontWeight.w600),
        bodyMedium: text.bodyMedium?.copyWith(fontSize: 14),
        bodySmall: text.bodySmall?.copyWith(fontSize: 12),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor:
            isLight ? const Color(0xFFFF6B35) : const Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
            fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Food Menu',
      scrollBehavior: AppScrollBehavior(),
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home: FoodMenuScreen(
        isDark: isDark,
        onToggle: () => setState(() => isDark = !isDark),
      ),
    );
  }
}

// ---------- Screen ----------
class FoodMenuScreen extends StatefulWidget {
  final bool isDark;
  final VoidCallback onToggle;
  const FoodMenuScreen(
      {super.key, required this.isDark, required this.onToggle});

  @override
  State<FoodMenuScreen> createState() => _FoodMenuScreenState();
}

class _FoodMenuScreenState extends State<FoodMenuScreen> {
  static const cats = ['All', 'Fast Food', 'Rice & Noodles', 'Healthy'];
  String selected = 'All';

  List<Food> get items => selected == 'All'
      ? foods
      : foods.where((f) => f.category == selected).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Menu'),
        actions: [
          IconButton(
            tooltip: 'Switch theme',
            icon: Icon(widget.isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.onToggle,
          ),
        ],
      ),
      body: Column(
        children: [
          // category chips
          SizedBox(
            height: 56,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              itemCount: cats.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) => ChoiceChip(
                label: Text(cats[i]),
                selected: selected == cats[i],
                onSelected: (_) => setState(() => selected = cats[i]),
              ),
            ),
          ),
          // responsive list / grid
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final list = items;
                if (width >= 600) {
                  // wide screen -> GridView
                  final cols = (width / 240).floor().clamp(2, 5);
                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
                    itemCount: list.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: cols,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.8,
                    ),
                    itemBuilder: (_, i) =>
                        FoodCard(food: list[i], isGrid: true),
                  );
                }
                // phone -> ListView
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
                  itemCount: list.length,
                  itemBuilder: (_, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SizedBox(
                      height: 150,
                      child: FoodCard(food: list[i], isGrid: false),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- Reusable custom widget ----------
class FoodCard extends StatelessWidget {
  final Food food;
  final bool isGrid;
  const FoodCard({super.key, required this.food, required this.isGrid});

  // fallback when image is loading / fails
  Widget _placeholder(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [c.primaryContainer, c.secondaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      alignment: Alignment.center,
      child: Text(food.emoji, style: const TextStyle(fontSize: 44)),
    );
  }

  Widget _image(BuildContext context) => Image.network(
        food.image,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        loadingBuilder: (ctx, child, progress) =>
            progress == null ? child : _placeholder(context),
        errorBuilder: (ctx, e, s) => _placeholder(context),
      );

  Widget _ratingBadge() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.65),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 14),
            const SizedBox(width: 3),
            Text(
              food.rating.toStringAsFixed(1),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );

  Widget _priceRow(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return Row(
      children: [
        Text(
          'Tk ${food.price.toStringAsFixed(0)}',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(color: c.primary, fontWeight: FontWeight.w700),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('${food.name} added to cart'),
              duration: const Duration(seconds: 1),
            ));
          },
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(color: c.primary, shape: BoxShape.circle),
            child: Icon(Icons.add, size: 20, color: c.onPrimary),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    // info for GRID card
    final gridInfo = Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(food.name,
              style: t.titleMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 6),
          _priceRow(context),
        ],
      ),
    );

    // info for LIST card
    final listInfo = Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(food.name,
                  style: t.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Text(food.desc,
                  style: t.bodySmall?.copyWith(color: Colors.grey),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
            ],
          ),
          _priceRow(context),
        ],
      ),
    );

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: isGrid
          // Grid: image on top (Stack + rating badge), info below
          ? Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(child: _image(context)),
                      Positioned(top: 8, right: 8, child: _ratingBadge()),
                    ],
                  ),
                ),
                gridInfo,
              ],
            )
          // List: image left (Stack + rating badge), info right
          : Row(
              children: [
                SizedBox(
                  width: 130,
                  child: Stack(
                    children: [
                      Positioned.fill(child: _image(context)),
                      Positioned(top: 8, left: 8, child: _ratingBadge()),
                    ],
                  ),
                ),
                Expanded(child: listInfo),
              ],
            ),
    );
  }
}

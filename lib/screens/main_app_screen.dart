import 'package:flutter/material.dart';
import '../main.dart';

// === SCREEN UTAMA ===
import 'home_screen.dart';
import 'shopping_cart_screen.dart';
import 'wishlist_screen.dart';
import 'profile_screen.dart';

// === CRUD PRODUCT ===
import 'product_list_screen.dart';

class MainAppScreen extends StatefulWidget {
  final int? initialIndex;

  const MainAppScreen({super.key, this.initialIndex});

  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {
  late int _selectedIndex;

  // =======================
  // DAFTAR HALAMAN (TAB)
  // =======================
  static const List<Widget> _pages = <Widget>[
    HomeScreen(),            // 0 - Home
    ProductListScreen(),     // 1 - PRODUCTS (CRUD)
    ShoppingCartScreen(),    // 2 - Cart
    WishlistScreen(),        // 3 - Wishlist
    ProfileScreen(),         // 4 - Profile
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex ?? 0;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],

      // =======================
      // BOTTOM NAVIGATION BAR
      // =======================
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: kPrimaryColor,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: _onItemTapped,

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),

          // ===== CRUD PRODUCT TAB =====
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            activeIcon: Icon(Icons.inventory_2),
            label: 'Products',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            activeIcon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            activeIcon: Icon(Icons.favorite),
            label: 'Wishlist',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

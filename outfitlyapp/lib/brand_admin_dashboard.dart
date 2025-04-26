import 'package:flutter/material.dart';
import 'brand_admin_products.dart';
import 'brand_admin_sales.dart';
import 'brand_admin_menu.dart';

class BrandAdminDashboard extends StatefulWidget {
  const BrandAdminDashboard({Key? key}) : super(key: key);

  @override
  State<BrandAdminDashboard> createState() => _BrandAdminDashboardState();
}

class _BrandAdminDashboardState extends State<BrandAdminDashboard> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    const BrandAdminProducts(),
    const BrandAdminSales(),
    const BrandAdminMenu(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/images/logo.jpeg', height: 40),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Products',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Sales'),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Menu'),
        ],
      ),
    );
  }
}

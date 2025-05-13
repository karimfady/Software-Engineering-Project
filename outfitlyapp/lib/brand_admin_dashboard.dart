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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Outfitly Vendor',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color(0xff041511),
          ),
        ),
        centerTitle: true,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: Color(0xff041511),
        unselectedItemColor: Color(0xff041511).withOpacity(0.5),
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

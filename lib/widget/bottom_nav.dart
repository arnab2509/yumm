import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:yumm/view/home.dart';
import 'package:yumm/view/myorderspage.dart';
import 'package:yumm/view/order.dart';
import 'package:yumm/view/profile.dart';
import 'package:yumm/view/wallet.dart';
class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _currentTabIndex = 0;
  late List<Widget> _pages;
  late Widget _currentPage;
  late Home _homePage;
  late Profile _profilePage;
  late MyOrdersPage _myOrdersPage;
  late Order _orderPage;

  @override
  void initState() {
    _homePage = const Home();
    _profilePage = const Profile(); 
    _myOrdersPage = const MyOrdersPage();
    _orderPage = const Order();
    _pages = [_homePage, _orderPage, _myOrdersPage, _profilePage];
    // _currentPage = _homePage;
    super.initState();

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(bottomNavigationBar: SafeArea(
        bottom: true,
  top: false,
  left: false,
  right: false,
      child: CurvedNavigationBar(
        height: MediaQuery.of(context).size.height / 14,
        color: Colors.deepOrange,
        backgroundColor: Colors.transparent,
        animationDuration: const Duration(milliseconds: 500),
        
        onTap: (int index) {
          setState(() {
            _currentTabIndex = index;
          
          });
          
        },
        items: [
        const Icon(Icons.home, size: 30, color: Color.fromARGB(255, 255, 255, 255)),
        const Icon(Icons.shopping_cart, size: 30, color: Color.fromARGB(255, 255, 255, 255)),
        const Icon(Icons.food_bank, size: 30, color: Color.fromARGB(255, 255, 255, 255)),
        const Icon(Icons.person, size: 30, color: Color.fromARGB(255, 255, 255, 255) ),
      ],  ),
    ),
    body: _pages[_currentTabIndex], // Display the current page based on the index
    );
  }
}
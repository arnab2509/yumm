import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:yumm/admin/add_food.dart';
import 'package:yumm/admin/admin_order.dart';
import 'package:yumm/admin/viewitem.dart';

class Adminnavbar extends StatefulWidget {
  const Adminnavbar({super.key});

  @override
  State<Adminnavbar> createState() => _AdminnavbarState();
}

class _AdminnavbarState extends State<Adminnavbar> {


  int currentTabIndex = 0;

  late List<Widget> pages;
  late Widget currentPage;
  late AddFood addItem;
  late Viewitem viewitem;
  late AdminOrder adminOrder;
  // late Payment payment;
//  late Adminorder AdminOrder;

  @override
  void initState() {
    addItem = AddFood();
    viewitem = Viewitem();
   // addItem = UserDashbord();
    adminOrder = AdminOrder();
    pages = [ viewitem,addItem,adminOrder];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      // appBar: AppBar(
        
      // ),
        
      // extendBody: true,

        bottomNavigationBar: CurvedNavigationBar(
         height: MediaQuery.of(context).size.height / 14,
      color: Colors.deepOrange,
      backgroundColor: Colors.transparent,
      animationDuration: const Duration(milliseconds: 500),
          onTap: (int index) {
            setState(() {
              currentTabIndex = index;
            });
          },
          items:  [
          
            Icon(
              Icons.food_bank_outlined,
              size: 30, color: Color.fromARGB(255, 255, 255, 255)
            ),
             Icon(Icons.rice_bowl_outlined,size: 30, color: Color.fromARGB(255, 255, 255, 255)),
             Icon(Icons.food_bank_rounded,size: 30, color: Color.fromARGB(255, 255, 255, 255)),

            // Icon(
            //   Icons.payment_outlined,
            //   color: Colors.white,
            // ),
            // Icon(
            //   Icons.person_outline,
            //   color: Colors.white,
            // )
          ],
          ),
      body: pages[currentTabIndex], 
    );
  }
}

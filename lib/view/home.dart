import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:yumm/Authentication/userlogin.dart';
import 'package:yumm/service/auth.dart';
import 'package:yumm/service/shared_pref.dart';
import 'package:yumm/view/details.dart';
import 'package:yumm/widget/widget_support.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool biriyani = false, pizza = false, chicken = false, icecream = false, burger = false;
  Stream? fooditemStream;
  String selectedCategory = "Biriyani";
  
  ontheload() async {
    fooditemStream = await getFoodItem("Biriyani");
    biriyani = true;
    setState(() {});
  }

  @override
  void initState() {
    ontheload();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.only(
            top: MediaQuery.of(context).size.height * 0.02,
            left: MediaQuery.of(context).size.width * 0.05,
            right: MediaQuery.of(context).size.width * 0.05,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Welcome Arnab', 
                    style: AppWidget.getPlaywriteOrangeTitleTextStyle(),
                  ),
                  GestureDetector(
                    onTap: () {
                      showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          backgroundColor: Color.fromARGB(255, 237, 237, 237),
          title: Text('Logout',style: AppWidget.getPlayLargeOrangeTextStyle(),),
          content: Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {

                Navigator.pop(context);
                _logout();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
              child: Text('Logout', style: TextStyle(color: Colors.white)),
            ),
          ],
        );});
                    },
                    child: Material(
                      elevation: 3,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.deepOrange,
                          borderRadius: BorderRadius.circular(10)
                        ),
                        child: Icon(Icons.logout_rounded, color: Colors.white),
                      ),
                    ),
                  )
                ],
              ),
              Text('Delicious Food', 
                style: AppWidget.getPoppinsOrangeHeaderTextStyle(),
              ),
              SizedBox(height: 5.h),
              Text('Find the best food around you', 
                style: AppWidget.getPoppinsOrangeLightTextStyle()
              ),
              SizedBox(height: 20.h),
              ShowItem(),
              SizedBox(height: 10.h),
              Expanded(
                child: StreamBuilder(
                  stream: fooditemStream,
                  builder: (context, AsyncSnapshot snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error loading items: ${snapshot.error}',
                          style: TextStyle(color: Colors.red),
                        ),
                      );
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.deepOrange),
                        ),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data.docs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.restaurant_menu,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No items found in $selectedCategory',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                                // fontWeight: FontWeight.500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: snapshot.data.docs.map<Widget>((doc) {
                              return FoodRow(doc);
                            }).toList(),
                          ),
                        ),
                        SizedBox(height: 25.h),
                        ...snapshot.data.docs.map<Widget>((doc) {
                          return Column(
                            children: [
                              FoodColumn(doc),
                              SizedBox(height: 20.h),
                            ],
                          );
                        }).toList(),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget ShowItem() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildCategoryItem("Biriyani", "assets/images/BiriyaniIcon.jpg", biriyani),
        _buildCategoryItem("Pizza", "assets/images/PizzaIcon.jpg", pizza),
        _buildCategoryItem("Burger", "assets/images/burgerIcon.jpg", burger),
        _buildCategoryItem("Chicken", "assets/images/ChickenIcon.jpg", chicken),
        _buildCategoryItem("Icecream", "assets/images/IceCreamIcon.jpg", icecream),
      ],
    );
  }

  Widget _buildCategoryItem(String category, String imagePath, bool isSelected) {
    return GestureDetector(
      onTap: () => _selectCategory(category),
      child: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(60),
        child: Container(
          decoration: BoxDecoration(
            border: isSelected
                ? Border.all(color: Colors.deepOrange, width: 3)
                : Border.all(color: Colors.white),
            borderRadius: BorderRadius.circular(60),
          ),
          child: ClipOval(
            child: Image.asset(
              imagePath,
              height: MediaQuery.of(context).size.height / 14,
              width: MediaQuery.of(context).size.height / 14,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectCategory(String category) async {
    try {
      // Reset all category states
      biriyani = false;
      chicken = false;
      icecream = false;
      pizza = false;
      burger = false;
      
      // Set selected category
      selectedCategory = category;
      
      // Set the appropriate boolean
      switch (category) {
        case "Biriyani":
          biriyani = true;
          break;
        case "Chicken":
          chicken = true;
          break;
        case "Icecream":
          icecream = true;
          break;
        case "Pizza":
          pizza = true;
          break;
        case "Burger":
          burger = true;
          break;
      }
      
      // Get food items for the selected category
      fooditemStream = await getFoodItem(category);
      setState(() {});
    } catch (e) {
      print('Error selecting category: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading $category items'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget FoodRow(DocumentSnapshot doc) {
    return GestureDetector(
      onTap: () {
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => Details(
      name: doc["Name"] ?? "Unknown",
      detail: doc["Detail"] ?? "No description",
      price: doc["Price"].toString(),
      image: doc["Image"] ?? "",
      time:doc["Time"]??"",
    ),
  ),
);

      },
      child: Container(
             width: MediaQuery.of(context).size.width / 2,
        padding: EdgeInsets.symmetric(horizontal: 10),
        margin: EdgeInsets.all(4),
        child: Material(
          elevation: 3,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            
            padding: EdgeInsets.only(left: 10, right: 10, top: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: CachedNetworkImage(
                    imageUrl: doc['Image'] ?? '',
                    height: MediaQuery.of(context).size.height / 5,
                    width: MediaQuery.of(context).size.width / 2.5,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: MediaQuery.of(context).size.height / 5,
                      width: MediaQuery.of(context).size.width / 2.5,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.deepOrange),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: MediaQuery.of(context).size.height / 5,
                      width: MediaQuery.of(context).size.width / 2.5,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.broken_image,
                            color: Colors.grey,
                            size: 40,
                          ),
                          Text(
                            'Image not found',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 5.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: Text(
                    doc["Name"] ?? "Unknown Item",
                    style: AppWidget.getBoldBlackHeadingTextStyle(),
                  ),
                ),
                SizedBox(height: 5.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: Text(
                    doc["Detail"] ?? "No description available",
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: AppWidget.getBlackLightHeadingTextStyle(),
                  ),
                ),
                SizedBox(height: 5.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(Icons.currency_rupee, color: Colors.deepOrange, size: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: Text(
                        doc["Price"] ?? "0",
                        style: AppWidget.getBoldBlackHeadingTextStyle(),
                      ),
                    ),
                    SizedBox(width: 10,),
                    // if (doc["Category"] != null) ...[
                    //   SizedBox(height: 5.0),
                    //   Container(
                    //     padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    //     decoration: BoxDecoration(
                    //       color: Colors.deepOrange.withOpacity(0.1),
                    //       borderRadius: BorderRadius.circular(12),
                    //     ),
                    //     child: Text(
                    //       doc["Category"],
                    //       style: TextStyle(
                    //         color: Colors.deepOrange,
                    //         fontSize: 12,
                    //         fontWeight: FontWeight.w500,
                    //       ),
                    //     ),
                    //   ),
                    // ],
                  ],
                ),
                SizedBox(height: 5.0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget FoodColumn(DocumentSnapshot doc) {
    return GestureDetector(
      onTap: () {
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => Details(
      name: doc["Name"] ?? "Unknown",
      detail: doc["Detail"] ?? "No description",
      price: doc["Price"].toString(),
      image: doc["Image"] ?? "",
      time:doc["Time"]??"N/A",

    ),
  ),
);

      },
      child: Material(
        elevation: 3,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          child: Row(
            children: [
                    SizedBox(height: 10),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: CachedNetworkImage(
                    imageUrl: doc['Image'] ?? '',
                    height: MediaQuery.of(context).size.height / 6.5,
                    width: MediaQuery.of(context).size.width / 3.5,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: MediaQuery.of(context).size.height / 6.5,
                      width: MediaQuery.of(context).size.width / 3.5,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.deepOrange),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: MediaQuery.of(context).size.height / 6.5,
                      width: MediaQuery.of(context).size.width / 3.5,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        // mainAxisSize: MainSizeMin,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.broken_image,
                            color: Colors.grey,
                            size: 20,
                          ),
                          Text(
                            'Image not found',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10),

                    Text(
                      doc["Name"] ?? "Unknown Item",
                      style: AppWidget.getBoldBlackHeadingTextStyle(),
                    ),
                    SizedBox(height: 5.0),
                    Text(
                      doc["Detail"] ?? "No description available",
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: AppWidget.getBlackLightHeadingTextStyle(),
                    ),
                    SizedBox(height: 5.0),
                    Row(
                      children: [
                        Icon(Icons.currency_rupee, color: Colors.deepOrange, size: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          child: Text(
                            doc["Price"] ?? "0",
                            style: AppWidget.getBoldBlackHeadingTextStyle(),
                          ),
                        ),
                      ],
                    ),
                    if (doc["Category"] != null) ...[
                      SizedBox(height: 5.0),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.deepOrange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          doc["Category"],
                          style: TextStyle(
                            color: Colors.deepOrange,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    SizedBox(height: 10),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<Stream<QuerySnapshot>> getFoodItem(String name) async {
    try {
      return FirebaseFirestore.instance
          .collection(name)
          .orderBy('CreatedAt', descending: true)
          .snapshots();
    } catch (e) {
      print('Error getting food items: $e');
      return Stream.empty();
    }
  }
   Future<void> _logout() async {
    try {
      await SharedPreferenceHelper().clearUserData();
      await Authmethods().SignOut();
      _showSnackBar('Success!', 'Account Signed Out', ContentType.success);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Userlogin()),
      );
    } catch (e) {
      print('Error signing out: $e');
      _showSnackBar('Error!', 'Failed to sign out', ContentType.failure);
    }
  }
  void _showSnackBar(String title, String message, ContentType contentType) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: AwesomeSnackbarContent(
            title: title,
            message: message,
            contentType: contentType,
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
  

}
 
  
   
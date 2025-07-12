import 'dart:async';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:random_string/random_string.dart';
import 'package:yumm/service/shared_pref.dart';
import 'package:yumm/widget/widget_support.dart';

class Order extends StatefulWidget {
  const Order({super.key});

  @override
  State<Order> createState() => _OrderState();
}

class _OrderState extends State<Order> {
  String? Id, address, phone, email, name;
  double total = 0.0;
  String order = "";
  Stream? foodStream;

  // Payment dropdown logic
  Map<String, String> paymentOptions = {
    'cod': 'Cash On Delivery',
    'online': 'Online Payment (Not Available)',
  };
  String paymentMethod = 'cod';

  @override
  void initState() {
    super.initState();
    ontheload();
  }

  getthesharedpref() async {
    Id = await SharedPreferenceHelper().getUserId();
    phone = await SharedPreferenceHelper().getUserPhone();
    email = await SharedPreferenceHelper().getUserEmail();
    name = await SharedPreferenceHelper().getUserName();
    setState(() {});
  }

  ontheload() async {
    await getthesharedpref();
    foodStream = await getFoodCart(Id!);
    setState(() {});
  }

  Widget foodCart() {
    return StreamBuilder(
      stream: foodStream,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          double localTotal = 0.0;
          String localOrder = "";
          List<Widget> foodItems = [];

          for (var doc in snapshot.data.docs) {
            DocumentSnapshot ds = doc;
            final totalStr = ds["Total"].toString().replaceAll(",", "").trim();
            final itemTotal = double.tryParse(totalStr) ?? 0.0;
            localTotal += itemTotal;
            localOrder += "${ds["Name"]} * ${ds["Quantity"]}, ";

            foodItems.add(_buildFoodItem(ds));
          }

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (total != localTotal || order != localOrder) {
              setState(() {
                total = localTotal;
                order = localOrder;
              });
            }
          });

          return foodItems.isEmpty
              ? _buildEmptyCart()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  itemCount: foodItems.length,
                  itemBuilder: (context, index) => foodItems[index],
                );
        } else {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.deepOrange),
            ),
          );
        }
      },
    );
  }

  Widget _buildFoodItem(DocumentSnapshot ds) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: Card(
        color:const Color.fromARGB(255, 237, 237, 237) ,
        elevation: 3.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isSmallScreen = constraints.maxWidth < 400;
              
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quantity Badge
                  Container(
                    height: isSmallScreen ? 70 : 80,
                    width: isSmallScreen ? 35 : 40,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.deepOrange, Colors.orange],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepOrange.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        ds["Quantity"],
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: isSmallScreen ? 16 : 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  // Food Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: ds['Image'] ?? '',
                      height: isSmallScreen ? 70 : 80,
                      width: isSmallScreen ? 70 : 80,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        height: isSmallScreen ? 70 : 80,
                        width: isSmallScreen ? 70 : 80,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.deepOrange),
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: isSmallScreen ? 70 : 80,
                        width: isSmallScreen ? 70 : 80,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.restaurant,
                              color: Colors.grey[400],
                              size: isSmallScreen ? 16 : 20,
                            ),
                            if (!isSmallScreen) const SizedBox(height: 2),
                            Text(
                              'No image',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 8 : 10,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  // Food Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ds["Name"],
                          style: TextStyle(
                            fontSize: isSmallScreen ? 14 : 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "₹${ds["Total"]}",
                            style: TextStyle(
                              fontSize: isSmallScreen ? 14 : 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.green[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Delete Button
                  IconButton(
                    onPressed: () async {
                      await deleteFood(Id!, ds["CId"]);
                    },
                    icon: Icon(
                      Icons.delete_outline,
                      color: Colors.red[400],
                      size: isSmallScreen ? 20 : 24,
                    ),
                    splashRadius: 20,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            "Your cart is empty",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Add some delicious items to get started",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showLocationDialog() async {
    TextEditingController locationController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.location_on, color: Colors.deepOrange),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  "Delivery Location",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: locationController,
                maxLines: 3,
                
                decoration: InputDecoration(
                  // fillColor: Colors.white,
                  
                  hintText: "Enter your complete delivery address",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.deepOrange),
                    
                  ),
                  prefixIcon: const Icon(Icons.home_outlined),
                  contentPadding: const EdgeInsets.all(16),
                  fillColor: Colors.white
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: () async {
                if (locationController.text.trim().isNotEmpty) {
                  address = locationController.text.trim();

                  String Oid = randomAlphaNumeric(10);
                  String UOid=Oid;
                  Map<String, dynamic> orderData = {
                    'Item': order,
                    'Ammount': total.toStringAsFixed(2),
                    'CoustomerId': Id,
                    'Name': name,
                    'Email': email,
                    'phone': phone,
                    'Address': address,
                    'PaymentMethod': paymentOptions[paymentMethod],
                    'OId': Oid,
                    'Timestamp': FieldValue.serverTimestamp(),
                           'Status': 'pending', 
                    
                  };

                  await addFoodToOrder(orderData, Id!,Oid!);
                  // Clear the cart after successful order placement
                   String AOid = randomAlphaNumeric(10);

                         Map<String, dynamic> addorderAdmin = {
                    'Item':order,
                    'Ammount': total.toStringAsFixed(2),
                    'CoustomerId': Id,
                    'Name': name,
                    'Email': email,
                    'phone': phone,
                    'Address': address,
                    'PaymentMethod': paymentOptions[paymentMethod],
                    'OId': Oid,
                    'Timestamp': FieldValue.serverTimestamp(),
                          'AOId':AOid,
                           'Status': 'pending', 
                           
                        };
                        await addOrderAdmin(addorderAdmin, AOid);
                  await clearCart(Id!);

                  Navigator.pop(context);

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: Colors.transparent,
                        content: AwesomeSnackbarContent(
                          title: 'Success!',
                          message: 'Your order has been placed successfully',
                          contentType: ContentType.success,
                        ),
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please enter your delivery address"),
                    ),
                  );
                }
              },
              child: const Text("Place Order"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 400;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
          automaticallyImplyLeading: false,
        title: const Text(
          "Food Cart",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        // leading:  Padding(
        //   padding: const EdgeInsets.only(left: 10),
        //   child: GestureDetector(
        //         onTap: () => Navigator.pop(context),
        //         child: Padding(
        //           padding: const EdgeInsets.all(10),
        //           child: const Icon(
        //             Icons.arrow_back_ios,
        //             size: 30,
        //             color: Colors.white,
        //           ),
        //         ),
        //       ),
        // ),

        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Cart Items
          Expanded(
            child: foodCart(),
          ),
          // Bottom Section
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              children: [
                // Total Price
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Total Amount",
                        style: TextStyle(
                          fontSize: isSmallScreen ? 16 : 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "₹${total.toStringAsFixed(2)}",
                          style: TextStyle(
                            fontSize: isSmallScreen ? 16 : 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.green[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Payment Method and Checkout
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Row(
                    children: [
                      // Payment Method Dropdown
                      Expanded(
                        flex: 2,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonFormField<String>(
                            value: paymentMethod,
                            items: paymentOptions.entries.map((entry) {
                              return DropdownMenuItem<String>(
                                value: entry.key,
                                child: Text(
                                  entry.value,
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 12 : 14,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (value) => setState(() => paymentMethod = value!),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              border: InputBorder.none,
                              hintText: "Payment Method",
                              hintStyle: TextStyle(
                                fontSize: isSmallScreen ? 12 : 14,
                              ),
                            ),
                            icon: const Icon(Icons.keyboard_arrow_down),
                            isExpanded: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Checkout Button
                      Expanded(
                        flex: 3,
                        child: ElevatedButton(
                          onPressed: () {
                            if (Id == null || order.isEmpty || total == 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Your cart is empty"),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }
                            _showLocationDialog();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepOrange,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: isSmallScreen ? 14 : 16,
                            ),
                            elevation: 2,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.shopping_bag_outlined, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                "Checkout",
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 14 : 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<Stream<QuerySnapshot>> getFoodCart(String id) async {
    return FirebaseFirestore.instance
        .collection('user')
        .doc(id)
        .collection('Cart')
        .snapshots();
  }

  Future addFoodToOrder(Map<String, dynamic> userInfoMap, String id,String Oid) async {
    return await FirebaseFirestore.instance
        .collection('user')
        .doc(id)
        .collection("Order")
        .doc(Oid)
        .set(userInfoMap);
  }
   Future addOrderAdmin(Map<String, dynamic> userInfoMap,  String aoid) async {// Debug statement
    return await FirebaseFirestore.instance
        .collection('AdminOrder')
        .doc(aoid)
        .set(userInfoMap);
  }
  

  Future deleteFood(String id, String cid) async {
    return await FirebaseFirestore.instance
        .collection('user')
        .doc(id)
        .collection("Cart")
        .doc(cid)
        .delete();
  }

  Future clearCart(String id) async {
    try {
      // Get all cart items
      QuerySnapshot cartSnapshot = await FirebaseFirestore.instance
          .collection('user')
          .doc(id)
          .collection('Cart')
          .get();

      // Delete all cart items in a batch
      WriteBatch batch = FirebaseFirestore.instance.batch();
      
      for (QueryDocumentSnapshot doc in cartSnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      
      // Reset local state
      setState(() {
        total = 0.0;
        order = "";
      });
    } catch (e) {
      print('Error clearing cart: $e');
    }
  }
}
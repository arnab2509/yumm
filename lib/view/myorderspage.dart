import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:yumm/service/shared_pref.dart';

class MyOrdersPage extends StatefulWidget {
  const MyOrdersPage({super.key});

  @override
  State<MyOrdersPage> createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage> {
  String? userId;
  Stream<QuerySnapshot>? ordersStream;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  loadUserData() async {
    userId = await SharedPreferenceHelper().getUserId();
    if (userId != null) {
      setState(() {
        ordersStream = FirebaseFirestore.instance
            .collection('user')
            .doc(userId)
            .collection('Order')
            .orderBy('Timestamp', descending: true)
            .snapshots();
      });
    }
  }

  // Function to delete order from user's collection
  Future<void> deleteOrder(String orderId) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Delete from user's Order collection
      await FirebaseFirestore.instance
          .collection('user')
          .doc(userId!)
          .collection('Order')
          .doc(orderId)
          .delete();

      // Close loading dialog
      Navigator.pop(context);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order deleted successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      // Close loading dialog
      Navigator.pop(context);
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting order: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // Function to show delete confirmation dialog
  Future<void> showDeleteConfirmationDialog(String orderId) async {
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Order'),
        content: const Text('Are you sure you want to delete this order from your history? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete',style: TextStyle(color: Colors.white),),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await deleteOrder(orderId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          "My Orders",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.deepOrange,
        elevation: 0,
      ),
      body: ordersStream == null
          ? _buildLoadingState()
          : StreamBuilder<QuerySnapshot>(
              stream: ordersStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return _buildLoadingState();
                }

                final orders = snapshot.data!.docs;

                if (orders.isEmpty) {
                  return _buildEmptyState();
                }

                return _buildOrdersList(orders, isTablet);
              },
            ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.deepOrange),
          ),
          SizedBox(height: 16),
          Text(
            "Loading your orders...",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 20),
          Text(
            "No orders yet",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Start shopping to see your orders here!",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList(List<QueryDocumentSnapshot> orders, bool isTablet) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
      },
      child: ListView.builder(
        padding: EdgeInsets.all(isTablet ? 20 : 16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          var order = orders[index];
          return _buildOrderCard(order, isTablet);
        },
      ),
    );
  }

  Widget _buildOrderCard(QueryDocumentSnapshot order, bool isTablet) {
    final size = MediaQuery.of(context).size;
    Timestamp timestamp = order['Timestamp'] ?? Timestamp.now();
    String formattedDate = DateFormat.yMMMd().add_jm().format(timestamp.toDate());
    String status = order['Status'] ?? 'Pending';
    String orderId = order['OId'] ?? '';

    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 20 : 16),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(50),
            bottomLeft: Radius.circular(50)
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(50),
              bottomLeft: Radius.circular(50)
            ),
            color: Color.fromARGB(255, 237, 237, 237),
          ),
          child: Padding(
            padding: EdgeInsets.all(isTablet ? 24 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order Header with Status and Delete Button
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.deepOrange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "Order #${order['OId'] ?? 'N/A'}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.deepOrange,
                                fontSize: _getResponsiveFontSize(size, 14),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  formattedDate,
                                  style: TextStyle(
                                    fontSize: _getResponsiveFontSize(size, 12),
                                    color: Colors.grey[600],
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Status Badge and Delete Button
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _getStatusColor(status),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getStatusIcon(status),
                                size: 14,
                                color: _getStatusColor(status),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                status,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _getStatusColor(status),
                                  fontSize: _getResponsiveFontSize(size, 11),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Delete Button (only show for completed or cancelled orders)
                        if (status == 'completed' || status == 'cancelled')
                          GestureDetector(
                            onTap: () => showDeleteConfirmationDialog(orderId),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.red.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: Text('Delete',style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold),),
                                  ),
                                  
                                  const Icon(
                                    Icons.delete,
                                    size: 19,
                                    color: Colors.red,
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Order Status Message
                if (status != 'Pending')
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status).withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _getStatusColor(status).withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _getStatusIcon(status),
                          size: 20,
                          color: _getStatusColor(status),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _getStatusMessage(status),
                            style: TextStyle(
                              fontSize: _getResponsiveFontSize(size, 13),
                              color: _getStatusColor(status),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                
                // Items Section
                _buildInfoSection(
                  icon: Icons.restaurant_menu,
                  title: "Items",
                  content: order['Item'] ?? 'N/A',
                  size: size,
                ),
                
                const SizedBox(height: 12),
                
                // Amount Section
                Row(
                  children: [
                    Icon(
                      Icons.currency_rupee,
                      size: 20,
                      color: Colors.green[600],
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        "Total: ₹${order['Ammount'] ?? '0'}",
                        style: TextStyle(
                          fontSize: _getResponsiveFontSize(size, 16),
                          fontWeight: FontWeight.bold,
                          color: Colors.green[600],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Payment and Address
                _buildInfoSection(
                  icon: Icons.payment,
                  title: "Payment",
                  content: order['PaymentMethod'] ?? 'N/A',
                  size: size,
                ),
                
                const SizedBox(height: 8),
                
                _buildInfoSection(
                  icon: Icons.location_on,
                  title: "Address",
                  content: order['Address'] ?? 'N/A',
                  size: size,
                ),
                
                const Divider(height: 24, thickness: 1),
                
                // Customer Info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Customer Details",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: _getResponsiveFontSize(size, 14),
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildCustomerInfo(Icons.person, order['Name'] ?? 'N/A', size),
                      const SizedBox(height: 4),
                      _buildCustomerInfo(Icons.email, order['Email'] ?? 'N/A', size),
                      const SizedBox(height: 4),
                      _buildCustomerInfo(Icons.phone, order['phone'] ?? 'N/A', size),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Color _getStatusColor(String status) {
  //   switch (status.toLowerCase()) {
  //     case 'completed':
  //       return Colors.green;
  //     case 'cancelled':
  //       return Colors.red;
  //     case 'pending':
  //     default:
  //       return Colors.orange;
  //   }
  // }
 Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'confirmed':
        return Colors.blue;
      case 'preparing':
        return Colors.orange;
      case 'ready':
        return Colors.teal;
      case 'pending':
      default:
        return Colors.amber;
    }
  }
  // IconData _getStatusIcon(String status) {
  //   switch (status.toLowerCase()) {
  //     case 'completed':
  //       return Icons.check_circle;
  //     case 'cancelled':
  //       return Icons.cancel;
  //     case 'pending':
  //     default:
  //       return Icons.access_time;
  //   }
  // }
 IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      case 'confirmed':
        return Icons.thumb_up;
      case 'preparing':
        return Icons.restaurant;
      case 'ready':
        return Icons.done;
      case 'pending':
      default:
        return Icons.pending;
    }
  }
  // String _getStatusMessage(String status) {
  //   switch (status.toLowerCase()) {
  //     case 'completed':
  //       return 'Your order has been completed and delivered successfully!';
  //     case 'cancelled':
  //       return 'This order has been cancelled. If you have any questions, please contact support.';
  //     case 'pending':
  //     default:
  //       return 'Your order is being processed. We\'ll update you soon!';
  //   }
  // }
String _getStatusMessage(String status) {
  switch (status.toLowerCase()) {
    case 'pending':
      return 'Your order is being processed. We\'ll update you soon!';
    case 'confirmed':
      return 'Your order has been confirmed and is being prepared.';
    case 'preparing':
      return 'Your order is currently being prepared.';
    case 'ready':
      return 'Your order is ready for pickup or is on the way!';
    case 'completed':
      return 'Your order has been completed and delivered successfully!';
    case 'cancelled':
      return 'This order has been cancelled. If you have any questions, please contact support.';
    default:
      return 'Your order status is being updated. Please check back shortly.';
  }
}

  Widget _buildInfoSection({
    required IconData icon,
    required String title,
    required String content,
    required Size size,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: Colors.deepOrange,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "$title:",
                style: TextStyle(
                  fontSize: _getResponsiveFontSize(size, 14),
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                content,
                style: TextStyle(
                  fontSize: _getResponsiveFontSize(size, 14),
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[800],
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerInfo(IconData icon, String info, Size size) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            info,
            style: TextStyle(
              fontSize: _getResponsiveFontSize(size, 13),
              color: Colors.grey[700],
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  double _getResponsiveFontSize(Size size, double baseSize) {
    if (size.width < 360) {
      return baseSize - 2;
    } else if (size.width > 600) {
      return baseSize + 2;
    }
    return baseSize;
  }
}
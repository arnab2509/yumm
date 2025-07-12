import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:yumm/service/shared_pref.dart';

class AdminOrder extends StatefulWidget {
  const AdminOrder({super.key});

  @override
  State<AdminOrder> createState() => _AdminOrderState();
}

class _AdminOrderState extends State<AdminOrder> {
  String? userId;
  Stream<QuerySnapshot>? ordersStream;
  String selectedFilter = 'All';
  final List<String> filterOptions = ['All', 'Pending', 'Confirmed', 'Preparing', 'Ready', 'Completed', 'Cancelled'];

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  loadUserData() async {
    setState(() {
      ordersStream = FirebaseFirestore.instance
          .collection('AdminOrder')
          .orderBy('Timestamp', descending: true)
          .snapshots();
    });
  }

  // Enhanced filter function with more status options
  void applyFilter(String filter) {
    setState(() {
      selectedFilter = filter;
      if (filter == 'All') {
        ordersStream = FirebaseFirestore.instance
            .collection('AdminOrder')
            .orderBy('Timestamp', descending: true)
            .snapshots();
      } else {
        // Use case-insensitive filtering by converting to lowercase for comparison
        ordersStream = FirebaseFirestore.instance
            .collection('AdminOrder')
            .where('Status', isEqualTo: filter.toLowerCase())
            // .orderBy('Timestamp', descending: true)
            .snapshots();
      }
    });
  }

  // Fixed function to update order status with correct document IDs
  Future<void> updateOrderStatus(String adminOrderId, String userOrderId, String customerId, String newStatus) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.deepOrange),
          ),
        ),
      );

      // Use batch for atomic operations
      WriteBatch batch = FirebaseFirestore.instance.batch();

      // Update AdminOrder collection using AOId as document ID
      DocumentReference adminOrderRef = FirebaseFirestore.instance
          .collection('AdminOrder')
          .doc(adminOrderId);
      batch.update(adminOrderRef, {
        'Status': newStatus.toLowerCase(), // Store in lowercase for consistent filtering
        'StatusUpdatedAt': FieldValue.serverTimestamp(),
      });

      // Update user's order collection using OId as document ID
      DocumentReference userOrderRef = FirebaseFirestore.instance
          .collection('user')
          .doc(customerId)
          .collection('Order')
          .doc(userOrderId);
      batch.update(userOrderRef, {
        'Status': newStatus.toLowerCase(), // Store in lowercase for consistent filtering
        'StatusUpdatedAt': FieldValue.serverTimestamp(),
      });

      // Commit batch
      await batch.commit();

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order status updated to ${newStatus.toLowerCase()}'),
            backgroundColor: newStatus.toLowerCase() == 'completed' ? Colors.green : Colors.deepOrange,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.pop(context);
      
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating order: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // Function to show confirmation dialog
  void showStatusConfirmationDialog(String adminOrderId, String userOrderId, String customerId, String newStatus) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: [
            Icon(
              _getStatusIcon(newStatus),
              color: _getStatusColor(newStatus),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'Confirm Status Change',
                style: TextStyle(fontSize: _getResponsiveFontSize(MediaQuery.of(context).size, 16)),
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to change the order status to $newStatus?',
          style: TextStyle(fontSize: _getResponsiveFontSize(MediaQuery.of(context).size, 14)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              updateOrderStatus(adminOrderId, userOrderId, customerId, newStatus);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _getStatusColor(newStatus),
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final isMobile = size.width < 600;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          "All Orders",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: _getResponsiveFontSize(size, 20),
          ),
        ),
        backgroundColor: Colors.deepOrange,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.04,
              vertical: 12,
            ),
            child: Row(
              children: [
                Text(
                  'Filter:',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: _getResponsiveFontSize(size, 16),
                  ),
                ),
                SizedBox(width: size.width * 0.03),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.03,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.white),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedFilter,
                        isExpanded: true,
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          color: Colors.deepOrange,
                        ),
                        iconSize: 24,
                        elevation: 16,
                        style: TextStyle(
                          color: Colors.deepOrange,
                          fontSize: _getResponsiveFontSize(size, 14),
                          fontWeight: FontWeight.w500,
                        ),
                        dropdownColor: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        items: filterOptions.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: size.width * 0.02,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _getFilterIcon(value),
                                    color: _getFilterColor(value),
                                    size: 18,
                                  ),
                                  SizedBox(width: size.width * 0.02),
                                  Text(
                                    value,
                                    style: TextStyle(
                                      fontSize: _getResponsiveFontSize(size, 14),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            print("new value "+newValue);
                            applyFilter(newValue);
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: ordersStream == null
          ? _buildLoadingState(size)
          : StreamBuilder<QuerySnapshot>(
              stream: ordersStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return _buildLoadingState(size);
                }

                final orders = snapshot.data!.docs;

                if (orders.isEmpty) {
                  return _buildEmptyState(size);
                }

                return _buildOrdersList(orders, size);
              },
            ),
    );
  }

  Widget _buildLoadingState(Size size) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.deepOrange),
          ),
          SizedBox(height: size.height * 0.02),
          Text(
            "Loading orders...",
            style: TextStyle(
              color: Colors.grey,
              fontSize: _getResponsiveFontSize(size, 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(Size size) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(size.width * 0.08),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: size.width * 0.2,
              color: Colors.grey[400],
            ),
            SizedBox(height: size.height * 0.03),
            Text(
              selectedFilter == 'All' ? "No orders yet" : "No $selectedFilter orders",
              style: TextStyle(
                fontSize: _getResponsiveFontSize(size, 24),
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: size.height * 0.01),
            Text(
              selectedFilter == 'All' 
                ? "Orders will appear here once customers place them!"
                : "No orders with $selectedFilter status found.",
              style: TextStyle(
                fontSize: _getResponsiveFontSize(size, 16),
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersList(List<QueryDocumentSnapshot> orders, Size size) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
      },
      child: ListView.builder(
        padding: EdgeInsets.all(size.width * 0.04),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          var order = orders[index];
          return _buildOrderCard(order, size);
        },
      ),
    );
  }

  Widget _buildOrderCard(QueryDocumentSnapshot order, Size size) {
    Timestamp timestamp = order['Timestamp'] ?? Timestamp.now();
    String formattedDate = DateFormat.yMMMd().add_jm().format(timestamp.toDate());
    String currentStatus = order['Status'] ?? 'pending';
    // Capitalize first letter for display
    String displayStatus = currentStatus[0].toUpperCase() + currentStatus.substring(1);
    String userOrderId = order['OId'] ?? order.id; // For user collection
    String adminOrderId = order['AOId'] ?? order.id; // For admin collection
    String customerId = order['CoustomerId'] ?? '';

    return Container(
      margin: EdgeInsets.only(bottom: size.height * 0.02),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.white,
          ),
          child: Padding(
            padding: EdgeInsets.all(size.width * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order Header with Status
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: size.width * 0.03,
                              vertical: size.height * 0.01,
                            ),
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
                          SizedBox(height: size.height * 0.01),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Flexible(
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
                    // Status Badge
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.03,
                        vertical: size.height * 0.01,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(currentStatus),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getStatusIcon(currentStatus),
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            displayStatus,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: _getResponsiveFontSize(size, 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: size.height * 0.02),
                
                // Order Details
                _buildOrderDetails(order, size),
                
                SizedBox(height: size.height * 0.02),
                
                // Customer Details
                _buildCustomerDetails(order, size),
                
                SizedBox(height: size.height * 0.02),
                
                // Status Change Button
                _buildStatusChangeButton(adminOrderId, userOrderId, customerId, currentStatus, size),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderDetails(QueryDocumentSnapshot order, Size size) {
    return Container(
      padding: EdgeInsets.all(size.width * 0.03),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Order Details",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: _getResponsiveFontSize(size, 16),
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: size.height * 0.01),
          _buildDetailRow(Icons.restaurant_menu, "Items", order['Item'] ?? 'N/A', size),
          _buildDetailRow(Icons.currency_rupee, "Amount", "₹${order['Ammount'] ?? '0'}", size),
          _buildDetailRow(Icons.payment, "Payment", order['PaymentMethod'] ?? 'N/A', size),
          _buildDetailRow(Icons.location_on, "Address", order['Address'] ?? 'N/A', size),
        ],
      ),
    );
  }

  Widget _buildCustomerDetails(QueryDocumentSnapshot order, Size size) {
    return Container(
      padding: EdgeInsets.all(size.width * 0.03),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Customer Details",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: _getResponsiveFontSize(size, 16),
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: size.height * 0.01),
          _buildDetailRow(Icons.person, "Name", order['Name'] ?? 'N/A', size),
          _buildDetailRow(Icons.email, "Email", order['Email'] ?? 'N/A', size),
          _buildDetailRow(Icons.phone, "Phone", order['phone'] ?? 'N/A', size),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, Size size) {
    return Padding(
      padding: EdgeInsets.only(bottom: size.height * 0.01),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: Colors.deepOrange,
          ),
          SizedBox(width: size.width * 0.02),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$label:",
                  style: TextStyle(
                    fontSize: _getResponsiveFontSize(size, 13),
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: _getResponsiveFontSize(size, 14),
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChangeButton(String adminOrderId, String userOrderId, String customerId, String currentStatus, Size size) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => showStatusChangeDialog(adminOrderId, userOrderId, customerId, currentStatus),
        icon: const Icon(Icons.edit, size: 18),
        label: Text(
          'Change Status',
          style: TextStyle(
            fontSize: _getResponsiveFontSize(size, 14),
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepOrange,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: size.height * 0.015),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
      ),
    );
  }

  // Show status change dialog with all available options
  void showStatusChangeDialog(String adminOrderId, String userOrderId, String customerId, String currentStatus) {
    final availableStatuses = [
      'Pending',
      'Confirmed', 
      'Preparing',
      'Ready',
      'Completed',
      'Cancelled'
    ];

    final size = MediaQuery.of(context).size;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: [
            Icon(Icons.edit, color: Colors.deepOrange),
            SizedBox(width: size.width * 0.02),
            Flexible(
              child: Text(
                'Change Order Status',
                style: TextStyle(
                  fontSize: _getResponsiveFontSize(size, 16),
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Current Status: ${currentStatus[0].toUpperCase() + currentStatus.substring(1)}',
                style: TextStyle(
                  fontSize: _getResponsiveFontSize(size, 14),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: size.height * 0.02),
              Text(
                'Select New Status:',
                style: TextStyle(
                  fontSize: _getResponsiveFontSize(size, 14),
                ),
              ),
              SizedBox(height: size.height * 0.01),
              ...availableStatuses.map((status) {
                if (status.toLowerCase() == currentStatus.toLowerCase()) return const SizedBox.shrink();
                return Container(
                  margin: EdgeInsets.only(bottom: size.height * 0.01),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        showStatusConfirmationDialog(adminOrderId, userOrderId, customerId, status);
                      },
                      icon: Icon(_getStatusIcon(status), size: 18),
                      label: Text(
                        status,
                        style: TextStyle(
                          fontSize: _getResponsiveFontSize(size, 14),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _getStatusColor(status),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: size.height * 0.01),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontSize: _getResponsiveFontSize(size, 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods for dropdown filter
  IconData _getFilterIcon(String filter) {
    switch (filter.toLowerCase()) {
      case 'all':
        return Icons.list;
      case 'pending':
        return Icons.pending;
      case 'confirmed':
        return Icons.thumb_up;
      case 'preparing':
        return Icons.restaurant;
      case 'ready':
        return Icons.done;
      case 'completed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.filter_list;
    }
  }

  Color _getFilterColor(String filter) {
    switch (filter.toLowerCase()) {
      case 'all':
        return Colors.grey;
      case 'pending':
        return Colors.amber;
      case 'confirmed':
        return Colors.blue;
      case 'preparing':
        return Colors.orange;
      case 'ready':
        return Colors.teal;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

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

  double _getResponsiveFontSize(Size size, double baseSize) {
    if (size.width < 360) {
      return baseSize - 2;
    } else if (size.width > 600) {
      return baseSize + 2;
    }
    return baseSize;
  }
}
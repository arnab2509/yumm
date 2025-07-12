import 'package:flutter/material.dart';

class Wallet extends StatefulWidget {
  const Wallet({super.key});

  @override
  State<Wallet> createState() => _WalletState();
}

class _WalletState extends State<Wallet> {
  double walletBalance = 500.0;
  final TextEditingController _amountController = TextEditingController();
  String paymentMethod = 'Online Payment'; // Default

  void _makePayment() {
    final amount = double.tryParse(_amountController.text);

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter a valid amount")),
      );
      return;
    }

    if (paymentMethod == 'Online Payment') {
      _mockOnlinePayment(amount);
    } else if (paymentMethod == 'Cash on Delivery') {
      _mockCOD(amount);
    }
  }

  void _mockOnlinePayment(double amount) {
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        walletBalance += amount;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("₹${amount.toStringAsFixed(2)} added via Online Payment!")),
      );
      _amountController.clear();
    });
  }

  void _mockCOD(double amount) {
    Future.delayed(const Duration(milliseconds: 800), () {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Cash on Delivery Selected. ₹${amount.toStringAsFixed(2)} to be paid in cash."),
        ),
      );
      _amountController.clear();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Wallet & Payment"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Icon(Icons.account_balance_wallet, size: 80),
            const SizedBox(height: 20),
            Text(
              "Wallet Balance",
              // style: Theme.of(context).textTheme.headlineLarge,
            ),
            Text(
              "₹${walletBalance.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Enter amount',
                prefixIcon: Icon(Icons.currency_rupee),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Text("Payment Method:"),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: paymentMethod,
                    items: ['Online Payment', 'Cash on Delivery']
                        .map((String method) => DropdownMenuItem<String>(
                              value: method,
                              child: Text(method),
                            ))
                        .toList(),
                    onChanged: (String? value) {
                      setState(() {
                        paymentMethod = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _makePayment,
              icon: const Icon(Icons.payment),
              label: const Text("Proceed Payment"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                backgroundColor: Colors.teal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class CashierScreen extends StatelessWidget {
  const CashierScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement scanning, creating invoice, payment, save sale
    return Scaffold(
      appBar: AppBar(title: const Text('Cashier')),
      body: const Center(child: Text('POS: scan barcode, add items, take payment')),
    );
  }
}

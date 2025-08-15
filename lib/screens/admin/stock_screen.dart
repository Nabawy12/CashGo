import 'package:flutter/material.dart';

class StockScreen extends StatelessWidget {
  const StockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: show list of products with quantities and low-stock alerts
    return Scaffold(
      appBar: AppBar(title: const Text('Stock')),
      body: const Center(child: Text('Stock list and low-stock alerts')),
    );
  }
}

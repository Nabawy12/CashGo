import 'package:flutter/material.dart';

class ProfitScreen extends StatelessWidget {
  const ProfitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: compute profit per product and total profits
    return Scaffold(
      appBar: AppBar(title: const Text('Profits')),
      body: const Center(child: Text('Profit reports here')),
    );
  }
}

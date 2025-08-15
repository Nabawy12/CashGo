import 'package:flutter/material.dart';

class ReceiptWidget extends StatelessWidget {
  final Map<String, dynamic> saleData;
  const ReceiptWidget({super.key, required this.saleData});

  @override
  Widget build(BuildContext context) {
    // TODO: implement a printable receipt widget
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: const [
          Text('Receipt'),
        ],
      ),
    );
  }
}

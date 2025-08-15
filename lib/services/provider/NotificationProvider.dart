// import 'package:flutter/material.dart';
//
// import '../../models/lowstock.dart';
// import '../../models/product.dart';
//
// class NotificationProvider with ChangeNotifier {
//   List<LowStockNotification> _notifications = [];
//
//   List<LowStockNotification> get notifications => _notifications;
//
//   int get unreadCount =>
//       _notifications.where((n) => !n.isRead).length;
//
//   void loadNotifications(List<LowStockNotification> list) {
//     _notifications = list;
//     notifyListeners();
//   }
//
//   void markAsRead(int id) {
//     final index = _notifications.indexWhere((n) => n.id == id);
//     if (index != -1) {
//       _notifications[index].isRead = true;
//       notifyListeners();
//     }
//   }
//   void checkLowStockProducts(List<Product> products) {
//     for (var product in products) {
//       if (product.quantity <= product.minQty && !product.isRead) {
//         notifications.add(
//           NotificationItem(
//             id: product.id,
//             title: 'كمية قليلة',
//             message: '${product.name} الكمية المتبقية ${product.quantity}',
//             productId: product.id,
//           ),
//         );
//       }
//     }
//     notifyListeners();
//   }
//
// }

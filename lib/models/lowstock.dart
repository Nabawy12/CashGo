class LowStockNotification {
  final int id;
  final String name;
  final int qty;
  bool isRead;

  LowStockNotification({
    required this.id,
    required this.name,
    required this.qty,
    this.isRead = false,
  });
}

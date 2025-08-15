// models/product.dart
class Product {
  final int? id;
  final String barcode;
  final String name;
  final double purchasePrice; // سعر الكرتونة
  final double sellingPrice;  // سعر بيع القطعة
  final int quantity;         // عدد الكراتين
  final int unitsInCarton;    // عدد القطع داخل الكرتونة

  // new fields
  final String? productionDate; // yyyy-mm-dd
  final String? expiryDate;     // yyyy-mm-dd
  final int? lowStockSeen;      // 0 or 1
  final int? expirySeen;        // 0 or 1

  Product({
    this.id,
    required this.barcode,
    required this.name,
    required this.purchasePrice,
    required this.sellingPrice,
    required this.quantity,
    required this.unitsInCarton,
    this.productionDate,
    this.expiryDate,
    this.lowStockSeen,
    this.expirySeen,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'barcode': barcode,
      'name': name,
      'purchase_price': purchasePrice,
      'selling_price': sellingPrice,
      'quantity': quantity,
      'units_in_carton': unitsInCarton,
      'production_date': productionDate ?? '',
      'expiry_date': expiryDate ?? '',
      'low_stock_seen': lowStockSeen ?? 0,
      'expiry_seen': expirySeen ?? 0,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as int?,
      barcode: map['barcode'] as String,
      name: map['name'] as String,
      purchasePrice: (map['purchase_price'] as num).toDouble(),
      sellingPrice: (map['selling_price'] as num).toDouble(),
      quantity: map['quantity'] as int,
      unitsInCarton: (map['units_in_carton'] as num).toInt(),
      productionDate: (map['production_date'] as String?)?.isEmpty ?? true ? null : map['production_date'] as String?,
      expiryDate: (map['expiry_date'] as String?)?.isEmpty ?? true ? null : map['expiry_date'] as String?,
      lowStockSeen: map['low_stock_seen'] is int ? map['low_stock_seen'] as int : int.tryParse((map['low_stock_seen'] ?? '').toString()) ?? 0,
      expirySeen: map['expiry_seen'] is int ? map['expiry_seen'] as int : int.tryParse((map['expiry_seen'] ?? '').toString()) ?? 0,
    );
  }
}

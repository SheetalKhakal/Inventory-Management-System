class Product {
  int? id;
  String name;
  String sku;
  int quantity;
  double price;

  Product(
      {this.id,
      required this.name,
      required this.sku,
      required this.quantity,
      required this.price});

  // Convert a Product into a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'sku': sku,
      'quantity': quantity,
      'price': price,
    };
  }

  // Convert a Map into a Product
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      sku: map['sku'],
      quantity: map['quantity'],
      price: map['price'],
    );
  }
}

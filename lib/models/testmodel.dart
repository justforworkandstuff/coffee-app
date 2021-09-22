class TestModel 
{
  final String product;
  final double price;

  TestModel({required this.product, required this.price});

  Map<String, dynamic> toJson() => {'product': this.product, 'price': this.price};
}
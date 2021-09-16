class Order {
  final String date;
  final String time;
  final String productName;
  final String owner;
  final double productPrice;
  final String address;

  Order(
      {required this.date,
      required this.time,
      required this.productName,
      required this.owner,
      required this.productPrice,
      required this.address});
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

void main() {
  runApp(const MyApp());
}

class Order {
  final String item;
  final String itemName;
  final double price;
  final String currency;
  final int quantity;

  Order({
    required this.item,
    required this.itemName,
    required this.price,
    required this.currency,
    required this.quantity,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      item: json['Item'],
      itemName: json['ItemName'],
      price: json['Price'].toDouble(),
      currency: json['Currency'],
      quantity: json['Quantity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Item': item,
      'ItemName': itemName,
      'Price': price,
      'Currency': currency,
      'Quantity': quantity,
    };
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Order Management',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const OrderPage(),
    );
  }
}

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final List<Order> _orders = [];
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _itemController = TextEditingController();
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _currencyController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final String jsonString = await rootBundle.loadString('assets/orders.json');
    final List<dynamic> jsonData = json.decode(jsonString);
    setState(() {
      _orders.addAll(jsonData.map((e) => Order.fromJson(e)).toList());
    });
  }

  void _addOrder() {
    final newOrder = Order(
      item: _itemController.text,
      itemName: _itemNameController.text,
      price: double.tryParse(_priceController.text) ?? 0.0,
      currency: _currencyController.text,
      quantity: int.tryParse(_quantityController.text) ?? 0,
    );
    setState(() {
      _orders.add(newOrder);
    });
    _clearInputFields();
  }

  void _clearInputFields() {
    _itemController.clear();
    _itemNameController.clear();
    _priceController.clear();
    _currencyController.clear();
    _quantityController.clear();
  }

  List<Order> _searchOrders(String query) {
    return _orders
        .where((order) => order.itemName.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Management'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search by Item Name',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _searchController.text.isEmpty
                    ? _orders.length
                    : _searchOrders(_searchController.text).length,
                itemBuilder: (context, index) {
                  final ordersToShow = _searchController.text.isEmpty
                      ? _orders
                      : _searchOrders(_searchController.text);
                  final order = ordersToShow[index];
                  return ListTile(
                    title: Text(order.itemName),
                    subtitle: Text('Price: ${order.price} ${order.currency}'),
                    trailing: Text('Qty: ${order.quantity}'),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            const Text('Add New Order', style: TextStyle(fontSize: 18)),
            TextField(
              controller: _itemController,
              decoration: const InputDecoration(labelText: 'Item'),
            ),
            TextField(
              controller: _itemNameController,
              decoration: const InputDecoration(labelText: 'Item Name'),
            ),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _currencyController,
              decoration: const InputDecoration(labelText: 'Currency'),
            ),
            TextField(
              controller: _quantityController,
              decoration: const InputDecoration(labelText: 'Quantity'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addOrder,
              child: const Text('Add Order'),
            ),
          ],
        ),
      ),
    );
  }
}
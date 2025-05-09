import 'package:flutter/material.dart';
import '../models/order.dart';
import '../services/order_service.dart';

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
  final OrderService _orderService = OrderService();

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final orders = await _orderService.loadOrders();
    setState(() {
      _orders.addAll(orders);
    });
  }

  Future<void> _addOrder() async {
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

    // Save the updated list to the JSON file
    await _orderService.saveOrders(_orders);

    _clearInputFields();
  }

  Future<void> _deleteOrder(int index) async {
    setState(() {
      _orders.removeAt(index);
    });

    // Save the updated list to the JSON file
    await _orderService.saveOrders(_orders);
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
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteOrder(index),
                        ),
                      ],
                    ),
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
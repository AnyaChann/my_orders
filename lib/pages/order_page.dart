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
    if (_itemController.text.isEmpty ||
        _itemNameController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _currencyController.text.isEmpty ||
        _quantityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    final price = double.tryParse(_priceController.text);
    final quantity = int.tryParse(_quantityController.text);

    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid price')),
      );
      return;
    }

    if (quantity == null || quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid quantity')),
      );
      return;
    }

    final newOrder = Order(
      item: _itemController.text,
      itemName: _itemNameController.text,
      price: price,
      currency: _currencyController.text,
      quantity: quantity,
    );

    setState(() {
      _orders.add(newOrder);
    });

    await _orderService.saveOrders(_orders);
    _clearInputFields();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Order added successfully')),
    );
  }

  Future<void> _deleteOrder(int index) async {
    setState(() {
      _orders.removeAt(index);
    });

    await _orderService.saveOrders(_orders);
  }

  void _clearInputFields() {
    _itemController.clear();
    _itemNameController.clear();
    _priceController.clear();
    _currencyController.clear();
    _quantityController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Order'),
        centerTitle: true,
        backgroundColor: Colors.orange,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _itemController,
                        decoration: const InputDecoration(
                          labelText: 'Item',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _itemNameController,
                        decoration: const InputDecoration(
                          labelText: 'Item Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _priceController,
                        decoration: const InputDecoration(
                          labelText: 'Price',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _quantityController,
                        decoration: const InputDecoration(
                          labelText: 'Quantity',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _currencyController,
                        decoration: const InputDecoration(
                          labelText: 'Currency',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _addOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  child: const Text('Add Item to Cart'),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Table(
                border: TableBorder.all(color: Colors.orange),
                columnWidths: const {
                  0: FixedColumnWidth(50),
                  1: FlexColumnWidth(),
                  2: FlexColumnWidth(),
                  3: FixedColumnWidth(80),
                  4: FixedColumnWidth(80),
                  5: FixedColumnWidth(80),
                  6: FixedColumnWidth(50),
                },
                children: [
                  TableRow(
                    decoration: const BoxDecoration(color: Colors.orange),
                    children: const [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Id', style: TextStyle(color: Colors.white)),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Item', style: TextStyle(color: Colors.white)),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Item Name', style: TextStyle(color: Colors.white)),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Quantity', style: TextStyle(color: Colors.white)),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Price', style: TextStyle(color: Colors.white)),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Currency', style: TextStyle(color: Colors.white)),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(''),
                      ),
                    ],
                  ),
                  ..._orders.asMap().entries.map((entry) {
                    final index = entry.key;
                    final order = entry.value;
                    return TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('${index + 1}'),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(order.item),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(order.itemName),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('${order.quantity}'),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('${order.price}'),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(order.currency),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteOrder(index),
                        ),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
          Container(
            color: Colors.orange,
            padding: const EdgeInsets.all(16.0),
            child: const Center(
              child: Text(
                'Số 8, Tôn Thất Thuyết, Cầu Giấy, Hà Nội',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import '../models/order.dart';

class OrderService {
  Future<String> _getFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/orders.json';
  }

  Future<List<Order>> loadOrders() async {
    final filePath = await _getFilePath();
    final file = File(filePath);

    if (!file.existsSync()) {
      // If the file doesn't exist, load initial data from assets
      final String jsonString = await rootBundle.loadString('assets/orders.json');
      final List<dynamic> jsonData = json.decode(jsonString);
      final orders = jsonData.map((e) => Order.fromJson(e)).toList();

      // Save the initial data to the local file
      await saveOrders(orders);
      return orders;
    }

    // Read the file and parse the JSON data
    final jsonString = await file.readAsString();
    final List<dynamic> jsonData = json.decode(jsonString);
    return jsonData.map((e) => Order.fromJson(e)).toList();
  }

  Future<void> saveOrders(List<Order> orders) async {
    final filePath = await _getFilePath();
    final file = File(filePath);

    // Convert the orders to JSON and write to the file
    final jsonString = json.encode(orders.map((e) => e.toJson()).toList());
    await file.writeAsString(jsonString);
  }
}
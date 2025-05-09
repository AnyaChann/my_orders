import 'dart:convert';
import 'dart:io' show File, Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'dart:html' as html; // For web localStorage
import '../models/order.dart';

class OrderService {
  static const String _storageKey = 'orders';

  Future<List<Order>> loadOrders() async {
    if (kIsWeb) {
      // Use localStorage for web
      final jsonString = html.window.localStorage[_storageKey];
      if (jsonString == null) {
        // Load initial data from assets if no data exists in localStorage
        final String initialData = await rootBundle.loadString('assets/orders.json');
        html.window.localStorage[_storageKey] = initialData;
        final List<dynamic> jsonData = json.decode(initialData);
        return jsonData.map((e) => Order.fromJson(e)).toList();
      } else {
        final List<dynamic> jsonData = json.decode(jsonString);
        return jsonData.map((e) => Order.fromJson(e)).toList();
      }
    } else {
      // Use file storage for other platforms
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
  }

  Future<void> saveOrders(List<Order> orders) async {
    if (kIsWeb) {
      // Save to localStorage for web
      final jsonString = json.encode(orders.map((e) => e.toJson()).toList());
      html.window.localStorage[_storageKey] = jsonString;
    } else {
      // Save to file for other platforms
      final filePath = await _getFilePath();
      final file = File(filePath);

      // Convert the orders to JSON and write to the file
      final jsonString = json.encode(orders.map((e) => e.toJson()).toList());
      await file.writeAsString(jsonString);
    }
  }

  Future<String> _getFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/orders.json';
  }
}
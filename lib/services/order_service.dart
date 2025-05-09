import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/order.dart';

class OrderService {
  Future<List<Order>> loadOrders() async {
    final String jsonString = await rootBundle.loadString('assets/orders.json');
    final List<dynamic> jsonData = json.decode(jsonString);
    return jsonData.map((e) => Order.fromJson(e)).toList();
  }
}
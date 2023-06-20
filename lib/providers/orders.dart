import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import './cart.dart';
//import './auth.dart';

class OrderItem {
  final String id;
  final int amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    @required this.id,
    @required this.amount,
    @required this.products,
    @required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  final String authToken;
  final String userId;

  Orders(this.authToken, this.userId, this._orders);

  List<OrderItem> get orders {
    return [..._orders]; //returns a copy of the _orders list
  }

  Future<void> fetchAndSetOrders() async {
    final url = Uri.https(
      'myshop-2bf82-default-rtdb.asia-southeast1.firebasedatabase.app',
      '/orders/$userId.json',
      {
        'auth': authToken,
        /* 'orderBy': '"userId"',
        'equalTo': '"$userId"', */
      },
    );
    final response = await http.get(url);
    final List<OrderItem> loadedOrders = [];
    final extractedData = json.decode(response.body) as Map<String, dynamic>;
    if (extractedData == null) {
      return;
    }
    extractedData.forEach((orderId, orderData) {
      loadedOrders.add(
        OrderItem(
          id: orderId,
          amount: orderData['amount'],
          dateTime: DateTime.parse(
            orderData['dateTime'],
          ),
          products: (orderData['products'] as List<dynamic>)
              .map(
                (item) => CartItem(
                  id: item['id'],
                  title: item['title'],
                  quantity: item['quantity'],
                  price: item['price'],
                ),
              )
              .toList(),
        ),
      );
    });
    _orders = loadedOrders.reversed.toList();
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartProducts, int total) async {
    final url = Uri.https(
      'myshop-2bf82-default-rtdb.asia-southeast1.firebasedatabase.app',
      '/orders/$userId.json',
      {
        'auth': authToken,
        /* 'orderBy': '"userId"',
        'equalTo': '"$userId"', */
      },
    );
    final timeStamp = DateTime.now();

    final response = await http.post(
      url,
      body: json.encode({
        //'id': json.decode(response),
        'amount': total,
        'products': cartProducts
            .map((cp) => {
                  //CartItem
                  'id': cp.id,
                  'price': cp.price,
                  'quantity': cp.quantity,
                  'title': cp.title,
                })
            .toList(),
        'dateTime': timeStamp.toIso8601String(),
      }),
    );
    _orders.insert(
      0,
      OrderItem(
        //to get auto generated id
        id: json.decode(response.body)['name'],
        amount: total,
        products: cartProducts,
        dateTime: DateTime.now(),
      ),
    );
    notifyListeners();
  }
}

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final int price;
  final String imageUrl;
  bool isFavorite;

  Product({
    @required this.title,
    @required this.price,
    @required this.description,
    @required this.id,
    @required this.imageUrl,
    this.isFavorite = false,
  });

  Future<void> toggleFavoriteStatus(String token,String userId) async {
    final oldStatus = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();
    final url = Uri.https(
      'myshop-2bf82-default-rtdb.asia-southeast1.firebasedatabase.app',
      '/user-favorites/$userId/$id.json',
      {
        'auth': token,
        /* 'orderBy': '"userId"',
        'equalTo': '"$userId"', */
      },
    );
    try {
      final response = await http.put(
        url,
        body: json.encode(
          isFavorite,
        ),
      );
      if (response.statusCode >= 400) {
        isFavorite = oldStatus;
        notifyListeners();
      }
    } catch (error) {
      isFavorite = oldStatus;
      notifyListeners();
    }
  }
}

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  final String creatorId;
  final DateTime lastUpdate;
  int stock;
  bool isFavorite;

  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
    @required this.stock,
    this.lastUpdate,
    this.creatorId = "",
    this.isFavorite = false,
  });

  void _setFavValue(bool newValue) {
    isFavorite = newValue;
    notifyListeners();
  }

  void _setStock(int newValue) {
    stock = newValue;
    notifyListeners();
  }

  Future<void> toggleFavoriteStatus(String token, String userId) async {
    final oldStatus = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();
    final url =
        'https://flutter-app-81864-default-rtdb.firebaseio.com/userFavorites/$userId/$id.json?auth=$token';
    try {
      final response = await http.put(
        url,
        body: json.encode(
          isFavorite,
        ),
      );
      if (response.statusCode >= 400) {
        _setFavValue(oldStatus);
      }
    } catch (error) {
      _setFavValue(oldStatus);
    }
  }

  Future<void> updateStockProduct(
      String authToken, String id, int pStock) async {
    var newStock;
    if (this.stock == null) {
      newStock = pStock;
      this.stock = newStock;
    } else {
      newStock = this.stock + pStock;
      this.stock = newStock;
    }
    final url =
        'https://flutter-app-81864-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken';
    await http.patch(url,
        body: json.encode({
          'stock': newStock,
        }));
    notifyListeners();
  }
}

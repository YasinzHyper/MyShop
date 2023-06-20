import 'dart:convert';
//import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/htpp_exception.dart';
import './product.dart';

class ProductsProvider with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 699,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 899,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 499,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 399,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];

  //var _showFavoritesOnly = false;

  final String authToken;
  final String userId;

  ProductsProvider(this.authToken, this.userId, this._items);

  List<Product> get items {
    // if (_showFavoritesOnly) {
    //   return _items.where((product) => product.isFavorite).toList();
    // }
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((product) => product.isFavorite).toList();
  }

  // void showFavoritesOnly(){
  //   _showFavoritesOnly = true;
  //   notifyListeners();
  // }

  // void showAll(){
  //   _showFavoritesOnly = false;
  //   notifyListeners();
  // }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    var url = filterByUser
        ? Uri.https(
            'myshop-2bf82-default-rtdb.asia-southeast1.firebasedatabase.app',
            '/products-provider.json',
            {
              'auth': authToken,
              'orderBy': '"userId"',
              'equalTo': '"$userId"',
            },
          )
        : Uri.https(
            'myshop-2bf82-default-rtdb.asia-southeast1.firebasedatabase.app',
            '/products-provider.json',
            {
              'auth': authToken,
            },
          );
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }
      url = Uri.https(
        'myshop-2bf82-default-rtdb.asia-southeast1.firebasedatabase.app',
        '/user-favorites/$userId.json',
        {
          'auth': authToken,
          /* 'orderBy': '"creatorId"',
          'equalTo': '"$userId"', */
        },
      );
      final favoriteResponse = await http.get(url);
      final favoriteData = json.decode(favoriteResponse.body);
      final List<Product> loadedProducts = [];
      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(
          Product(
            title: prodData['title'],
            price: prodData['price'],
            description: prodData['description'],
            id: prodId,
            imageUrl: prodData['imageUrl'],
            isFavorite:
                favoriteData == null ? false : favoriteData[prodId] ?? false,
            // '??' indicates that if favData[prodId] == null , then it will be set to false
          ),
        );
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  Future<void> addProduct(Product product) async {
    final url = Uri.https(
      'myshop-2bf82-default-rtdb.asia-southeast1.firebasedatabase.app',
      '/products-provider.json',
      {
        'auth': authToken,
        /* 'orderBy': '"userId"',
        'equalTo': '"$userId"', */
      },
    );
    try {
      final response = await http //to return a future to addProduct method
          .post(
        url,
        body: json.encode(
          {
            'title': product.title,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'price': product.price,
            'creatorId': userId,
            //'isFavorite': product.isFavorite,
          },
        ),
      );
      final newProduct = Product(
        title: product.title,
        price: product.price,
        description: product.description,
        id: json.decode(response.body)['name'],
        imageUrl: product.imageUrl,
      );
      _items.insert(0, newProduct);
      notifyListeners();
    } catch (error) {
      print(error);
      //throw error;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      final url = Uri.https(
        'myshop-2bf82-default-rtdb.asia-southeast1.firebasedatabase.app',
        '/products-provider/$id.json',
        {
          'auth': authToken,
          /* 'orderBy': '"userId"',
        'equalTo': '"$userId"', */
        },
      );
      try {
        await http.patch(
          url,
          body: json.encode({
            //merge the following fields with the existing data on the sever
            'title': newProduct.title,
            'description': newProduct.description,
            'imageUrl': newProduct.imageUrl,
            'price': newProduct.price,
            //'isFavorite': newProduct.isFavorite,
          }),
        );
      } catch (error) {
        print(error);
      }
      _items[prodIndex] = newProduct;
      notifyListeners();
    } else {
      print('...');
    }
  }

  void deleteProduct(String id) async {
    final url = Uri.https(
      'myshop-2bf82-default-rtdb.asia-southeast1.firebasedatabase.app',
      '/products-provider/$id.json',
      {
        'auth': authToken,
        /* 'orderBy': '"userId"',
        'equalTo': '"$userId"', */
      },
    );
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    var existingProduct = _items[existingProductIndex];
    //_items.removeWhere((prod) => prod.id == id);
    _items.removeAt(existingProductIndex);
    notifyListeners();
    //Optimistic updating
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete product!');
    } else {
      existingProduct = null;
    }
  }
}

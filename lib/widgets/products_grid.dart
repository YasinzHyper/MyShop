import 'package:flutter/material.dart';
//import 'package:flutter_complete_guide/providers/products_provider.dart';
import 'package:provider/provider.dart';

import './product_item.dart';
//import '../models/product.dart';
import '../providers/products_provider.dart';

class ProductsGrid extends StatelessWidget {
  final bool showFavs;

  ProductsGrid(this.showFavs);

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<ProductsProvider>(context);
    final products = showFavs ? productsData.favoriteItems : productsData.items;
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: products.length,
      itemBuilder: (context, index) => ChangeNotifierProvider.value(
        value: products[index], //correct approach for data in a list/grid
        //This is useful when u re-use an existing object
        //create: (ctx) => products[index],
        child: ProductItem(
            // id: products[index].id,
            // imageUrl: products[index].imageUrl,
            // title: products[index].title,
            // price: products[index].price,
            ),
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        childAspectRatio: 1.35,
        crossAxisCount: 2,
        crossAxisSpacing: 10, //Space between each column..
        mainAxisSpacing: 10, //Space between rows..
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../providers/products_provider.dart';

//import '../models/product.dart';
import 'package:provider/provider.dart';

class ProductDetailScreen extends StatelessWidget {
  //const ProductDetailScreen({Key key}) : super(key: key);
  // final String title;

  // ProductDetailScreen({this.title});
  static const routeName = '/product-detail';

  @override
  Widget build(BuildContext context) {
    final productId = ModalRoute.of(context).settings.arguments as String;
    final loadedProduct = Provider.of<ProductsProvider>(
      context,
      listen: false, //Won't rebuild everytime is a new product is added..
    ).findById(productId);
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      // appBar: AppBar(
      //   title: Text(
      //     loadedProduct.title,
      //     // ignore: deprecated_member_use
      //     style: Theme.of(context).textTheme.headline6,
      //   ),
      // ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            iconTheme: IconThemeData(
              color: Theme.of(context).accentColor,
            ),
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                loadedProduct.title,
                // ignore: deprecated_member_use
                style: TextStyle(
                  backgroundColor: Color.fromARGB(73, 96, 125, 139),
                  color: Colors.white,
                  fontFamily: Theme.of(context).textTheme.headline6.fontFamily,
                  fontSize: Theme.of(context).textTheme.headline6.fontSize,
                ),
              ),
              background: Hero(
                tag: loadedProduct.id,
                child: Image.network(
                  loadedProduct.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                SizedBox(
                  height: 10,
                ),
                Text(
                  '₹${loadedProduct.price}',
                  style: TextStyle(
                    color: Colors.blueGrey,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  padding: EdgeInsets.all(8),
                  width: double.infinity,
                  child: Text(
                    loadedProduct.description,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                    ),
                    softWrap: true,
                  ),
                ),
                SizedBox(
                  height: 700,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

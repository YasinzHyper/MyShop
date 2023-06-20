import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/orders.dart' show Orders;
import '../widgets/order_item.dart' /* as orderWidget */;
import '../widgets/app_drawer.dart';

class OrdersScreen extends StatefulWidget {
  //const OrdersScreen({Key key}) : super(key: key);
  static const routeName = '/orders';

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  Future _ordersFuture;

  Future obtainOrdersFuture() {
    return Provider.of<Orders>(context, listen: false).fetchAndSetOrders();
  }

  @override
  void initState() {
    _ordersFuture = obtainOrdersFuture();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //final orderData = Provider.of<Orders>(context);
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: Text(
          'Your Orders',
        ),
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: _ordersFuture,
        builder: (ctx, dataSnapshot) {
          if (dataSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else {
            if (dataSnapshot.error != null) {
              //Error Handling...
              return Center(
                child: Text('An error occurred!'),
              );
            }
            return Consumer<Orders>(
              builder: (ctx, orderData, child) => orderData.orders == null
                  ? Center(
                      child: Card(
                        color: Theme.of(context).primaryColorDark,
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'No orders placed yet!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              //backgroundColor: Theme.of(context).primaryColorDark,
                              color: Theme.of(context).accentColor,
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: orderData.orders.length,
                      itemBuilder: (ctx, i) => /*orderWidget.*/ OrderItem(
                        orderData.orders[i],
                      ),
                    ),
            );
          }
        },
      ),
    );
  }
}

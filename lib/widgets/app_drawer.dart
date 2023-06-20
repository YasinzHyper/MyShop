import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/orders_screen.dart';
import '../screens/user_products_screen.dart';
import '../providers/auth.dart';
import '../helpers/custom_route.dart';

class AppDrawer extends StatelessWidget {
  //const AppDrawer({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            title: Text('Hello There!'),
            automaticallyImplyLeading: false, //won't show back button
          ),
          Divider(
            thickness: 2,
          ),
          ListTile(
            leading: Icon(Icons.shop),
            title: Text(
              'Shop',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            onTap: () {
              Navigator.of(context).pushReplacementNamed(
                  '/'); //go back to the root route/homepage
            },
          ),
          Divider(
            thickness: 1.5,
          ),
          ListTile(
            leading: Icon(Icons.payment),
            title: Text(
              'My Orders',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            onTap: () {
              Navigator.of(context).pushReplacementNamed(OrdersScreen.routeName);
              // Navigator.of(context).pushReplacement(CustomRoute(
              //   builder: (ctx) => OrdersScreen(),
              // ));
            },
          ),
          Divider(
            thickness: 1.5,
          ),
          ListTile(
            leading: Icon(Icons.edit_attributes),
            title: Text(
              'Manage Products',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            onTap: () {
              Navigator.of(context)
                  .pushReplacementNamed(UserProductsScreen.routeName);
            },
          ),
          Divider(
            thickness: 1.5,
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text(
              'Logout',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            onTap: () {
              //close drawer
              Navigator.of(context).pop();
              Navigator.of(context)
                  .pushReplacementNamed('/'); //back to home screen
              //logout
              Provider.of<Auth>(context, listen: false).logout();
            },
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart';

class CartItem extends StatelessWidget {
  //const CartItem({Key key}) : super(key: key);
  final String id;
  final String title;
  final int quantity;
  final int price;
  final String productId;

  CartItem({
    this.productId,
    this.id,
    this.title,
    this.quantity,
    this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(productId),
      direction: DismissDirection.startToEnd,
      background: Container(
        color: Theme.of(context).colorScheme.error,
        margin: EdgeInsets.symmetric(horizontal: 12),
        padding: EdgeInsets.all(5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(
              Icons.delete,
              size: 30,
              color: Colors.white,
            ),
            Text(
              'Remove Item',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
      ),
      confirmDismiss: (direction) {
        return showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(
              'Are you sure?',
              style: TextStyle(
                color: Colors.black,
                fontFamily: 'Lato',
              ),
            ),
            content: Text(
              'Do you want to remove the item from the cart?',
            ),
            actionsAlignment: MainAxisAlignment.spaceEvenly,
            actions: <Widget>[
              MaterialButton(
                //color: Color.fromRGBO(154, 243, 255, 1),
                textColor: Theme.of(context).accentColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'No',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              MaterialButton(
                //color: Color.fromRGBO(154, 243, 255, 1),
                textColor: Theme.of(context).accentColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Yes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          ),
        );
      },
      onDismissed: (_) {
        Provider.of<Cart>(context, listen: false).removeItem(productId);
      },
      child: Card(
        elevation: 3,
        color: Color.fromARGB(255, 225, 255, 251),
        margin: EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 4,
        ),
        child: Padding(
          padding: EdgeInsets.all(10),
          child: ListTile(
            leading: CircleAvatar(
              radius: 25,
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: FittedBox(child: Text('₹$price')),
              ),
            ),
            title: Text(
              title,
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            subtitle: Text('Total: ₹${price * quantity}'),
            trailing: Text('$quantity x'),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/edit_product_screen.dart';
import '../providers/products.dart';

class UserProductItem extends StatelessWidget {
  final String id;
  final String title;
  final String imageUrl;
  final double price;

  UserProductItem(this.id, this.title, this.imageUrl, this.price);

  @override
  Widget build(BuildContext context) {
    final scaffold = ScaffoldMessenger.of(context);
    return ListTile(
      title: Text(title),
      leading: CircleAvatar(
        backgroundImage: NetworkImage(imageUrl),
      ),
      subtitle: Text("€${price.toString()}"),
      trailing: Container(
        width: 100,
        child: Row(
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                Navigator.of(context)
                    .pushNamed(EditProductScreen.routeName, arguments: id);
              },
              color: Theme.of(context).primaryColor,
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () async {
                _delete(context);
              },
              color: Theme.of(context).errorColor,
            ),
          ],
        ),
      ),
    );
  }

  void _delete(BuildContext context) async {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: const Text('Attenzione!'),
            content: const Text(
                'Sei sicuro di voler eliminare l' 'articolo dallo store?'),
            actions: [
              // The "Yes" button
              TextButton(
                  onPressed: () async {
                    // Close the dialog
                    try {
                      await Provider.of<Products>(context, listen: false)
                          .deleteProduct(id);
                    } catch (error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Cancellazione non riuscita!',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }
                    Navigator.of(context).pop();
                  },
                  child: const Text('Yes')),
              TextButton(
                  onPressed: () {
                    // Close the dialog
                    Navigator.of(context).pop();
                  },
                  child: const Text('No'))
            ],
          );
        });
  }
}

import 'package:flutter/material.dart';
//import 'package:flutter_complete_guide/providers/orders.dart';
import 'package:provider/provider.dart';

import '../screens/product_detail_screen.dart';
import '../providers/product.dart';
import '../providers/cart.dart';
import '../providers/auth.dart';

class ProductItem extends StatefulWidget {
  @override
  State<ProductItem> createState() => _ProductItemState();
}

class _ProductItemState extends State<ProductItem> {
  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context, listen: true);
    final cart = Provider.of<Cart>(context, listen: false);
    final authData = Provider.of<Auth>(context, listen: false);
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(
              ProductDetailScreen.routeName,
              arguments: product.id,
            );
          },
          child: Hero(
            tag: product.id,
            child: FadeInImage(
              placeholder: AssetImage('assets/images/Loading.jpg'),
              image: NetworkImage(product.imageUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
        header: GridTileBar(
          leading: Consumer<Product>(
            builder: (ctx, product, _) => CircleAvatar(
              backgroundColor: Color.fromARGB(200, 1, 12, 66),
              child: FittedBox(
                alignment: Alignment.center,
                child: Text(
                  '${product.stock} pz.',
                  style: TextStyle(
                    color: Theme.of(context).accentColor,
                  ),
                ),
              ),
            ),
          ),
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '${product.price}€',
                style: TextStyle(
                  color: Theme.of(context).accentColor,
                  fontSize: 20,
                  backgroundColor: Color.fromARGB(200, 1, 12, 66),
                ),
              ),
            ],
          ),
        ),
        footer: GridTileBar(
          backgroundColor: Color.fromARGB(200, 1, 12, 66),
          leading: Consumer<Product>(
            builder: (ctx, product, _) => IconButton(
              icon: Icon(
                product.isFavorite ? Icons.favorite : Icons.favorite_border,
              ),
              color: Theme.of(context).accentColor,
              onPressed: () {
                product.toggleFavoriteStatus(
                  authData.token,
                  authData.userId,
                );
              },
            ),
          ),
          title: Text(product.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).accentColor,
                fontWeight: FontWeight.bold,
              )),
          trailing: IconButton(
            icon: Icon(
              Icons.shopping_cart,
            ),
            onPressed: () {
              if (product.stock <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Non ci sono quantità disponibili!',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              } else {
                cart.addItem(
                  product.id,
                  product.price,
                  product.title,
                  product.stock,
                );
                product.updateStockProduct(authData.token, product.id, -1);
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Aggiunto al carrello!',
                    ),
                    duration: Duration(seconds: 2),
                    action: SnackBarAction(
                      label: 'Annulla',
                      onPressed: () {
                        cart.removeSingleItem(product.id);
                        product.updateStockProduct(
                            authData.token, product.id, 1);
                      },
                    ),
                  ),
                );
              }
            },
            color: Theme.of(context).accentColor,
          ),
        ),
      ),
    );
  }
}

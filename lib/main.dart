import 'package:emarket/providers/product.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/personal_area_screen.dart';
import './screens/splash_screen.dart';
import './screens/cart_screen.dart';
import './screens/products_overview_screen.dart';
import './screens/product_detail_screen.dart';
import './providers/products.dart';
import './providers/user.dart';
import './providers/orders.dart';
import './providers/cart.dart';
import './providers/auth.dart';
import './screens/orders_screen.dart';
import './screens/user_products_screen.dart';
import './screens/edit_product_screen.dart';
import './screens/auth_screen.dart';
import './helpers/custom_route.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, User>(
          create: (ctx) => User(
            authToken: '',
            email: '',
            firstName: '',
            userId: '',
            lastName: '',
            nickName: '',
          ),
          update: (ctx, auth, previousProducts) => User(
              authToken: auth.token,
              userId: auth.userId,
              email: '',
              firstName: '',
              lastName: '',
              nickName: ''),
        ),
        ChangeNotifierProxyProvider<Auth, Products>(
          create: (ctx) => Products('', '', []),
          update: (ctx, auth, previousProducts) => Products(
              auth.token,
              auth.userId,
              previousProducts == null ? [] : previousProducts.items),
        ),
        // ChangeNotifierProxyProvider<Auth, Products>(
        //   builder: (ctx, auth, previousProducts) => Products(
        //         auth.token,
        //         auth.userId,
        //         previousProducts == null ? [] : previousProducts.items,
        //       ),
        // ),
        ChangeNotifierProvider.value(
          value: Cart(),
        ),
        ChangeNotifierProvider.value(
          value: Product(),
        ),
        ChangeNotifierProxyProvider<Auth, Orders>(
          create: (ctx) => Orders('', '', []),
          update: (ctx, auth, previousOrders) => Orders(auth.token, auth.userId,
              previousOrders == null ? [] : previousOrders.orders),
        ),
        // ChangeNotifierProxyProvider<Auth, Orders>(
        //   builder: (ctx, auth, previousOrders) => Orders(
        //     auth.token,
        //     auth.userId,
        //     previousOrders == null ? [] : previousOrders.orders,
        //   ),
        // ),
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
          title: 'E-Market',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            accentColor: Colors.deepOrange,
            fontFamily: 'Lato',
            pageTransitionsTheme: PageTransitionsTheme(
              builders: {
                TargetPlatform.android: CustomPageTransitionBuilder(),
                TargetPlatform.iOS: CustomPageTransitionBuilder(),
              },
            ),
          ),
          home: auth.isAuth
              ? ProductsOverviewScreen()
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (ctx, authResultSnapshot) =>
                      authResultSnapshot.connectionState ==
                              ConnectionState.waiting
                          ? SplashScreen()
                          : AuthScreen(),
                ),
          routes: {
            PersonalAreaScreen.routeName: (ctx) => PersonalAreaScreen(),
            ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
            CartScreen.routeName: (ctx) => CartScreen(),
            OrdersScreen.routeName: (ctx) => OrdersScreen(),
            UserProductsScreen.routeName: (ctx) => UserProductsScreen(),
            EditProductScreen.routeName: (ctx) => EditProductScreen(),
          },
        ),
      ),
    );
  }
}

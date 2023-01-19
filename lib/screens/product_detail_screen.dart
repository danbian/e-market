import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/user_item.dart';
import '../providers/auth.dart';
import '../providers/products.dart';
import '../providers/user.dart';

class ProductDetailScreen extends StatefulWidget {
  static const routeName = '/product-detail';

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  var _productId;
  var _loadedProduct;
  var _isInit = true;
  var _isLoading = false;
  Auth _authData;
  var _ownerUser;
  @override
  void initState() {
    super.initState();
  }

  String pezziRimanenti(int pezzi) {
    if (pezzi == 1) {
      return '${pezzi} pezzo rimanente';
    } else {
      return '${pezzi} pezzi rimanenti';
    }
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      _productId = ModalRoute.of(context).settings.arguments as String;
      _loadedProduct = Provider.of<Products>(
        context,
        listen: false,
      ).findById(_productId);
      _authData = Provider.of<Auth>(context, listen: false);
      // _editedUser.authToken = authData.token;
      Provider.of<User>(context)
          .fetchAndSetUser(
        _authData.token,
        _loadedProduct.creatorId,
      )
          .then((data) {
        setState(() {
          _ownerUser = data;
          _isLoading = false;
        });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Container(
                color: Color.fromARGB(200, 1, 12, 66),
                child: SizedBox(
                  width: double.infinity,
                  child: Text(
                    _loadedProduct.title,
                  ),
                ),
              ),
              background: Hero(
                tag: _loadedProduct.id,
                child: Image.network(
                  _loadedProduct.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                _isLoading
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : UserItem(
                        _ownerUser.nickName,
                        _ownerUser.firstName,
                        _ownerUser.lastName,
                        _ownerUser.email,
                        _loadedProduct.lastUpdate,
                      ),
                // : Text(
                //     'Proprietario: ${_ownerUser.id == null ? 'anonimo' : _ownerUser.firstName}',
                //     style: TextStyle(
                //       color: Colors.grey,
                //       fontSize: 20,
                //     ),
                //     textAlign: TextAlign.center,
                //   ),
                SizedBox(height: 10),
                Text(
                  '€${_loadedProduct.price}',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  '${pezziRimanenti(_loadedProduct.stock)}',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 30,
                ),
                Text(
                  'Descrizione',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  width: double.infinity,
                  child: Text(
                    _loadedProduct.description,
                    textAlign: TextAlign.center,
                    softWrap: true,
                  ),
                ),
                SizedBox(
                  height: 800,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

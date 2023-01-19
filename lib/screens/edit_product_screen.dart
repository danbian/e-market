import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product.dart';
import '../providers/products.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _stockFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  var _editedProduct = Product(
    id: null,
    title: '',
    price: 0,
    description: '',
    imageUrl: '',
    stock: 0,
  );
  var _initValues = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': '',
    'stock': '',
  };
  var _isInit = true;
  var _isLoading = false;

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final productId = ModalRoute.of(context).settings.arguments as String;
      if (productId != null) {
        _editedProduct =
            Provider.of<Products>(context, listen: false).findById(productId);
        _initValues = {
          'title': _editedProduct.title,
          'description': _editedProduct.description,
          'price': _editedProduct.price.toString(),
          'imageUrl': '',
          'stock': _editedProduct.stock.toString(),
        };
        _imageUrlController.text = _editedProduct.imageUrl;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();
    _stockFocusNode.dispose();
    super.dispose();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      if ((!_imageUrlController.text.startsWith('http') &&
              !_imageUrlController.text.startsWith('https')) ||
          (!_imageUrlController.text.endsWith('.png') &&
              !_imageUrlController.text.endsWith('.jpg') &&
              !_imageUrlController.text.endsWith('.jpeg'))) {
        return;
      }
      setState(() {});
    }
  }

  Future<void> _saveForm() async {
    final isValid = _form.currentState.validate();
    if (!isValid) {
      return;
    }
    _form.currentState.save();
    setState(() {
      _isLoading = true;
    });
    if (_editedProduct.id != null) {
      await Provider.of<Products>(context, listen: false)
          .updateProduct(_editedProduct.id, _editedProduct);
    } else {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(_editedProduct);
      } catch (error) {
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('Errore generico!'),
            content: Text('Qualcosa è andato storto.'),
            actions: <Widget>[
              TextButton(
                child: Text('Ok'),
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
              )
            ],
          ),
        );
      }
    }
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modifica Prodotti'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveForm,
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _form,
                child: ListView(
                  children: <Widget>[
                    TextFormField(
                      initialValue: _initValues['title'],
                      decoration: InputDecoration(labelText: 'Titolo'),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_priceFocusNode);
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Inserire un valore.';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editedProduct = Product(
                            title: value,
                            price: _editedProduct.price,
                            description: _editedProduct.description,
                            imageUrl: _editedProduct.imageUrl,
                            id: _editedProduct.id,
                            stock: _editedProduct.stock,
                            isFavorite: _editedProduct.isFavorite);
                      },
                    ),
                    TextFormField(
                      initialValue: _initValues['price'],
                      decoration: InputDecoration(labelText: 'Prezzo'),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      focusNode: _priceFocusNode,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context)
                            .requestFocus(_descriptionFocusNode);
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Inserire un prezzo.';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Inserire un numero valido.';
                        }
                        if (double.parse(value) <= 0) {
                          return 'Inserire un numero maggiroe di zero.';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editedProduct = Product(
                            title: _editedProduct.title,
                            price: double.parse(value),
                            description: _editedProduct.description,
                            imageUrl: _editedProduct.imageUrl,
                            id: _editedProduct.id,
                            stock: _editedProduct.stock,
                            isFavorite: _editedProduct.isFavorite);
                      },
                    ),
                    TextFormField(
                      initialValue: _initValues['stock'],
                      decoration: InputDecoration(labelText: 'Disponibilità'),
                      textInputAction: TextInputAction.next,
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: false),
                      focusNode: _stockFocusNode,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context)
                            .requestFocus(_descriptionFocusNode);
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Inserire una disponibilità.';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Inserire un numero intero valido.';
                        }
                        if (int.parse(value) <= 0) {
                          return 'Inserire un numero maggiroe di zero.';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editedProduct = Product(
                            title: _editedProduct.title,
                            price: _editedProduct.price,
                            description: _editedProduct.description,
                            imageUrl: _editedProduct.imageUrl,
                            id: _editedProduct.id,
                            stock: int.parse(value),
                            isFavorite: _editedProduct.isFavorite);
                      },
                    ),
                    TextFormField(
                      initialValue: _initValues['description'],
                      decoration: InputDecoration(labelText: 'Descrizione'),
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      focusNode: _descriptionFocusNode,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Inserire una descrizione.';
                        }
                        if (value.length < 10) {
                          return 'La lunghezza deve essere minimo di 10 caratteri.';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editedProduct = Product(
                          title: _editedProduct.title,
                          price: _editedProduct.price,
                          description: value,
                          imageUrl: _editedProduct.imageUrl,
                          id: _editedProduct.id,
                          stock: _editedProduct.stock,
                          isFavorite: _editedProduct.isFavorite,
                        );
                      },
                    ),
                    // Row(
                    //   crossAxisAlignment: CrossAxisAlignment.end,
                    //   children: <Widget>[
                    //     Container(
                    //       width: 100,
                    //       height: 100,
                    //       margin: EdgeInsets.only(
                    //         top: 8,
                    //         right: 10,
                    //       ),
                    //       decoration: BoxDecoration(
                    //         border: Border.all(
                    //           width: 1,
                    //           color: Colors.grey,
                    //         ),
                    //       ),
                    //       child: _imageUrlController.text.isEmpty
                    //           ? Text('Inserisci un URL')
                    //           : FittedBox(
                    //               child: Image.network(
                    //                 _imageUrlController.text,
                    //                 fit: BoxFit.cover,
                    //               ),
                    //             ),
                    //     ),
                    //     Expanded(
                    //       child: TextFormField(
                    //         decoration:
                    //             InputDecoration(labelText: 'Immagine URL'),
                    //         keyboardType: TextInputType.url,
                    //         textInputAction: TextInputAction.done,
                    //         controller: _imageUrlController,
                    //         focusNode: _imageUrlFocusNode,
                    //         onFieldSubmitted: (_) {
                    //           _saveForm();
                    //         },
                    //         validator: (value) {
                    //           if (value.isEmpty) {
                    //             return 'Inserisci un immagine URL.';
                    //           }
                    //           if (!value.startsWith('http') &&
                    //               !value.startsWith('https')) {
                    //             return 'Inserire un URL valida.';
                    //           }
                    //           if (!value.endsWith('.png') &&
                    //               !value.endsWith('.jpg') &&
                    //               !value.endsWith('.jpeg')) {
                    //             return 'Inserire un immagine URL valida.';
                    //           }
                    //           return null;
                    //         },
                    //         onSaved: (value) {
                    //           _editedProduct = Product(
                    //             title: _editedProduct.title,
                    //             price: _editedProduct.price,
                    //             description: _editedProduct.description,
                    //             imageUrl: value,
                    //             id: _editedProduct.id,
                    //             isFavorite: _editedProduct.isFavorite,
                    //           );
                    //         },
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Container(
                          width: 100,
                          height: 100,
                          margin: EdgeInsets.only(
                            top: 8,
                            right: 10,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: Colors.grey,
                            ),
                          ),
                          child: _imageUrlController.text.isEmpty
                              ? Text('Inserisci un URL')
                              : FittedBox(
                                  child: Image.network(
                                    _imageUrlController.text,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                        Expanded(
                          child: TextFormField(
                            decoration:
                                InputDecoration(labelText: 'Immagine URL'),
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            controller: _imageUrlController,
                            focusNode: _imageUrlFocusNode,
                            onFieldSubmitted: (_) {
                              _saveForm();
                            },
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Inserisci un immagine URL.';
                              }
                              if (!value.startsWith('http') &&
                                  !value.startsWith('https')) {
                                return 'Inserire un URL valida.';
                              }
                              if (!value.endsWith('.png') &&
                                  !value.endsWith('.jpg') &&
                                  !value.endsWith('.jpeg')) {
                                return 'Inserire un immagine URL valida.';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _editedProduct = Product(
                                title: _editedProduct.title,
                                price: _editedProduct.price,
                                description: _editedProduct.description,
                                imageUrl: value,
                                id: _editedProduct.id,
                                stock: _editedProduct.stock,
                                isFavorite: _editedProduct.isFavorite,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

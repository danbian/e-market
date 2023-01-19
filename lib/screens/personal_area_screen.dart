import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';
import '../providers/user.dart';
import '../widgets/app_drawer.dart';

class PersonalAreaScreen extends StatefulWidget {
  static const routeName = '/personal-area';

  @override
  _PersonalAreaScreenState createState() => _PersonalAreaScreenState();
}

class _PersonalAreaScreenState extends State<PersonalAreaScreen> {
  final _firstNameFocusNode = FocusNode();
  final _lastNameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  var _editedUser = User(
    id: null,
    userId: null,
    nickName: '',
    firstName: '',
    lastName: '',
    email: '',
    authToken: '',
  );
  var _isInit = true;
  var _isLoading = false;
  Auth authData;
  @override
  void initState() {
    //_imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      authData = Provider.of<Auth>(context, listen: false);
      // _editedUser.authToken = authData.token;
      Provider.of<User>(context)
          .fetchAndSetUser(
        authData.token,
        authData.userId,
      )
          .then((data) {
        _editedUser = data;
        setState(() {
          _isLoading = false;
        });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _lastNameFocusNode.dispose();
    _firstNameFocusNode.dispose();
    _emailFocusNode.dispose();
    super.dispose();
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
    if (_editedUser.id != null) {
      await Provider.of<User>(context, listen: false)
          .updateUser(_editedUser.id, _editedUser);
    } else {
      try {
        await Provider.of<User>(context, listen: false).addUser(_editedUser);
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
    Navigator.of(context).pushNamed('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dati Personali'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveForm,
          ),
        ],
      ),
      drawer: AppDrawer(),
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
                      initialValue: _editedUser.nickName,
                      decoration: InputDecoration(labelText: 'Nick Name'),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context)
                            .requestFocus(_firstNameFocusNode);
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Inserire un valore.';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editedUser = User(
                          nickName: value,
                          firstName: _editedUser.firstName,
                          lastName: _editedUser.lastName,
                          email: _editedUser.email,
                          userId: authData.userId,
                          id: _editedUser.id,
                        );
                      },
                    ),
                    TextFormField(
                      initialValue: _editedUser.firstName,
                      decoration: InputDecoration(labelText: 'Nome'),
                      textInputAction: TextInputAction.next,
                      focusNode: _firstNameFocusNode,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_lastNameFocusNode);
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Inserire un nome.';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editedUser = User(
                          nickName: _editedUser.nickName,
                          firstName: value,
                          lastName: _editedUser.lastName,
                          email: _editedUser.email,
                          userId: authData.userId,
                          id: _editedUser.id,
                        );
                      },
                    ),
                    TextFormField(
                      initialValue: _editedUser.lastName,
                      decoration: InputDecoration(labelText: 'Cognome'),
                      textInputAction: TextInputAction.next,
                      focusNode: _lastNameFocusNode,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_emailFocusNode);
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Inserire un cognome.';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editedUser = User(
                          nickName: _editedUser.nickName,
                          firstName: _editedUser.firstName,
                          lastName: value,
                          email: _editedUser.email,
                          userId: authData.userId,
                          id: _editedUser.id,
                        );
                      },
                    ),
                    TextFormField(
                      initialValue: _editedUser.email,
                      decoration: InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      focusNode: _emailFocusNode,
                      onFieldSubmitted: (_) {
                        _saveForm();
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Inserire un email.';
                        }
                        if (value.isEmpty || !value.contains('@')) {
                          return 'Email non valida!';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editedUser = User(
                          nickName: _editedUser.nickName,
                          firstName: _editedUser.firstName,
                          lastName: _editedUser.lastName,
                          email: value,
                          userId: authData.userId,
                          id: _editedUser.id,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

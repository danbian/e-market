import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UserItem extends StatelessWidget {
  final String nickName;
  final String firstName;
  final String lastName;
  final String email;
  final DateTime lastUpdate;

  UserItem(
    this.nickName,
    this.firstName,
    this.lastName,
    this.email,
    this.lastUpdate,
  );

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      //color: Theme.of(context).secondaryHeaderColor,
      child: ListTile(
          leading: CircleAvatar(
            child: Padding(
              padding: EdgeInsets.all(5),
              child: FittedBox(
                child: (nickName == '' || nickName == null)
                    ? Text('--')
                    : Text(
                        '${firstName.toUpperCase().substring(0, 1)}${lastName.toUpperCase().substring(0, 1)}'),
              ),
            ),
          ),
          title: (nickName == '' || nickName == null)
              ? Text('Anonimo')
              : Text(nickName),
          subtitle: (nickName == '' || nickName == null)
              ? Text('Anonimo')
              : Text(email),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Ultimo agg.'),
              Text('${DateFormat('dd-MM-yy').format(lastUpdate)}'),
            ],
          )
          //trailing: Text('$quantity x'),
          ),
    );
  }
}

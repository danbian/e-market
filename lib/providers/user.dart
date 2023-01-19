import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class User with ChangeNotifier {
  final String id;
  final String userId;
  final String nickName;
  final String firstName;
  final String lastName;
  final String email;
  final String authToken;

  User({
    @required this.id,
    @required this.userId,
    @required this.nickName,
    @required this.firstName,
    @required this.lastName,
    @required this.email,
    @required this.authToken,
  });

  Future<User> fetchAndSetUser(String authToken, String userId) async {
    final url =
        'https://flutter-app-81864-default-rtdb.firebaseio.com/users.json?auth=$authToken&orderBy="userId"&equalTo="$userId"';
    final response = await http.get(url);
    final extractedData = json.decode(response.body) as Map<String, dynamic>;
    var id = null;
    var nickName = '';
    var firstName = '';
    var lastName = '';
    var email = '';

    if (extractedData != null) {
      extractedData.forEach((idRecord, userData) {
        id = idRecord;
        nickName = userData['nickName'];
        firstName = userData['firstName'];
        lastName = userData['lastName'];
        email = userData['email'];
      });
    }
    return new User(
      id: id,
      nickName: nickName,
      firstName: firstName,
      lastName: lastName,
      email: email,
      userId: userId,
      authToken: authToken,
    );
  }

  Future<void> addUser(User user) async {
    final url =
        'https://flutter-app-81864-default-rtdb.firebaseio.com/users.json?auth=$authToken';
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'userId': userId,
          'nickName': user.nickName,
          'firstName': user.firstName,
          'lastName': user.lastName,
          'email': user.email,
        }),
      );
      if (json.decode(response.body)['name'] == null) {
        print(json.decode(response.body)['name']);
      }
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> updateUser(String id, User newUser) async {
    final url =
        'https://flutter-app-81864-default-rtdb.firebaseio.com/users/$id.json?auth=$authToken';
    await http.patch(url,
        body: json.encode({
          'nickName': newUser.nickName,
          'firstName': newUser.firstName,
          'lastName': newUser.lastName,
          'email': newUser.email,
        }));
    notifyListeners();
  }
}

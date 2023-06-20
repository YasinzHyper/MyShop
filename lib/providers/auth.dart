import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/htpp_exception.dart';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;
  Timer _authTimer;
  static const params = {
    'key': 'AIzaSyAHZ8WVy1qT6b2Da6YXZwyZFp0kN3_DzmM',
  };

  bool get isAuth {
    return token != null;
  }

  String get token {
    if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  String get userId {
    //return isAuth ? _userId : '';
    return _userId;
  }

  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    final url = Uri.https(
        'identitytoolkit.googleapis.com', '/v1/accounts:$urlSegment', params);
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'email': email,
          'password': password,
          'returnSecureToken': true,
        }),
      );
      //print(response.body);
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryDate = DateTime.now().add(
        //adding to current time
        Duration(
          seconds: int.parse(responseData['expiresIn']),
        ),
      );
      _autoLogout();
      notifyListeners();
      //Writing to Device Storage:
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token': _token,
        'userId': _userId,
        'expiryDate': _expiryDate.toIso8601String(),
      });
      prefs.setString('userData', userData);
    } catch (error) {
      throw error;
    }
  } //Alternative

  Future<void> signup(String email, String password) async {
    return _authenticate(email, password, 'signUp');
    // final url = Uri.https('identitytoolkit.googleapis.com',
    //     '/v1/accounts:signUp?key=AIzaSyAHZ8WVy1qT6b2Da6YXZwyZFp0kN3_DzmM');
    // final response = await http.post(
    //   url,
    //   body: json.encode({
    //     'email': email,
    //     'password': password,
    //     'returnSecureToken': true,
    //   }),
    // );
  }

  Future<void> login(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
    // final url = Uri.https('identitytoolkit.googleapis.com',
    //     '/v1/accounts:signInWithPassword?key=AIzaSyAHZ8WVy1qT6b2Da6YXZwyZFp0kN3_DzmM');
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractedUserData =
        prefs.getString('userData');
    final userData = json.decode(extractedUserData) as Map<String, dynamic>;
    final expiryDate = DateTime.parse(userData['expiryDate'] as String);

    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }

    _token = userData['token'];
    _userId = userData['userId'];
    _expiryDate = expiryDate;

    notifyListeners();
    _autoLogout();
    return true;
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('userData');
    notifyListeners();
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }
}

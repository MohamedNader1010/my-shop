import 'dart:convert';
import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/http_exception.dart';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;
  Timer
      _authTimer; // this is used for if the duration of auto-logout is not reach to end
  // but the user manually logOut , so we have to set it again from start.
  // to do something like so , we need an instance to store our data in.
  // LOOK DOWN AT _autoLogout() & logout() for more understand.

  bool get isAuth {
    return token != null;
  }

  String get token {
    if (_token != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _expiryDate != null) return _token;
  }

  String get userId {
    return _userId;
  }

  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    final url =
        'https://www.googleapis.com/identitytoolkit/v3/relyingparty/$urlSegment?key=AIzaSyBv-rlvnwxmoXrJK-kDLDXlekteAQXEmoA';
    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'email': email,
            'password': password,
            'returnSecureToken': true,
          },
        ),
      );
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        print(responseData['error']['message']); //
        // the problem seems that is belongs to sdkMinVersion
        // which is found in android/app/build.gradle try to upgrade it
        // home internet isa <3
        // NOTE: the probem is solved by unmark break point of uncaughted exception.
        throw new HttpException(responseData['error']['message']);
      }
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(
            responseData['expiresIn'],
          ),
        ),
      );
      _autoLogout();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token': _token,
        'userId': _userId,
        'expiryDate': _expiryDate.toIso8601String(),
      });
      prefs.setString('userData', userData);
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> signup(String email, String password) async {
    return _authenticate(email, password, 'signupNewUser');
  }

  Future<void> login(String email, String password) async {
    return _authenticate(email, password, 'verifyPassword');
  }

  Future<void> logout() async {
    _userId = null;
    _token = null;
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    //prefs.remove('userData'); // delete specific data with a key.
    // or we can use
    prefs.clear();
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    final timeOfExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeOfExpiry), logout);
    notifyListeners();
  }

  Future<bool> tryLogUserIn() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false; // check if there is any data stored on device or not.
      // if not get out of this function.
    }
    final extractedUserData =
        json.decode(prefs.getString('userData')) as Map<String, Object>;
    // remember. json.encode or json.decode are Strings  ex: "{'key1' : value1 , 'key2' : value2,}"
    // so when i decode the incoming data I converted the String into a map of String , Object.
    final expiryUserDate = DateTime.parse(extractedUserData['expiryDate']);
    // in this line i tried to extract the date of expire of user to know if he should continue
    //logout or log him again.
    // as I know i decoded the data as Map<String , Object> so i have to use DateTime.parse()
    // to tell the compiler that data is DateTime type.
    if (expiryUserDate.isBefore(DateTime.now())) {
      return false; // another check!
      // if the date comes from device is before the time now , so it expired.
      // so the user shouldn't auto-login.
    }
    _token = extractedUserData['token'];
    _userId = extractedUserData['userId'];
    _expiryDate = expiryUserDate;
    notifyListeners();
    _autoLogout(); // to set a timer again.
    return true;
  }
}

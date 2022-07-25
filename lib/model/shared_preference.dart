import 'package:flutter_hami/model/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreference {

  Future<bool> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('registrationPin', user.registrationPin!);
    prefs.setString('userName', user.userName!);
    prefs.setString('userMobile', user.userMobile!);
    prefs.setString('userEmail', user.userEmail!);
    prefs.setString('userPassword', user.userPassword!);
    prefs.setString('userCity', user.userCity!);
    return Future.value(true);
  }

  Future<bool> saveUserMobile(String mobile) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('userMobile', mobile);
    return true;
  }

  Future<UserModel> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final registrationPin = prefs.getString('registrationPin');
    final userName = prefs.getString('userName');
    final userMobile = prefs.getString('userMobile');
    final userEmail = prefs.getString('userEmail');
    final userPassword = prefs.getString('userPassword');
    final userCity = prefs.getString('userCity');
    return UserModel(
      registrationPin: registrationPin,
      userName: userName,
      userMobile: userMobile,
      userEmail: userEmail,
      userPassword: userPassword,
      userCity: userCity,
    );
  }

  Future<void> removeUser() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('registrationPin');
    prefs.remove('userName');
    prefs.remove('userMobile');
    prefs.remove('userEmail');
    prefs.remove('userPassword');
    prefs.remove('userCity');
  }

  Future<bool> saveRegistrationPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('registrationPin', pin);
    return true;
  }

  Future<void> removeRegistrationPin() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('registrationPin');
  }

}
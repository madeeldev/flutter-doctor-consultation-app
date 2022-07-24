import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hami/screens/auth/login_page.dart';
import 'package:flutter_hami/model/shared_preference.dart';
import 'package:flutter_hami/screens/auth/verify_pin_page.dart';
import 'package:flutter_hami/screens/dashboard_page.dart';

import 'model/user_model.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((value) => runApp(const MyApp()));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future<UserModel> getUserInfo() => SharedPreference().getUserInfo();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder(
        future: getUserInfo(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return const Scaffold(
                body: CircularProgressIndicator(),
              );
            default:
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (snapshot.data == null) {
                return const LoginPage();
              } else {
                UserModel data = snapshot.data! as UserModel;
                if (data.registrationPin == null && data.userMobile == null) {
                  return const LoginPage();
                } else if (data.registrationPin != null && data.userMobile != null) {
                  return const VerifyPinPage();
                } else {
                  return DashboardPage(
                    mobile: data.userMobile!,
                  );
                }
              }
          }
        },
      ),
    );
  }
}

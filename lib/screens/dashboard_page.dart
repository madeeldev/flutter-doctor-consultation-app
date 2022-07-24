import 'package:flutter/material.dart';
import 'package:flutter_hami/model/shared_preference.dart';
import 'package:flutter_hami/screens/auth/login_page.dart';

class DashboardPage extends StatelessWidget {
  final String mobile;
  const DashboardPage({required this.mobile, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(child: Text('Welcome, $mobile')),
          Container(
            margin : const EdgeInsetsDirectional.only(top: 20),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            color: Colors.pink,
            child: TextButton(
              onPressed: () async {
                await SharedPreference().removeUser().then((_) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const LoginPage(),
                    ), (Route<dynamic> route) => false,
                  );
                });
              },
              child: const Text('Logout', style: TextStyle(color: Colors.white),),
            ),
          ),
        ],
      ),
    );
  }
}

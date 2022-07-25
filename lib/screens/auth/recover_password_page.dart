import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hami/model/shared_preference.dart';
import 'package:flutter_hami/screens/auth/forgot_password_page.dart';
import 'package:flutter_hami/screens/auth/login_page.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../../colors.dart';
import '../../model/user_model.dart';
import '../../services/auth_service.dart';
import '../../widget/connectivity_banner.dart';
import '../../widget/show_dialog.dart';

class RecoverPasswordPage extends StatefulWidget {
  const RecoverPasswordPage({Key? key}) : super(key: key);

  @override
  State<RecoverPasswordPage> createState() => _RecoverPasswordPageState();
}

class _RecoverPasswordPageState extends State<RecoverPasswordPage> {

  final _recoverPassFormKey = GlobalKey<FormState>();

  bool _isLoadingPage = true;
  DateTime? _currentBackPressTime;

  // controllers
  final _passwordCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  // show password
  bool _showPassword = false;

  // user info
  String? _registrationPin = '';
  String _userMobile = '';

  // has internet
  late StreamSubscription internetSubscription;

  @override
  initState() {
    internetSubscription = InternetConnectionChecker().onStatusChange.listen((status) {
      final hasInternet = status == InternetConnectionStatus.connected;
      if(!hasInternet) {
        connectivityBanner(context, 'No internet connection.',
                () => ScaffoldMessenger.of(context).hideCurrentMaterialBanner()
        );
      } else {
        ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
      }
    });
    //
    _loadUserData();
    //
    super.initState();
  }

  _loadUserData() async {
    await SharedPreference().getUserInfo().then((userModel) {
      if (userModel.registrationPin != null && userModel.userMobile != null) {
        setState(() {
          _isLoadingPage = false;
          _registrationPin = userModel.registrationPin;
          if (userModel.userMobile != null) {
            _userMobile = userModel.userMobile!;
          }
        });
      } else {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const ForgotPasswordPage(),
          ),
        );
      }
    });
  }

  // check internet
  Future<bool> _hasInternetConnection() async {
    return await InternetConnectionChecker().hasConnection;
  }

  // validator
  String? _validatePassword (String? val){
    if(val == null || val.isEmpty) {
      return 'Password is required';
    }
    if(val.length < 4) {
      return 'Password must be at least 5 characters long';
    }
    return null;
  }
  String? _validateConfirmPassword (String? val){
    if(val == null || val.isEmpty) {
      return 'Confirm is required';
    }
    if(_passwordCtrl.value.text != val) {
      return 'Confirmation password does not match';
    }
    return null;
  }

  @override
  void dispose() {
    _passwordCtrl.dispose();
    _confirmPassCtrl.dispose();
    internetSubscription.cancel();
    // TODO: implement dispose
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    DateTime now = DateTime.now();
    if (_currentBackPressTime == null ||
        now.difference(_currentBackPressTime!) > const Duration(seconds: 2)) {
      _currentBackPressTime = now;
      Fluttertoast.showToast(
        msg: 'Press back again to exit!',
        toastLength: Toast.LENGTH_SHORT,
      );
      return Future.value(false);
    } else {
      Fluttertoast.cancel();
      setState(() {
        _isLoadingPage = true;
      });
      await SharedPreference().removeUser().then((_) {
        setState(() {
          _isLoadingPage = false;
        });
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (Route<dynamic> route) => false,
        );
      });
      return Future.value(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 0),
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ), (Route<dynamic> route) => false,
                      );
                    },
                    child: const Icon(
                      Icons.arrow_back_ios,
                      size: 20,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.only(right: size.width * 0.06),
                      alignment: Alignment.center,
                      child: const Text(
                        'Recover Password',
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 18
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: size.height * 0.05,),
            Form(
              key: _recoverPassFormKey,
              child: SizedBox(
                height: size.height * 0.70,
                width: double.infinity,
                child:Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Stack(
                        children: [
                          Container(
                            height: 58,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: kColorPrimary.withOpacity(0.2),
                                  blurRadius: 1,
                                  offset: const Offset(
                                      0.0,
                                      3
                                  ),
                                ),
                              ],
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          TextFormField(
                            controller: _passwordCtrl,
                            cursorColor: Colors.black,
                            obscureText: _showPassword ? false : true,
                            decoration: InputDecoration(
                              enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: kColorPrimary, width: 1),
                              ),
                              border: const OutlineInputBorder(),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: kColorPrimary, width: 1),
                              ),
                              hintText: 'Password',
                              suffix: GestureDetector(
                                onTap: () => setState(() => _showPassword = !_showPassword),
                                child: Text(
                                  _showPassword ? 'Hide' : 'Show',
                                ),
                              ),
                              suffixStyle: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            validator: _validatePassword,
                          ),
                        ],
                      ),
                    ),
                    const  SizedBox(height: 15,),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Stack(
                        children: [
                          Container(
                            height: 58,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: kColorPrimary.withOpacity(0.2),
                                  blurRadius: 1,
                                  offset: const Offset(
                                      0.0,
                                      3
                                  ),
                                ),
                              ],
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          TextFormField(
                            controller: _confirmPassCtrl,
                            cursorColor: Colors.black,
                            obscureText: true,
                            decoration: const InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: kColorPrimary, width: 1),
                              ),
                              border: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: kColorPrimary, width: 1),
                              ),
                              hintText: 'Confirm Password',
                            ),
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            validator: _validateConfirmPassword,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20,),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Material(
                        color: kColorPrimary,
                        borderRadius: BorderRadius.circular(2),
                        child: InkWell(
                          onTap: _onPressedChangePassword,
                          child: Container(
                            alignment: Alignment.center,
                            width: double.infinity,
                            height: size.height * 0.065,
                            child: Text(
                              'Change Password',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: size.width * 0.045,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _onPressedChangePassword() {
    bool formValidation = _recoverPassFormKey.currentState!.validate();
    if(formValidation) {
      showDialogBox(context);
      _onPostChangePassword().then((res) {
        final String message = res['message'] ?? 'Error occurred';
        if (message == 'Password updated!') {
          _onDoneChangePassword();
        } else {
          Navigator.pop(context);
          Fluttertoast.showToast(
            msg: message,
            toastLength: Toast.LENGTH_SHORT,
          );
        }
      });
    }
  }

  Future<Map<String, String>> _onPostChangePassword() async {
    // check internet connectivity
    final hasInternet = await _hasInternetConnection();
    if(hasInternet) {
      final user = UserModel(
        userMobile: _userMobile,
        userPassword: _passwordCtrl.value.text
      );
      final res = await AuthService().onVerifyUser(user, false, true);
      return {
        'message' : res,
      };
    }
    return {
      'message' : 'No internet connection',
    };
  }

  _onDoneChangePassword() async {
    Navigator.pop(context);
    await SharedPreference().removeUser().then((_) {
      Fluttertoast.showToast(
        msg: 'Password has been updated.',
        toastLength: Toast.LENGTH_LONG,
      );
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (Route<dynamic> route) => false,
      );
    });
  }

}

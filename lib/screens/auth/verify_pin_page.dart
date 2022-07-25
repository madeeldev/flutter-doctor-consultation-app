import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hami/model/shared_preference.dart';
import 'package:flutter_hami/screens/auth/recover_password_page.dart';
import 'package:flutter_hami/screens/auth/signup_page.dart';
import 'package:flutter_hami/screens/dashboard_page.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'dart:math' as math;
import 'package:http/http.dart' as http;

import '../../colors.dart';
import '../../config.dart';
import '../../model/user_model.dart';
import '../../services/auth_service.dart';
import '../../widget/connectivity_banner.dart';
import '../../widget/show_confirmation_alert.dart';
import '../../widget/show_dialog.dart';
import 'forgot_password_page.dart';

class VerifyPinPage extends StatefulWidget {
  const VerifyPinPage({Key? key}) : super(key: key);

  @override
  State<VerifyPinPage> createState() => _VerifyPinPageState();
}

class _VerifyPinPageState extends State<VerifyPinPage> {

  final _verifyPinFormKey = GlobalKey<FormState>();

  // controllers
  final _num1Ctrl = TextEditingController();
  final _num2Ctrl = TextEditingController();
  final _num3Ctrl = TextEditingController();
  final _num4Ctrl = TextEditingController();

  // LOADING PROGRESS
  bool _isLoadingPage = true;

  // user info
  String? _registrationPin = '';
  String _userName = '';
  String _userMobile = '';
  String _userEmail = '';
  String _userPassword = '';
  String _userCity = '';

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
    super.initState();
    _loadUserData();
  }

  // check internet
  Future<bool> _hasInternetConnection() async {
    return await InternetConnectionChecker().hasConnection;
  }

  _loadUserData() async {
    await SharedPreference().getUserInfo().then((userModel) {
      if (userModel.registrationPin != null) {
        setState(() {
          _isLoadingPage = false;
          _registrationPin = userModel.registrationPin;
          if (userModel.userName != null) {
            _userName = userModel.userName!;
          }
          if (userModel.userMobile != null) {
            _userMobile = userModel.userMobile!;
          }
          if (userModel.userEmail != null) {
            _userEmail = userModel.userEmail!;
          }
          if (userModel.userPassword != null) {
            _userPassword = userModel.userPassword!;
          }
          if (userModel.userCity != null) {
            _userCity = userModel.userCity!;
          }
        });
      } else {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const SignupPage()), (Route<dynamic> route) => false,
        );
      }
    });
  }

  @override
  void dispose() {
    _num1Ctrl.dispose();
    _num2Ctrl.dispose();
    _num3Ctrl.dispose();
    _num4Ctrl.dispose();
    internetSubscription.cancel();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () {
        return Future.value(false);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        drawer: const Drawer(),
        appBar: PreferredSize(
          preferredSize: Size.zero,
          child: AppBar(
            elevation: 0,
            backgroundColor: Colors.white, //ios status bar colors
            systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarColor: Colors.white, //android status bar color
              statusBarBrightness: Brightness.light, // For iOS: (dark icons)
              statusBarIconBrightness:
              Brightness.dark, // For Android: (dark icons)
            ),
          ),
        ),
        body: SafeArea(
          child: _isLoadingPage ? const Center(child: CircularProgressIndicator()) : ListView(
            children: [
              Form(
                key: _verifyPinFormKey,
                child: Container(
                  width: double.infinity,
                  height: size.height,
                  padding: const EdgeInsets.only(left: 24, right: 24, bottom: 60),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            height: 68,
                            width: 64,
                            child: TextFormField(
                              controller: _num1Ctrl,
                              autofocus: true,
                              cursorColor: Colors.black,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(1),
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: kColorPrimary, width: 1),
                                ),
                              ),
                              style: Theme.of(context).textTheme.headline6,
                              onChanged: (textVal) {
                                if(textVal.length == 1) {
                                  FocusScope.of(context).nextFocus();
                                }
                              },
                            ),
                          ),
                          SizedBox(
                            height: 68,
                            width: 64,
                            child: TextFormField(
                              controller: _num2Ctrl,
                              cursorColor: Colors.black,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(1),
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: kColorPrimary, width: 1),
                                ),
                              ),
                              style: Theme.of(context).textTheme.headline6,
                              onChanged: (textVal) {
                                if(textVal.length == 1) {
                                  FocusScope.of(context).nextFocus();
                                }
                              },
                            ),
                          ),
                          SizedBox(
                            height: 68,
                            width: 64,
                            child: TextFormField(
                              controller: _num3Ctrl,
                              cursorColor: Colors.black,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(1),
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: kColorPrimary, width: 1),
                                ),
                              ),
                              style: Theme.of(context).textTheme.headline6,
                              onChanged: (textVal) {
                                if(textVal.length == 1) {
                                  FocusScope.of(context).nextFocus();
                                }
                              },
                            ),
                          ),
                          SizedBox(
                            height: 68,
                            width: 64,
                            child: TextFormField(
                              controller: _num4Ctrl,
                              cursorColor: Colors.black,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(1),
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: kColorPrimary, width: 1),
                                ),
                              ),
                              style: Theme.of(context).textTheme.headline6,
                              onChanged: (textVal) {
                                if(textVal.length == 1) {
                                  FocusScope.of(context).nextFocus();
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20,),
                      Container(
                        padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          color: Colors.grey.shade200,
                        ),
                        child: Column(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const FittedBox(
                                  fit: BoxFit.fitWidth,
                                  child: Text(
                                    'Pin has been sent to your following phone number:',
                                    style: TextStyle(color: kColorPrimary, fontSize: 16),
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                FittedBox(
                                  fit: BoxFit.fitWidth,
                                  child: Text(
                                    _userMobile,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: kColorPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.grey,
                                    primary: Colors.white,
                                  ),
                                  onPressed: _onPressedResendBtn,
                                  child: const Text('RESEND'),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 15,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            height: 50,
                            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                            child: TextButton.icon(
                              style: TextButton.styleFrom(
                                padding:
                                const EdgeInsets.only(right: 15, left: 5),
                                backgroundColor: Colors.white,
                                primary: Colors.black54,
                                side: const BorderSide(
                                  color: Colors.grey,
                                  width: 1,
                                ),
                              ),
                              onPressed: _onPressedBackBtn,
                              label: const Text('BACK'),
                              icon: const Icon(Icons.arrow_left_sharp),
                            ),
                          ),
                          Container(
                            height: 50,
                            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                            child: TextButton.icon(
                              style: TextButton.styleFrom(
                                padding:
                                const EdgeInsets.only(right: 15, left: 5),
                                backgroundColor: Colors.red.shade900,
                                primary: Colors.white,
                              ),
                              onPressed: _onPressedVerifyBtn,
                              label: const Text('VERIFY'),
                              icon: const Icon(Icons.done),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _onPressedResendBtn() async {
    setState(() {
      _isLoadingPage = true;
    });
    _onSendVerificationCodeMessage().then((res) async {
      final message = res['message'];
      if(message == 'Success!') {
        final randomPin = res['randomPin'];
        await SharedPreference().saveRegistrationPin(randomPin).then((_) {
          Fluttertoast.showToast(
            msg: 'Check your text message on $_userMobile',
            toastLength: Toast.LENGTH_LONG,
          );
        });
        setState(() {
          _isLoadingPage = false;
        });
      } else {
        Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_SHORT,
        );
        setState(() {
          _isLoadingPage = false;
        });
      }
    });
  }

  Future<Map<String, dynamic>> _onSendVerificationCodeMessage() async {
    // check internet connectivity
    final hasInternet = await _hasInternetConnection();
    if(hasInternet) {
      final String randomPin = _getRandomPin().toString();
      final String randomPinStr = 'Your%20PIN%20for%20HAMI%20App%20is%20$randomPin.';
      final mobile = _userMobile;
      String res = await AuthService().sendTextMessage(mobile, randomPinStr);
      return {
        'message': res,
        'randomPin': randomPin
      };
    }
    return {
      'message' : 'No internet connection',
    };
  }

  int _getRandomPin() {
    var rnd = math.Random();
    return rnd.nextInt(1000) + 1000;
  }

  _onPressedBackBtn() {
    showConfirmationAlert(
      context,
      _onPressedCancelBtn,
      _onPressedContinueBtn,
      "Warning message",
      "Are you sure you want to exit this page!",
    );
  }

  _onPressedCancelBtn() {
    Navigator.of(context).pop();
  }

  _onPressedContinueBtn() async {
    if (_userName != '' && _userPassword != '') {
      await SharedPreference().removeUser().then((_) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const SignupPage(),
          ), (Route<dynamic> route) => false,
        );
      });
    } else {
      await SharedPreference().removeUser().then((_) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const ForgotPasswordPage(),
          ), (Route<dynamic> route) => false,
        );
      });
    }
  }

  // custom validate form
  bool _customValidateForm() {
    // number 1
    if(_num1Ctrl.value.text.isEmpty) {
      // required
      return false;
    }
    // number 2
    if(_num2Ctrl.value.text.isEmpty) {
      // required
      return false;
    }
    // number 3
    if(_num3Ctrl.value.text.isEmpty) {
      // required
      return false;
    }
    // number 4
    if(_num4Ctrl.value.text.isEmpty) {
      // required
      return false;
    }
    return true;
  }

  _onPressedVerifyBtn() {
    bool customValidation = _customValidateForm();
    if(customValidation) {
      final pinCode = '${_num1Ctrl.value.text}${_num2Ctrl.value.text}${_num3Ctrl.value.text}${_num4Ctrl.value.text}';
        if(_registrationPin == pinCode) {
          showDialogBox(context);
          if (_userName != '' && _userPassword != '') {
            _onVerifyUser().then((res) {
              final String message = res['message'] ?? 'Error occurred';
              debugPrint('verify user message: $message');
              if (message == 'User not found!') {
                _addHamiMaster().then((String addHamiRes) {
                  final String addHamiMessage = addHamiRes;
                  if (addHamiMessage == 'Successful') {
                    _addPublicLogin().then((String addLoginRes) {
                      final String addLoginMessage = addLoginRes;
                      if (addLoginMessage == 'User Created!' || addLoginMessage == 'Success!') {
                        _onDoneRegistration(_userMobile);
                      } else {
                        Navigator.pop(context);
                        Fluttertoast.showToast(
                          msg: addLoginMessage,
                          toastLength: Toast.LENGTH_LONG,
                        );
                      }
                    });
                  } else {
                    Navigator.pop(context);
                    Fluttertoast.showToast(
                      msg: addHamiMessage,
                      toastLength: Toast.LENGTH_LONG,
                    );
                  }
                });
              } else if (message == 'User found!') {
                _addPublicLogin().then((String addLoginRes) {
                  final String addLoginMessage = addLoginRes;
                  debugPrint('addLoginMessage: $addLoginMessage');
                  if (addLoginMessage == 'User Created!' || addLoginMessage == 'Success!') {
                    _onDoneRegistration(_userMobile);
                  } else {
                    Navigator.pop(context);
                    Fluttertoast.showToast(
                      msg: addLoginMessage,
                      toastLength: Toast.LENGTH_LONG,
                    );
                  }
                });
              } else {
                Navigator.pop(context);
                Fluttertoast.showToast(
                  msg: message,
                  toastLength: Toast.LENGTH_LONG,
                );
              }
            });
          } else {
            Navigator.pop(context);
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const RecoverPasswordPage()),
              (Route<dynamic> route) => false,
            );
          }
        } else {
          Fluttertoast.showToast(
            msg: 'Invalid PIN CODE',
            toastLength: Toast.LENGTH_LONG,
          );
        }
    } else {
      Fluttertoast.showToast(
        msg: 'Please enter PIN CODE',
        toastLength: Toast.LENGTH_LONG,
      );
    }
  }

  Future<Map<String, String>> _onVerifyUser() async {
    // check internet connectivity
    final hasInternet = await _hasInternetConnection();
    if(hasInternet) {
      final mobile = _userMobile;
      final user = UserModel(
        userMobile: mobile,
      );
      final res = await AuthService().onVerifyUser(user, true);
      return {
        'message' : res,
      };
    }
    return {
      'message' : 'No internet connection',
    };
  }

  Future<String> _addHamiMaster() async {
    try {
      final url = Config.addHamiMaster;
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, List<Map<String, String>>>{
          'Hami_Master': [
            {
              "HM_Mobile": _userMobile,
              "HM_Name": _userName,
              "HM_Email": _userEmail,
              "HM_CNIC": "-",
              "HM_City_Code": _userCity
            }
          ],
        }),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body)['message'];
      } else {
        return 'Server Error occurred!';
      }
    } on SocketException catch (_) {
      return 'Internet is not connected!';
    }
  }

  Future<String> _addPublicLogin() async {
    try {
      final url = '${Config.loginUrl}?module=${Config.loginModule}&mobile=$_userMobile&pwd=$_userPassword&upd=0&ins=1&api_key=${Config.apiKey}';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return json.decode(response.body)['PUBLIC_LOGIN__Result'][0]['Remarks'];
      } else {
        return 'Server Error occurred';
      }
    } on SocketException catch (_) {
      return 'Internet is not connected!';
    }
  }

  _onDoneRegistration(String mobile) async {
    await SharedPreference().removeRegistrationPin().then((_) {
      Navigator.pop(context);
      Fluttertoast.showToast(
        msg: 'Your account has been created.',
        toastLength: Toast.LENGTH_LONG,
      );
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (context) => DashboardPage(
              mobile: mobile,
            )), (Route<dynamic> route) => false,
      );
    });
  }
}

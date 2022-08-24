import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hami/screens/auth/login_page.dart';
import 'package:flutter_hami/screens/auth/verify_pin_page.dart';
import 'package:flutter_hami/widget/show_dialog.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'dart:math' as math;

import '../../colors.dart';
import '../../constants.dart';
import '../../model/shared_preference.dart';
import '../../model/user_model.dart';
import '../../services/auth_service.dart';
import '../../widget/connectivity_banner.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {

  // controller
  final _phoneNumberCtrl = TextEditingController();

  // errorMessages
  String _phoneNumberErrMsg = '';

  // node
  final _phoneNumberNode = FocusNode();

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
  }

  // check internet
  Future<bool> _hasInternetConnection() async {
    return await InternetConnectionChecker().hasConnection;
  }

  _validatePhoneNumber(String? val) {
    setState(() {
      if(val != null && val.isNotEmpty) {
        if(RegExp(r'^[0-9]*$').hasMatch(val)) {
          if(val.length == 10) {
            _phoneNumberErrMsg = '';
          } else {
            _phoneNumberErrMsg = 'Invalid phone number length';
          }
        } else {
          _phoneNumberErrMsg = 'Invalid phone number';
        }
      } else {
        _phoneNumberErrMsg = 'Phone number is required';
      }
    });
  }

  @override
  void dispose() {
    _phoneNumberCtrl.dispose();
    internetSubscription.cancel();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
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
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: SafeArea(
          child: ListView(
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
                          'Forgot Password',
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
              SizedBox(
                height: size.height * 0.75,
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Stack(
                        children: [
                          Container(
                            height: 60,
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
                          Column(
                            children: [
                              Container(
                                alignment: Alignment.center,
                                height: 60,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(color: kColorPrimary, width: kInputBorderWidth, style: BorderStyle.solid,),
                                ),
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                      child: GestureDetector(
                                        onTap: () {
                                          FocusScope.of(context).requestFocus(_phoneNumberNode);
                                        },
                                        child: Row(
                                          children: [
                                            Container(
                                              alignment: Alignment.center,
                                              padding: const EdgeInsets.only(bottom: 1),
                                              child: Text(
                                                '+',
                                                style: TextStyle(
                                                  color: kColorPrimary,
                                                  fontSize: size.width*0.038,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              '92',
                                              style: TextStyle(
                                                color: kColorPrimary,
                                                fontSize: size.width*0.035,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: 1,
                                      color: kColorPrimary.withOpacity(0.5),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 15),
                                        child: TextFormField(
                                          focusNode: _phoneNumberNode,
                                          controller: _phoneNumberCtrl,
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [
                                            LengthLimitingTextInputFormatter(10),
                                          ],
                                          cursorColor: Colors.black,
                                          decoration: const InputDecoration(
                                              border: InputBorder.none,
                                              hintText: 'Phone Number'
                                          ),
                                          autovalidateMode: AutovalidateMode.onUserInteraction,
                                          onChanged: _validatePhoneNumber,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                height: _phoneNumberErrMsg.isEmpty ? 0: null,
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 6, left: 16),
                                  child: Text(
                                    _phoneNumberErrMsg,
                                    style: const TextStyle(
                                      color: kColorPrimary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ],
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
                          onTap: _onPressedForgotPass,
                          child: Container(
                            alignment: Alignment.center,
                            width: double.infinity,
                            height: size.height * 0.065,
                            child: Text(
                              'Forgot Password',
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
            ],
          ),
        ),
      ),
    );
  }

  // custom validate form
  bool _customValidateForm() {
    // phone number
    if(_phoneNumberCtrl.value.text.isEmpty) {
      // required
      return false;
    } else {
      // not a number
      if(RegExp(r'^[a-z]+$').hasMatch(_phoneNumberCtrl.value.text)) {
        return false;
      } else {
        // invalid length
        if(_phoneNumberCtrl.value.text.length < 10) {
          return false;
        }
      }
    }
    return true;
  }

  _onPressedForgotPass() {
    // custom inputs error messages
    _validatePhoneNumber(_phoneNumberCtrl.value.text);
    // forms validate
    bool customValidation = _customValidateForm();
    if(customValidation) {
      showDialogBox(context);
      _onVerifyUser().then((res) {
        final String message = res['message'] ?? 'Error occurred';
        if (message == 'User found!') {
          _onSendVerificationCodeMessage().then((postRes) {
            final sendMessage = postRes['message'];
            if(sendMessage == 'Success!') {
              final randomPin = postRes['randomPin'];
              final phoneNumber = '92${_phoneNumberCtrl.value.text}';
              SharedPreference().saveUserMobile(phoneNumber).then((_) {
                SharedPreference().saveRegistrationPin(randomPin).then((value) {
                  Navigator.pop(context);
                  Fluttertoast.showToast(
                    msg: 'Check your text message on $phoneNumber',
                    toastLength: Toast.LENGTH_LONG,
                  );
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const VerifyPinPage(),
                    ),
                  );
                });
              });
            } else {
              Navigator.pop(context);
              Fluttertoast.showToast(
                msg: sendMessage,
                toastLength: Toast.LENGTH_SHORT,
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
    }
  }

  Future<Map<String, String>> _onVerifyUser() async {
    // check internet connectivity
    final hasInternet = await _hasInternetConnection();
    if(hasInternet) {
      final mobile = '92${_phoneNumberCtrl.value.text}';
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

  Future<Map<String, dynamic>> _onSendVerificationCodeMessage() async {
    // check internet connectivity
    final hasInternet = await _hasInternetConnection();
    if(hasInternet) {
      final String randomPin = _getRandomPin().toString();
      final String randomPinStr = 'Your%20PIN%20for%20HAMI%20App%20is%20$randomPin.';
      final mobile = '92${_phoneNumberCtrl.value.text}';
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

  //
  int _getRandomPin() {
    var rnd = math.Random();
    return rnd.nextInt(1000) + 1000;
  }
}

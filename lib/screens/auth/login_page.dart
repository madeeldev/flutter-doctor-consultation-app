import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hami/colors.dart';
import 'package:flutter_hami/model/shared_preference.dart';
import 'package:flutter_hami/model/user_model.dart';
import 'package:flutter_hami/screens/auth/signup_page.dart';
import 'package:flutter_hami/screens/dashboard_page.dart';
import 'package:flutter_hami/services/auth_service.dart';
import 'package:flutter_hami/widget/connectivity_banner.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../../constants.dart';
import '../../widget/show_dialog.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final _loginFormKey = GlobalKey<FormState>();

  // errorMessages
  String _phoneNumberErrMsg = '';

  // controllers
  final _phoneNumberCtrl = TextEditingController(text: '3007918427');
  final _passwordCtrl = TextEditingController(text: 'abc123');

  // show password
  bool _showPassword = false;

  // node
  final _phoneNumberNode = FocusNode();

  // has internet
  late StreamSubscription internetSubscription;

  @override
  initState() {
    internetSubscription = InternetConnectionChecker().onStatusChange.listen((status) {
      final hasInternet = status == InternetConnectionStatus.connected;
      if(!hasInternet) {
        connectivityBanner(context, 'No internet connection.', () => ScaffoldMessenger.of(context).hideCurrentMaterialBanner());
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

  // validators
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
  String? _validatePassword (String? val){
    if(val == null || val.isEmpty) {
      return 'Password is required';
    }
    if(val.length < 4) {
      return 'Password must be at least 5 characters long';
    }
    return null;
  }

  @override
  void dispose() {
    _phoneNumberCtrl.dispose();
    _passwordCtrl.dispose();
    internetSubscription.cancel();
    // TODO: implement dispose
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const Drawer(),
      appBar: PreferredSize(
        preferredSize: Size.zero,
        child: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,//ios status bar colors
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.white,//android status bar color
            statusBarBrightness: Brightness.light, // For iOS: (dark icons)
            statusBarIconBrightness: Brightness.dark, // For Android: (dark icons)
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
              Form(
                key: _loginFormKey,
                child: Column(
                  children: [
                    SizedBox(
                      height: size.height * 0.43,
                      child: Image.asset('assets/images/hami_logo.png'),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: SizedBox(
                        width: size.width,
                        height: 60,
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
                    ),
                    const SizedBox(height: 15,),
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
                    const SizedBox(height: 15,),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: Container(
                        alignment: Alignment.topRight,
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(color: kColorPrimary, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20,),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Material(
                        color: kColorPrimary,
                        borderRadius: BorderRadius.circular(2),
                        child: InkWell(
                          onTap: _onPressedLogin,
                          child: Container(
                            alignment: Alignment.center,
                            width: double.infinity,
                            height: size.height * 0.065,
                            child: Text(
                              'Login',
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
                    const SizedBox(height: 20,),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SizedBox(
                        width: size.width * 0.8,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Don\'t have an account ? ', style: TextStyle(fontSize: 13, color: Color(0xff2d2d2d), fontWeight: FontWeight.bold),),
                            GestureDetector(
                              onTap: () => {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const SignupPage()))
                              },
                              child: const Text('Sign-up', style: TextStyle(fontSize: 15, color: kColorPrimary, fontWeight: FontWeight.bold),),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20,),
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

  _onPressedLogin() {
    // custom inputs error messages
    _validatePhoneNumber(_phoneNumberCtrl.value.text);
    // forms validate
    bool customValidation = _customValidateForm();
    bool formValidation = _loginFormKey.currentState!.validate();
    // if validated
    if (customValidation && formValidation) {
      showDialogBox(context);
      _onPostLogin().then((res) {
        final String message = res['message'] ?? 'Error occurred';
        if(message == 'Success!') {
          _onDoneLogin();
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

  Future<Map<String, String>> _onPostLogin() async {
    // check internet connectivity
    final hasInternet = await _hasInternetConnection();
    if(hasInternet) {
      final mobile = '92${_phoneNumberCtrl.value.text}';
      final password = _passwordCtrl.value.text;
      final user = UserModel(
        userMobile: mobile,
        userPassword: password,
      );
      final res = await AuthService().onPostLogin(user);
      return {
        'message' : res,
      };
    } else {
      return {
        'message' : 'No internet connection',
      };
    }
  }

  _onDoneLogin() {
    final mobile = '92${_phoneNumberCtrl.value.text}';
    SharedPreference().saveUserMobile(mobile).then((_) {
      Navigator.pop(context);
      Fluttertoast.showToast(
        msg: 'Welcome, you have successfully logged in',
        toastLength: Toast.LENGTH_SHORT,
      );
      // dashboard
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => DashboardPage(
            mobile: mobile,
          ),
        ), (Route<dynamic> route) => false,
      );
    });
  }

}

import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hami/model/shared_preference.dart';
import 'package:flutter_hami/screens/auth/login_page.dart';
import 'package:flutter_hami/screens/auth/verify_pin_page.dart';
import 'package:flutter_hami/screens/privacy_policy_page.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../../colors.dart';
import '../../constants.dart';
import 'package:flutter_hami/config.dart';

import '../../model/user_model.dart';
import '../../services/auth_service.dart';
import '../../widget/connectivity_banner.dart';
import '../../widget/show_dialog.dart';
import '../terms_and_conditions_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _signupFormKey = GlobalKey<FormState>();

  List _dropdownItems = [];
  bool _isChecked = true;

  // errorMessages
  String _phoneNumberErrMsg = '';
  String _cityErrMsg = '';

  // controllers
  final _nameCtrl = TextEditingController();
  final _phoneNumberCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  // show password
  bool _showPassword = false;

  // selected city
  String? _selectedCity;

  // node
  final _phoneNumberNode = FocusNode();

  // has internet
  late StreamSubscription internetSubscription;

  @override
  initState() {
    internetSubscription =
        InternetConnectionChecker().onStatusChange.listen((status) {
      final hasInternet = status == InternetConnectionStatus.connected;
      if (!hasInternet) {
        connectivityBanner(context, 'No internet connection.',
            () => ScaffoldMessenger.of(context).hideCurrentMaterialBanner());
      } else {
        ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
      }
    });
    //
    getCitiesData();
    //
    super.initState();
  }

  // check internet
  Future<bool> _hasInternetConnection() async {
    return await InternetConnectionChecker().hasConnection;
  }

  // get cities
  Future getCitiesData() async {
    try {
      var res = await http.get(Uri.parse(Config.citiesUrl));
      var resBody = json.decode(res.body);
      final cities = resBody[Config.citiesResult];
      setState(() {
        _dropdownItems = cities;
      });
    } catch (e) {
      debugPrint('Error occurred: $e');
    }
  }

  // validators
  String? _validateName(val) {
    if (val == null || val.isEmpty) {
      return 'Name is required';
    }
    return null;
  }

  _validatePhoneNumber(String? val) {
    setState(() {
      if (val != null && val.isNotEmpty) {
        if (RegExp(r'^[0-9]*$').hasMatch(val)) {
          if (val.length == 10) {
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

  String? _validateEmail(String? val) {
    if (val == null || val.isEmpty) {
      return 'Email is required';
    }
    if (!EmailValidator.validate(val)) {
      return 'Please enter valid email';
    }
    return null;
  }

  String? _validatePassword(String? val) {
    if (val == null || val.isEmpty) {
      return 'Password is required';
    }
    if (val.length < 4) {
      return 'Password must be at least 5 characters long';
    }
    return null;
  }

  String? _validateConfirmPassword(String? val) {
    if (val == null || val.isEmpty) {
      return 'Confirm is required';
    }
    if (_passwordCtrl.value.text != val) {
      return 'Confirmation password does not match';
    }
    return null;
  }

  _validateCity() {
    setState(() {
      if (_selectedCity != null && _selectedCity!.isNotEmpty) {
        _cityErrMsg = '';
      } else {
        _cityErrMsg = 'Selection of City is required';
      }
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneNumberCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPassCtrl.dispose();
    internetSubscription.cancel();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    //
    Color getColor(Set<MaterialState> states) {
      const Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.pressed,
        MaterialState.hovered,
        MaterialState.focused,
      };
      if (states.any(interactiveStates.contains)) {
        return Colors.blue;
      }
      return kColorPrimary;
    }

    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const LoginPage(),
          ),
              (Route<dynamic> route) => false,
        );
        return Future.value(true);
      },
      child: Scaffold(
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
                Form(
                  key: _signupFormKey,
                  child: Column(children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 20, 18, 0),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (context) => const LoginPage(),
                                ),
                                (Route<dynamic> route) => false,
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
                                'Signup',
                                style: TextStyle(
                                    fontWeight: FontWeight.w500, fontSize: 18),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: size.height * 0.05,
                    ),
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
                                  offset: const Offset(0.0, 3),
                                ),
                              ],
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          TextFormField(
                            controller: _nameCtrl,
                            cursorColor: Colors.black,
                            decoration: const InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: kColorPrimary, width: 1),
                              ),
                              border: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: kColorPrimary, width: 1),
                              ),
                              hintText: 'Full Name',
                            ),
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            validator: _validateName,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
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
                                  offset: const Offset(0.0, 3),
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
                                  border: Border.all(
                                    color: kColorPrimary,
                                    width: kInputBorderWidth,
                                    style: BorderStyle.solid,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: GestureDetector(
                                        onTap: () {
                                          FocusScope.of(context)
                                              .requestFocus(_phoneNumberNode);
                                        },
                                        child: Row(
                                          children: [
                                            Container(
                                              alignment: Alignment.center,
                                              padding: const EdgeInsets.only(
                                                  bottom: 1),
                                              child: Text(
                                                '+',
                                                style: TextStyle(
                                                  color: kColorPrimary,
                                                  fontSize: size.width * 0.038,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              '92',
                                              style: TextStyle(
                                                color: kColorPrimary,
                                                fontSize: size.width * 0.035,
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
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 15),
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
                                              hintText: 'Phone Number'),
                                          autovalidateMode:
                                              AutovalidateMode.onUserInteraction,
                                          onChanged: _validatePhoneNumber,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                height: _phoneNumberErrMsg.isEmpty ? 0 : null,
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(top: 6, left: 16),
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
                    const SizedBox(
                      height: 15,
                    ),
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
                                  offset: const Offset(0.0, 3),
                                ),
                              ],
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          TextFormField(
                            controller: _emailCtrl,
                            cursorColor: Colors.black,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: kColorPrimary, width: 1),
                              ),
                              border: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: kColorPrimary, width: 1),
                              ),
                              hintText: 'Email',
                            ),
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            validator: _validateEmail,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
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
                                  offset: const Offset(0.0, 3),
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
                                borderSide:
                                    BorderSide(color: kColorPrimary, width: 1),
                              ),
                              border: const OutlineInputBorder(),
                              focusedBorder: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: kColorPrimary, width: 1),
                              ),
                              hintText: 'Password',
                              suffix: GestureDetector(
                                onTap: () => setState(
                                    () => _showPassword = !_showPassword),
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
                    const SizedBox(
                      height: 15,
                    ),
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
                                  offset: const Offset(0.0, 3),
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
                                borderSide:
                                    BorderSide(color: kColorPrimary, width: 1),
                              ),
                              border: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: kColorPrimary, width: 1),
                              ),
                              hintText: 'Confirm Password',
                            ),
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            validator: _validateConfirmPassword,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
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
                                  offset: const Offset(0.0, 3),
                                ),
                              ],
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          Column(
                            children: [
                              Container(
                                alignment: Alignment.center,
                                height: 58,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                    color: kColorPrimary,
                                    width: kInputBorderWidth,
                                    style: BorderStyle.solid,
                                  ),
                                ),
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 15),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      hint: const Text('Select City'),
                                      isExpanded: true,
                                      value: _selectedCity,
                                      onChanged: (selectedVal) {
                                        setState(() {
                                          _selectedCity = selectedVal;
                                          _cityErrMsg = '';
                                        });
                                      },
                                      // items: const [],
                                      items: _dropdownItems.map((cityItem) {
                                        return DropdownMenuItem(
                                          value: cityItem['City_Code'].toString(),
                                          child: Text(cityItem['City_Desc']),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                height: _cityErrMsg.isEmpty ? 0 : null,
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(top: 6, left: 16),
                                  child: Text(
                                    _cityErrMsg,
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
                    const SizedBox(
                      height: 15,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: [
                          Checkbox(
                            checkColor: Colors.white,
                            fillColor:
                                MaterialStateProperty.resolveWith(getColor),
                            value: _isChecked,
                            onChanged: (bool? value) {
                              setState(() {
                                _isChecked = value!;
                              });
                            },
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isChecked = !_isChecked;
                                  });
                                },
                                child: const Text(
                                  'I have read and agree to all',
                                ),
                              ),
                              const SizedBox(
                                height: 3,
                              ),
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const TermsAndConditionsPage(),
                                      ),
                                    ),
                                    child: Text(
                                      'Terms & Conditions',
                                      style: TextStyle(
                                          color: Colors.blueAccent,
                                          fontSize: size.width * 0.035,
                                          letterSpacing: 0.5),
                                    ),
                                  ),
                                  const Text(' and '),
                                  GestureDetector(
                                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const PrivacyPolicyPage())),
                                    child: Text(
                                      'Privacy Policy',
                                      style: TextStyle(
                                        color: Colors.blueAccent,
                                        fontSize: size.width * 0.035,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Material(
                        color: kColorPrimary,
                        borderRadius: BorderRadius.circular(2),
                        child: InkWell(
                          onTap: _onPressedSignup,
                          child: Container(
                            alignment: Alignment.center,
                            width: double.infinity,
                            height: size.height * 0.065,
                            child: Text(
                              'Signup',
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
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Already have an account ? ',
                          style: TextStyle(
                              fontSize: 13,
                              color: Color(0xff2d2d2d),
                              fontWeight: FontWeight.bold),
                        ),
                        GestureDetector(
                          onTap: () => {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const LoginPage()))
                          },
                          child: const Text(
                            'Log-in',
                            style: TextStyle(
                                fontSize: 15,
                                color: kColorPrimary,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                  ]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // custom validate form
  bool _customValidateForm() {
    // phone number
    if (_phoneNumberCtrl.value.text.isEmpty) {
      // required
      return false;
    } else {
      // not a number
      if (RegExp(r'^[a-z]+$').hasMatch(_phoneNumberCtrl.value.text)) {
        return false;
      } else {
        // invalid length
        if (_phoneNumberCtrl.value.text.length < 10) {
          return false;
        }
      }
    }
    // city
    if (_selectedCity == null || _selectedCity!.isEmpty) {
      // required
      return false;
    }
    return true;
  }

  //
  _onPressedSignup() {
    // custom inputs error messages
    _validatePhoneNumber(_phoneNumberCtrl.value.text);
    _validateCity();
    // forms validate
    bool customValidation = _customValidateForm();
    bool formValidation = _signupFormKey.currentState!.validate();
    // if validated
    if (customValidation && formValidation) {
      // check for term & conditions
      if (!_isChecked) {
        Fluttertoast.showToast(
          msg: "Please tick the checkbox to accept our customer agreements",
          toastLength: Toast.LENGTH_SHORT,
        );
      } else {
        showDialogBox(context);
        _onVerifyUser().then((res) {
          final String message = res['message'] ?? 'Error occurred';
          if (message == 'User found!') {
            Navigator.pop(context);
            Fluttertoast.showToast(
              msg: 'User with this mobile already exist.',
              toastLength: Toast.LENGTH_SHORT,
            );
          } else if (message == 'User not found!') {
            _onSendVerificationCodeMessage().then((postRes) {
              final sendMessage = postRes['message'];
              if (sendMessage == 'Success!') {
                // create user
                final randomPin = postRes['randomPin'];
                UserModel user = UserModel(
                  registrationPin: randomPin,
                  userName: _nameCtrl.value.text,
                  userMobile: '92${_phoneNumberCtrl.value.text}',
                  userEmail: _emailCtrl.value.text,
                  userPassword: _passwordCtrl.value.text,
                  userCity: _selectedCity,
                );
                SharedPreference().saveUser(user).then((_) {
                  Navigator.pop(context);
                  Fluttertoast.showToast(
                    msg:
                        'Check your text message on 92${_phoneNumberCtrl.text}',
                    toastLength: Toast.LENGTH_LONG,
                  );
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const VerifyPinPage(),
                    ),
                  );
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
              toastLength: Toast.LENGTH_SHORT,
            );
          }
        });
      }
    }
  }

  Future<Map<String, String>> _onVerifyUser() async {
    // check internet connectivity
    final hasInternet = await _hasInternetConnection();
    if (hasInternet) {
      final mobile = '92${_phoneNumberCtrl.value.text}';
      final user = UserModel(
        userMobile: mobile,
      );
      final res = await AuthService().onVerifyUser(user, true);
      return {
        'message': res,
      };
    }
    return {
      'message': 'No internet connection',
    };
  }

  //
  Future<Map<String, dynamic>> _onSendVerificationCodeMessage() async {
    // check internet connectivity
    final hasInternet = await _hasInternetConnection();
    if (hasInternet) {
      final String randomPin = _getRandomPin().toString();
      final String randomPinStr =
          'Your%20PIN%20for%20HAMI%20App%20is%20$randomPin.';
      final mobile = '92${_phoneNumberCtrl.value.text}';
      String res = await AuthService().sendTextMessage(mobile, randomPinStr);
      return {'message': res, 'randomPin': randomPin};
    }
    return {
      'message': 'No internet connection',
    };
  }

  //
  int _getRandomPin() {
    var rnd = math.Random();
    return rnd.nextInt(1000) + 1000;
  }
}

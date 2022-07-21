import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hami/colors.dart';
import 'package:flutter_hami/screens/auth/signup_page.dart';

import '../../constants.dart';

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
  final _phoneNumberCtrl = TextEditingController();

  // show password
  bool _showPassword = false;

  // bottom SizedBox heights
  double _passwordBottom = 15;

  // validators
  _validatePhoneNumber(String? val) {
    setState(() {
      if(val != null && val.isNotEmpty) {
        if(!RegExp(r'^[a-z]+$').hasMatch(val)) {
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
      SchedulerBinding.instance.addPostFrameCallback((duration) {
        setState(() => _passwordBottom = 5);
      });
      return 'Password is required';
    }
    if(val.length < 4) {
      SchedulerBinding.instance.addPostFrameCallback((duration) {
        setState(() => _passwordBottom = 5);
      });
      return 'Password must be at least 5 characters long!';
    }
    SchedulerBinding.instance.addPostFrameCallback((duration) {
      setState(() => _passwordBottom = 15);
    });
    return null;
  }

  @override
  void dispose() {
    _phoneNumberCtrl.dispose();
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
                      child: Column(
                        children: [
                          Container(
                            alignment: Alignment.center,
                            height: size.height * 0.07,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(color: kColorPrimary, width: kInputBorderWidth, style: BorderStyle.solid,),
                            ),
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  child: Row(
                                    children: [
                                      Container(
                                        alignment: Alignment.center,
                                        padding: const EdgeInsets.only(bottom: 1),
                                        child: Text(
                                          '+',
                                          style: TextStyle(
                                              color: Colors.black.withOpacity(0.7),
                                              fontSize: size.width*0.040,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '92',
                                        style: TextStyle(
                                          color: Colors.black.withOpacity(0.7),
                                          fontSize: size.width*0.040,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 1.5,
                                  height: size.height * 0.04,
                                  color: Colors.grey,
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 15),
                                    child: TextFormField(
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
                    ),
                    const SizedBox(height: 15,),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: TextFormField(
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
                          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: size.height * 0.023),
                        ),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: _validatePassword,
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
                          onTap: _handleLogin,
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
    // // password
    // if(_passwordCtrl.value.text.isEmpty) {
    //   // required
    //   return false;
    // } else {
    //   // invalid length
    //   if(_passwordCtrl.value.text.length < 4) {
    //     return false;
    //   }
    // }
    return true;
  }

  _handleLogin() {

    // custom form error messages
    _validatePhoneNumber(_phoneNumberCtrl.value.text);
    //
    bool customValidation = _customValidateForm();
    bool formValidation = _loginFormKey.currentState!.validate();
    // if validated
    if (customValidation && formValidation) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Submitting data..')),
      );
    }

  }
}

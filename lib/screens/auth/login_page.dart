import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hami/colors.dart';
import 'package:flutter_hami/screens/auth/signup_page.dart';
import 'package:flutter_hami/services/network_service.dart';
import 'package:provider/provider.dart';

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
  final _phoneNumberCtrl = TextEditingController(text: '3007918427');

  // show password
  bool _showPassword = false;

  // node
  final _phoneNumberNode = FocusNode();

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
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    // check internet
    NetworkStatus networkStatus = Provider.of<NetworkStatus>(context, listen: true);
    WidgetsBinding.instance.addPostFrameCallback((_){
      debugPrint('Network Status: $networkStatus');
      if(networkStatus == NetworkStatus.offline) {
        _showBanner('No internet connection.');
      } else {
        _showBanner('Back online');
      }
    });
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
                            initialValue: 'Abc123',
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
      NetworkStatus networkStatus = Provider.of<NetworkStatus>(context, listen: false);
      if(networkStatus == NetworkStatus.offline) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No internet connection')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Submitting data..')),
        );
      }
    }
  }

  void _showBanner(String contentText) => ScaffoldMessenger.of(context)
    ..removeCurrentMaterialBanner()
    ..showMaterialBanner(
      MaterialBanner(
        elevation: 1,
        backgroundColor: Colors.black87,
        leadingPadding: const EdgeInsets.only(right: 12),
        content: Text(
          contentText,
          overflow: TextOverflow.ellipsis,
          // style: TextStyle(fontSize: 12),
        ),
        contentTextStyle: const TextStyle(color: Colors.white),
        forceActionsBelow: true,
        actions: [
          TextButton(
              onPressed: _hideBanner,
              child: const Text('Dismiss', style: TextStyle(color: Colors.white),),
          ),
        ],
      )
  );

  void _hideBanner() {
    ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
  }
}

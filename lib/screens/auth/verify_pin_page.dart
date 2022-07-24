import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hami/model/shared_preference.dart';
import 'package:flutter_hami/screens/auth/signup_page.dart';

import '../../colors.dart';

class VerifyPinPage extends StatefulWidget {
  const VerifyPinPage({Key? key}) : super(key: key);

  @override
  State<VerifyPinPage> createState() => _VerifyPinPageState();
}

class _VerifyPinPageState extends State<VerifyPinPage> {

  final _verifyPinFormKey = GlobalKey<FormState>();

  // LOADING PROGRESS
  bool _isLoadingPage = true;

  // user info
  String? _registrationPin = '';
  String _userName = '';
  String _userMobile = '';
  String _userEmail = '';
  String _userPassword = '';
  String _userCity = '';

  @override
  initState() {
    super.initState();
    _loadUserData();
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
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
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
        child: _isLoadingPage ? const CircularProgressIndicator() : ListView(
          children: [
            Form(
              key: _verifyPinFormKey,
              child: Container(
                width: double.infinity,
                height: size.height,
                padding: const EdgeInsets.symmetric(horizontal: 24),
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
                            autofocus: true,
                            cursorColor: Colors.black,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(1),
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: const InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: kColorPrimary, width: 1),
                              ),
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
                            cursorColor: Colors.black,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(1),
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: const InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: kColorPrimary, width: 1),
                              ),
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
                            cursorColor: Colors.black,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(1),
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: const InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: kColorPrimary, width: 1),
                              ),
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
                            cursorColor: Colors.black,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(1),
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: const InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: kColorPrimary, width: 1),
                              ),
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
                                  'Pin has been sent to your following mobile number:',
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
                                    fontSize: 14,
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
                                onPressed: () {},
                                child: const Text('RESEND'),
                              ),
                            ],
                          )
                        ],
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
}

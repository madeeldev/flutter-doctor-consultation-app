import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hami/screens/auth/login_page.dart';

import '../../colors.dart';
import '../../constants.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {

  final _signupFormKey = GlobalKey<FormState>();

  final List<String> _dropdownItems = ['Lahore', 'Karachi'];
  bool _isChecked = false;

  // errorMessages
  String _phoneNumberErrMsg = '';
  String _cityErrMsg = '';

  // controllers
  final _phoneNumberCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  // show password
  bool _showPassword = false;

  // selected city
  String? _selectedCity;

  // node
  final _phoneNumberNode = FocusNode();

  // validators
  String? _validateName(val){
    if(val == null || val.isEmpty) {
      return 'Name is required';
    }
    return null;
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
  String? _validateEmail(String? val) {
    if(val == null || val.isEmpty) {
      return 'Email is required';
    }
    if(!EmailValidator.validate(val)) {
      return 'Please enter valid email';
    }
    return null;
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
  String? _validateConfirmPassword (String? val){
    if(val == null || val.isEmpty) {
      return 'Confirm is required';
    }
    if(_passwordCtrl.value.text != _confirmPassCtrl.value.text) {
      return 'Confirmation password does not match';
    }
    return null;
  }
  _validateCity() {
    setState(() {
      if(_selectedCity != null && _selectedCity!.isNotEmpty) {
        _cityErrMsg = '';
      } else {
        _cityErrMsg = 'Selection of City is required';
      }
    });
  }

  @override
  void dispose() {
    _phoneNumberCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPassCtrl.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

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
                          onTap: () => Navigator.pop(context),
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
                          cursorColor: Colors.black,
                          decoration: const InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: kColorPrimary, width: 1),
                            ),
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: kColorPrimary, width: 1),
                            ),
                            hintText: 'Full Name',
                          ),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: _validateName,
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
                          cursorColor: Colors.black,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: kColorPrimary, width: 1),
                            ),
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: kColorPrimary, width: 1),
                            ),
                            hintText: 'Email',
                          ),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: _validateEmail,
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
                          cursorColor: Colors.black,
                          obscureText: _showPassword ? false : true,
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
                        Column(
                          children: [
                            Container(
                              alignment: Alignment.center,
                              height: 58,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(color: kColorPrimary, width: kInputBorderWidth, style: BorderStyle.solid,),
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 15),
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
                                    items: _dropdownItems.map((String items) {
                                      return DropdownMenuItem<String>(
                                        value: items,
                                        child: Text(items),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              height: _cityErrMsg.isEmpty ? 0: null,
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 6, left: 16),
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
                  const  SizedBox(height: 15,),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        Checkbox(
                          checkColor: Colors.white,
                          fillColor: MaterialStateProperty.resolveWith(getColor),
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
                            const SizedBox(height: 3,),
                            Row(
                              children: [
                                Text(
                                  'Terms & Conditions',
                                  style: TextStyle(
                                      color: Colors.blueAccent,
                                      fontSize: size.width*0.035,
                                      letterSpacing: 0.5
                                  ),
                                ),
                                const Text(' and '),
                                Text(
                                  'Privacy Policy',
                                  style: TextStyle(
                                    color: Colors.blueAccent,
                                    fontSize: size.width*0.035,
                                    letterSpacing: 0.5
                                  ),
                                ),
                              ],
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
                        onTap: _handleSignup,
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
                  const SizedBox(height: 20,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Already have an account ? ', style: TextStyle(fontSize: 13, color: Color(0xff2d2d2d), fontWeight: FontWeight.bold),),
                      GestureDetector(
                        onTap: () => {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage()))
                        },
                        child: const Text('Log-in', style: TextStyle(fontSize: 15, color: kColorPrimary, fontWeight: FontWeight.bold),),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20,),
                ]),
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
    // city
    if(_selectedCity == null || _selectedCity!.isEmpty) {
      // required
      return false;
    }
    return true;
  }

  //
  _handleSignup() {
    // custom form error messages
    _validatePhoneNumber(_phoneNumberCtrl.value.text);
    _validateCity();
    //
    bool customValidation = _customValidateForm();
    bool formValidation = _signupFormKey.currentState!.validate();
    // if validated
    if (customValidation && formValidation) {
      // check for term & conditions
      if(!_isChecked) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please tick the checkbox to accept our Customer Agreement')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Submitting data..')),
        );
      }
    }
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../../services/member_service.dart';
import '../../widget/connectivity_banner.dart';
import '../../widget/show_dialog.dart';
import '../dashboard_page.dart';

const kColorBg = Color(0xfff2f6fe);

class AskUsPage extends StatefulWidget {
  final String mobile;
  const AskUsPage({required this.mobile, Key? key}) : super(key: key);

  @override
  State<AskUsPage> createState() => _AskUsPageState();
}

class _AskUsPageState extends State<AskUsPage> {
  // select member
  String? _selectMember;

  // data
  List<dynamic> _membersData = [];

  // check if page is loaded
  bool _isPageLoaded = false;

  // checked terms & conditions
  bool _isChecked = false;

  // error message
  String _messageError = '';

  // controller
  final _messageCtrl = TextEditingController();

  // has internet
  late StreamSubscription internetSubscription;

  @override
  void initState() {
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
    // load members data
    _loadMembersData();
    super.initState();
  }

  // check internet
  Future<bool> _hasInternetConnection() async {
    return await InternetConnectionChecker().hasConnection;
  }

  Future _loadMembersData() async {
    // check internet connectivity
    final hasInternet = await _hasInternetConnection();
    if (hasInternet) {
      final membersData = await MemberService().onLoadMembers(widget.mobile);
      final message = membersData['message'];
      if (message == 'success') {
        final data = membersData['data'];
        if (data.isNotEmpty) {
          _selectMember = data[0]['HP_ID'].toString();
        }
        _membersData = data;
        _isPageLoaded = true;
        setState(() {});
      } else {
        Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_LONG,
        );
      }
    } else {
      Fluttertoast.showToast(
        msg: 'No internet connection',
        toastLength: Toast.LENGTH_LONG,
      );
    }
  }

  @override
  void dispose() {
    _messageCtrl.dispose();
    internetSubscription.cancel();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => DashboardPage(
              mobile: widget.mobile,
            ),
          ),
              (Route<dynamic> route) => false,
        );
        return Future.value(true);
      },
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
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
          body: _isPageLoaded
              ? ListView(
                  children: [
                    SizedBox(
                      width: size.width,
                      height: size.height,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(18, 20, 18, 0),
                            child: Row(
                              children: [
                                InkWell(
                                  onTap: () {
                                    Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(
                                        builder: (context) => DashboardPage(
                                          mobile: widget.mobile,
                                        ),
                                      ),
                                      (Route<dynamic> route) => false,
                                    );
                                  },
                                  child: const Icon(
                                    Icons.arrow_back_ios,
                                    size: 18,
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    padding:
                                        EdgeInsets.only(right: size.width * 0.06),
                                    alignment: Alignment.center,
                                    child: const Text(
                                      'Ask US',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 18),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: DropdownButtonFormField<String>(
                              isExpanded: true,
                              hint: const Align(
                                alignment: Alignment.centerLeft,
                                child: Text('Select an option'),
                              ),
                              value: _selectMember,
                              borderRadius: BorderRadius.circular(10),
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.only(
                                  left: 20,
                                  right: 15,
                                  bottom: 12,
                                  top: 12,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: const BorderSide(
                                      color: Colors.grey, width: 1),
                                ),
                              ),
                              items: _membersData.map((item) {
                                return DropdownMenuItem(
                                  value: item['HP_ID'].toString(),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item['HP_Name'],
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (String? val) {
                                setState(() {
                                  _selectMember = val;
                                });
                              },
                            ),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(bottom: 20),
                                  child: const Text(
                                    'Send Us A Message',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Container(
                                  height: 200,
                                  margin: const EdgeInsets.only(
                                    left: 20,
                                    right: 20,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 15,
                                    horizontal: 18,
                                  ),
                                  decoration: BoxDecoration(
                                    color: kColorBg,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: TextFormField(
                                    controller: _messageCtrl,
                                    cursorColor: Colors.black,
                                    keyboardType: TextInputType.multiline,
                                    maxLines: null,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.zero,
                                      isDense: true,
                                      hintText: 'Your message',
                                    ),
                                    onChanged: _validateForm,
                                  ),
                                ),
                                Container(
                                  height: _messageError.isEmpty ? 0 : 15,
                                  margin: _messageError.isNotEmpty ? const EdgeInsets.only(
                                    left: 25,
                                    top: 5,
                                  ) : EdgeInsets.zero,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    _messageError,
                                    style: TextStyle(
                                      color: Colors.red[900],
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(
                                    top: 20,
                                    left: 20,
                                    right: 30,
                                    bottom: 20,
                                  ),
                                  height: 60,
                                  child: Row(
                                    children: [
                                      Checkbox(
                                        value: _isChecked,
                                        onChanged: (bool? val){
                                          setState(() {
                                            _isChecked = val!;
                                          });
                                        }
                                      ),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _isChecked = !_isChecked;
                                            });
                                          },
                                          child: const Text(
                                            'I agree to share my particulars, basic information & medical record with admin and concerned health care professional',
                                            style: TextStyle(
                                              fontSize: 13,
                                              letterSpacing: 0.6,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  width: size.width,
                                  margin: const EdgeInsets.only(
                                    left: 60,
                                    right: 60,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red[900],
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: TextButton(
                                    onPressed: _onPressedSendMsg,
                                    child: const Text(
                                      'Send Message',
                                      style: TextStyle(
                                        color: Colors.white,
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
                  ],
                )
              : const Center(
                  child: CircularProgressIndicator(),
                ),
        ),
      ),
    );
  }
  //
  _validateForm(String? val) {
    if(val != null && val.isNotEmpty) {
      _messageError = '';
    } else {
      _messageError = 'Please write your message into input box';
    }
    setState(() {});
  }
  //
  _onPressedSendMsg() async {
    _validateForm(_messageCtrl.text);
    if(_messageCtrl.text.isNotEmpty) {
      if(_isChecked == true) {
        // check internet connectivity
        final hasInternet = await _hasInternetConnection();
        if (hasInternet) {
          _onPostSendMsg();
        } else {
          Fluttertoast.showToast(
            msg: 'No internet connection',
            toastLength: Toast.LENGTH_LONG,
          );
        }
      } else {
        Fluttertoast.showToast(
          msg: 'Please tick checkbox to accept our terms',
          toastLength: Toast.LENGTH_LONG,
        );
      }
    }
  }
  //
  _onPostSendMsg() async {
    showDialogBox(context);
    final result = await MemberService().onSendMemberMsg(
        widget.mobile,
        _selectMember!,
        _messageCtrl.text
    );
    _onDoneSendMsg(result);
  }
  //
  _onDoneSendMsg(result) {
    Navigator.of(context).pop();
    final message = result['message'];
    if (message == 'success') {
      final data = result['data'];
      final remarks = data[0]['remarks'];
      if(remarks == 'Success!') {
        _messageCtrl.clear();
        Fluttertoast.showToast(
          msg: 'Message sent successfully. Please wait we will get back to you with answer',
          toastLength: Toast.LENGTH_LONG,
        );
      } else {
        Fluttertoast.showToast(
          msg: remarks,
          toastLength: Toast.LENGTH_LONG,
        );
      }
    } else {
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
      );
    }
  }
  //
}

import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hami/colors.dart';
import 'package:flutter_hami/model/shared_preference.dart';
import 'package:flutter_hami/screens/auth/login_page.dart';
import 'package:flutter_hami/screens/user/ask_us_page.dart';
import 'package:flutter_hami/screens/user/awareness_material_page.dart';
import 'package:flutter_hami/screens/user/members_page.dart';
import 'package:flutter_hami/screens/user/notification_page.dart';
import 'package:flutter_hami/screens/user/record_page.dart';
import 'package:badges/badges.dart';
import 'package:flutter_hami/screens/user/medicine_page.dart';
import 'package:flutter_hami/services/member_service.dart';
import 'package:flutter_hami/services/notification_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../widget/connectivity_banner.dart';

enum UserClickMenu {
  onClickNotification,
  onClickMembers,
  onClickRecord,
  onClickAwarenessMaterial,
  onClickMedicine,
  onClickAskUs,
}

class DashboardPage extends StatefulWidget {
  final String mobile;
  const DashboardPage({
    required this.mobile,
    Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // notifications count
  int? _notificationCount;

  DateTime? _currentBackPressTime;

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
    // load notifications data
    _loadNotificationData();
    _handleAppNotifications();
    super.initState();
  }

  // check internet
  Future<bool> _hasInternetConnection() async {
    return await InternetConnectionChecker().hasConnection;
  }

  _loadNotificationData() async {
    // check internet connectivity
    final hasInternet = await _hasInternetConnection();
    if (hasInternet) {
      final result = await MemberService().onLoadMemberNotifications(
        widget.mobile,
      );
      final message = result['message'];
      if (message == 'success') {
        final data = result['data'];
        final newData = data.where((n) => n['HAA_IsViewed'] == false).toList();
        _notificationCount = newData.isNotEmpty ? newData.length : null;
        if (mounted) {
          setState(() {});
        }
      }
    }
  }

  _handleAppNotifications() {
    // only works when app is terminated
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        debugPrint('✅ FUNCTION CALLED: getInitialMessage');
        Navigator.push(context, MaterialPageRoute(builder: (_) => NotificationPage(mobile: widget.mobile,)));
      }
    });
    //
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('✅ FUNCTION CALLED: onMessage');
      NotificationService.display(message);
      if(_notificationCount != null) {
        _notificationCount = _notificationCount! + 1;
      } else {
        _notificationCount = 1;
      }
      setState(() {});
    });
    // only works if app in background but not terminated
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('✅ FUNCTION CALLED: onMessageOpenedApp');
      RemoteNotification? remoteNotification = message.notification;
      AndroidNotification? androidNotification = message.notification?.android;
      if(remoteNotification != null && androidNotification != null) {
        Navigator.push(context, MaterialPageRoute(builder: (_) => NotificationPage(mobile: widget.mobile)));
      }
    });
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
      return Future.value(true);
    }
  }

  @override
  void dispose() {
    internetSubscription.cancel();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.zero,
          child: AppBar(
            elevation: 0,
            backgroundColor: kColorPrimary, //ios status bar colors
            systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarColor: kColorPrimary, //android status bar color
              statusBarBrightness: Brightness.dark, // For iOS: (dark icons)
              statusBarIconBrightness:
                  Brightness.light, // For Android: (dark icons)
            ),
          ),
        ),
        body: ListView(
          children: [
            // header
            Container(
              width: double.infinity,
              height: size.height * 0.33,
              decoration: const BoxDecoration(
                color: kColorPrimary,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 20,
                    right: 20,
                    child: Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      child: InkWell(
                        onTap: () =>
                            _handleUserClick(UserClickMenu.onClickNotification),
                        borderRadius: BorderRadius.circular(10),
                        child: Badge(
                          showBadge: _notificationCount != null ? true : false,
                          badgeContent: _notificationCount != null
                              ? Text(
                                  '$_notificationCount',
                                  style: const TextStyle(color: Colors.black),
                                )
                              : null,
                          animationType: BadgeAnimationType.scale,
                          badgeColor: Colors.greenAccent,
                          child: SizedBox(
                            height: 40,
                            width: 40,
                            child: Stack(
                              children: [
                                const Center(
                                    child: Icon(
                                  Icons.notifications_none_outlined,
                                  size: 30,
                                )),
                                Positioned(
                                  top: 12,
                                  right: 10,
                                  child: Container(
                                    padding: const EdgeInsets.all(1),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Container(
                                      height: 5,
                                      width: 5,
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: Colors.grey,
                          shape: BoxShape.circle,
                        ),
                        child: Container(
                          height: size.height * 0.13,
                          width: size.height * 0.13,
                          decoration: const BoxDecoration(
                              color: Colors.white38,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white,
                                  offset: Offset.zero,
                                  blurRadius: 30,
                                  spreadRadius: 8,
                                  blurStyle: BlurStyle.inner,
                                ),
                              ]),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: size.height * 0.13,
                                width: size.height * 0.13,
                                child: const CircleAvatar(
                                  backgroundColor: Colors.white,
                                  backgroundImage: AssetImage(
                                    'assets/images/header.png',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // body
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        height: size.height * 0.17,
                        width: size.width * 0.44,
                        child: Card(
                          elevation: 5,
                          shadowColor: Colors.black,
                          color: Colors.white,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                          child: InkWell(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(20),
                            ),
                            onTap: () =>
                                _handleUserClick(UserClickMenu.onClickMembers),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.groups,
                                  size: size.height * 0.05,
                                  color: Colors.deepPurple,
                                ),
                                SizedBox(
                                  child: Text(
                                    'Members',
                                    style: TextStyle(
                                      fontSize: size.height * 0.018,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  child: Text(
                                    'ممبرز',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontFamily: 'Jameel-Noori-Nastaleeq',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: size.height * 0.17,
                        width: size.width * 0.44,
                        child: Card(
                          elevation: 5,
                          shadowColor: Colors.black,
                          color: Colors.white,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(20),
                            ),
                          ),
                          child: InkWell(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(20),
                            ),
                            onTap: () =>
                                _handleUserClick(UserClickMenu.onClickRecord),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.description,
                                  size: size.height * 0.05,
                                  color: Colors.orange,
                                ),
                                SizedBox(
                                  child: Text(
                                    'Record',
                                    style: TextStyle(
                                      fontSize: size.height * 0.018,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  child: Text(
                                    'ریکارڈ',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontFamily: 'Jameel-Noori-Nastaleeq',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        height: size.height * 0.17,
                        width: size.width * 0.44,
                        child: Card(
                          elevation: 5,
                          shadowColor: Colors.black,
                          color: Colors.white,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(20),
                            ),
                          ),
                          child: InkWell(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(20),
                            ),
                            onTap: () => _handleUserClick(
                                UserClickMenu.onClickAwarenessMaterial),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.highlight,
                                  size: size.height * 0.05,
                                  color: Colors.green,
                                ),
                                SizedBox(
                                  child: Text(
                                    'Awareness',
                                    style: TextStyle(
                                      fontSize: size.height * 0.018,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  child: Text(
                                    'material',
                                    style: TextStyle(
                                      fontSize: size.height * 0.018,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  child: Text(
                                    'آگاہی',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontFamily: 'Jameel-Noori-Nastaleeq',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: size.height * 0.17,
                        width: size.width * 0.44,
                        child: Card(
                          elevation: 5,
                          shadowColor: Colors.black,
                          color: Colors.white,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(20),
                            ),
                          ),
                          child: InkWell(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(20),
                            ),
                            onTap: () =>
                                _handleUserClick(UserClickMenu.onClickMedicine),
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.medication_liquid,
                                    size: size.height * 0.05,
                                    color: Colors.indigo,
                                  ),
                                  SizedBox(
                                    child: Text(
                                      'Medicine',
                                      style: TextStyle(
                                        fontSize: size.height * 0.018,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    child: Text(
                                      'ادویات',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontFamily: 'Jameel-Noori-Nastaleeq',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        height: size.height * 0.17,
                        width: size.width * 0.44,
                        child: Card(
                          elevation: 5,
                          shadowColor: Colors.black,
                          color: Colors.white,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(20),
                            ),
                          ),
                          child: InkWell(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(20),
                            ),
                            onTap: () =>
                                _handleUserClick(UserClickMenu.onClickAskUs),
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.chat,
                                    size: size.height * 0.05,
                                    color: Colors.blueAccent,
                                  ),
                                  SizedBox(
                                    child: Text(
                                      'Ask Us',
                                      style: TextStyle(
                                        fontSize: size.height * 0.018,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    child: Text(
                                      'جانئیے',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontFamily: 'Jameel-Noori-Nastaleeq',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: size.height * 0.17,
                        width: size.width * 0.44,
                        child: Card(
                          elevation: 5,
                          shadowColor: Colors.black,
                          color: Colors.white,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                          child: InkWell(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(20),
                            ),
                            onTap: _onPressedLogout,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.exit_to_app,
                                    size: size.height * 0.05,
                                    color: kColorPrimary,
                                  ),
                                  SizedBox(
                                    child: Text(
                                      'Logout',
                                      style: TextStyle(
                                        fontSize: size.height * 0.018,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    child: Text(
                                      'لاگ آوٹ',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontFamily: 'Jameel-Noori-Nastaleeq',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _handleUserClick(UserClickMenu menu) async {
    // check internet connectivity
    final hasInternet = await _hasInternetConnection();
    if (hasInternet) {
      switch (menu) {
        case UserClickMenu.onClickNotification:
          _onPressedNotification();
          break;
        case UserClickMenu.onClickMembers:
          _onPressedMembers();
          break;
        case UserClickMenu.onClickRecord:
          _onPressedRecord();
          break;
        case UserClickMenu.onClickAwarenessMaterial:
          _onPressedAwarenessMaterial();
          break;
        case UserClickMenu.onClickMedicine:
          _onPressedMedicine();
          break;
        case UserClickMenu.onClickAskUs:
          _onPressedAskUs();
          break;
      }
    } else {
      Fluttertoast.showToast(
        msg: 'No internet connection',
        toastLength: Toast.LENGTH_LONG,
      );
    }
  }

  //
  _onPressedMembers() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MembersPage(
          mobile: widget.mobile,
        ),
      ),
    );
  }

  //
  _onPressedRecord() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecordPage(
          mobile: widget.mobile,
        ),
      ),
    );
  }

  //
  _onPressedAwarenessMaterial() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AwarenessMaterialPage(
          mobile: widget.mobile,
        ),
      ),
    );
  }

  //
  _onPressedMedicine() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MedicinePage(
          mobile: widget.mobile,
        ),
      ),
    );
  }

  //
  _onPressedAskUs() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AskUsPage(
          mobile: widget.mobile,
        ),
      ),
    );
  }

  //
  _onPressedNotification() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotificationPage(
          mobile: widget.mobile,
        ),
      ),
    );
  }

  //
  _onPressedLogout() async {
    await SharedPreference().removeUser().then((_) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const LoginPage(),
        ),
        (Route<dynamic> route) => false,
      );
    });
  }
}

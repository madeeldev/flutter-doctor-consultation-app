import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hami/widget/show_dialog_html.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:intl/intl.dart';

import '../../model/shared_preference.dart';
import '../../services/member_service.dart';
import '../../widget/connectivity_banner.dart';
import '../dashboard_page.dart';

const kColorBg = Color(0xfff2f6fe);

class NotificationPage extends StatefulWidget {
  final String? mobile;
  const NotificationPage({this.mobile, Key? key}) : super(key: key);

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  // data
  List<dynamic> _notificationData = [];

  // check if page is loaded
  bool _isPageLoaded = false;
  String? _mobile;

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
    _loadUserData();
    super.initState();
  }

  _loadUserData() async {
    final data = await SharedPreference().getUserInfo();
    if(widget.mobile == null) {
      _mobile = data.userMobile;
    } else {
      _mobile = widget.mobile;
    }
    _loadNotificationData();
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
        _mobile!,
      );
      final message = result['message'];
      if (message == 'success') {
        final data = result['data'];
        _notificationData = data;
        debugPrint(_notificationData.toString());
        _isPageLoaded = true;
        setState(() {});
      }
    } else {
      _isPageLoaded = true;
      setState(() {});
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
      onWillPop: () async {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => DashboardPage(mobile: widget.mobile!)),
              (Route<dynamic> route) => false,
        );
        return Future.value(true);
      },
      child: Scaffold(
        backgroundColor: kColorBg,
        appBar: PreferredSize(
          preferredSize: Size.zero,
          child: AppBar(
            elevation: 0,
            backgroundColor: kColorBg, //ios status bar colors
            systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarColor: kColorBg, //android status bar color
              statusBarBrightness: Brightness.light, // For iOS: (dark icons)
              statusBarIconBrightness:
                  Brightness.dark, // For Android: (dark icons)
            ),
          ),
        ),
        body: SizedBox(
          width: size.width,
          height: size.height,
          child: _isPageLoaded
              ? Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 20, 18, 0),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      DashboardPage(mobile: _mobile!),
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
                              padding: EdgeInsets.only(right: size.width * 0.06),
                              alignment: Alignment.center,
                              child: const Text(
                                'Notifications',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(
                        left: 20,
                        bottom: 8,
                      ),
                      child: const Text(
                        'All notifications list',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(child: _buildShowNotification()),
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
  Widget _buildShowNotification() {
    Size size = MediaQuery.of(context).size;
    return _notificationData.isNotEmpty
        ? ListView.builder(
            itemCount: _notificationData.length,
            itemBuilder: (_, idx) {
              return Material(
                color: _notificationData[idx]['HAA_IsViewed']
                    ? Colors.white.withOpacity(0.5)
                    : const Color(0xFFeceff5),
                child: InkWell(
                  onTap: () => _onPressedNotification(
                        _notificationData[idx]['HA_Question'],
                        _notificationData[idx]['HAA_Answer'],
                        _notificationData[idx]['HAA_ID'],
                        _notificationData[idx]['HAA_IsViewed']
                      ),
                  child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey.withOpacity(0.5),
                            width: 1,
                            style: BorderStyle.solid,
                          ),
                        )),
                    child: Column(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              SizedBox(
                                width: size.width * 0.16,
                                height: double.maxFinite,
                                child: Container(
                                  margin: EdgeInsets.all(size.width * 0.035),
                                  decoration: const BoxDecoration(
                                    color: Colors.black,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.notifications,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 2,
                                    right: 10,
                                    top: 5,
                                    bottom: 10,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text.rich(
                                        TextSpan(
                                          children: [
                                            const TextSpan(
                                              text: 'Answer for your question: ',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.black,
                                              ),
                                            ),
                                            TextSpan(
                                              text: _notificationData[idx]
                                                  ['HA_Question'],
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(
                                        height: 1,
                                      ),
                                      Text(
                                        DateFormat('MMM dd, yyyy')
                                            .format(DateTime.now()),
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                        ),
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
            },
          )
        : Container(
            margin: EdgeInsets.only(
              bottom: size.height * 0.15,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.notifications_off_sharp,
                  size: 80,
                  color: Colors.redAccent,
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text(
                  'No notifications',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text(
                  'When you have notification\n you\'ll see then here',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) =>
                          DashboardPage(mobile: _mobile!),
                    ),
                  ),
                  child: const Text(
                    'Go Back',
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          );
  }
  //
  _onPressedNotification(String q, String a, int aId, bool isViewed) {//question, answer, askAnswerId, isAnswerViewed
    showDialogHtml(context, 'View Answer', a, [
      TextButton(
        style: TextButton.styleFrom(
          primary: Colors.blue,
        ),
        child: const Text("View Question"),
        onPressed: () => _onPressedViewQuestion(q),
      ),
      TextButton(
        style: TextButton.styleFrom(
          primary: Colors.blue,
        ),
        child: const Text("Close"),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
    ]);
    if(isViewed == false) {
      _updateNotification(aId);
    }
  }
  //
  _onPressedViewQuestion(String q) {
    Navigator.of(context).pop();
    showDialogHtml(context, 'View Question', q, [
      TextButton(
        style: TextButton.styleFrom(
          primary: Colors.blue,
        ),
        child: const Text("Hide"),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
    ]);
  }
  //
  _updateNotification(int aId) async {
    // check internet connectivity
    final hasInternet = await _hasInternetConnection();
    if (hasInternet) {
     _onPostUpdateNotification(aId);
    }
  }
  //
  _onPostUpdateNotification(int aId) async {
    final result = await MemberService().onUpdateMemberNotification(aId);
    final message = result['message'];
    if(message == 'success') {
      final data = result['data'];
      final remarks = data[0]['remarks'];
      if(remarks == 'Success!') {
        final notificationData = _notificationData;
        final notification = notificationData.where((e) => e['HAA_ID'] == aId).first;
        final index = notificationData.indexOf(notification);
        notificationData[index]['HAA_IsViewed'] = true;
        setState(() {});
      } else {
        debugPrint(remarks);
      }
    } else {
      debugPrint(message);
    }
  }
}

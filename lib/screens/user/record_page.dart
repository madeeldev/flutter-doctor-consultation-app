import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hami/screens/dashboard_page.dart';
import 'package:flutter_hami/screens/user/record_add_page.dart';
import 'package:flutter_hami/services/member_service.dart';
import 'package:flutter_hami/widget/connectivity_banner.dart';
import 'package:flutter_hami/widget/show_confirmation_alert.dart';
import 'package:flutter_hami/widget/show_dialog.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:intl/intl.dart';

import '../../colors.dart';

const kColorBg = Color(0xfff2f6fe);

enum Menu { removeRecord }

class RecordPage extends StatefulWidget {
  final String mobile;
  final String? memberId;
  const RecordPage({required this.mobile, this.memberId, Key? key})
      : super(key: key);

  @override
  State<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  // select member
  String? _selectMember;

  // data
  List<dynamic> _membersData = [];
  List<dynamic> _memberRecordData = [];

  // check if page is loaded
  bool _isPageLoaded = false;
  bool _isPageDataLoaded = true;

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
        if (widget.memberId != null) {
          _selectMember = widget.memberId;
        } else {
          if (data.isNotEmpty) {
            _selectMember = data[0]['HP_ID'].toString();
          }
        }
        _membersData = data;
        await _loadMemberRecordData();
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

  //
  Future _loadMemberRecordData() async {
    // check internet connectivity
    final hasInternet = await _hasInternetConnection();
    if (hasInternet) {
      if (_selectMember != null) {
        final memberRecordData = await MemberService()
            .onLoadMemberRecord(widget.mobile, _selectMember!);
        final message = memberRecordData['message'];
        if (message == 'success') {
          final data = memberRecordData['data'];
          setState(() {
            _memberRecordData = data;
            _isPageLoaded = true;
          });
        }
      } else {
        setState(() {
          _isPageLoaded = true;
        });
      }
    } else {
      Fluttertoast.showToast(
        msg: 'No internet connection',
        toastLength: Toast.LENGTH_LONG,
      );
    }
  }

  _onPressedFab() {
    if (_membersData.isNotEmpty) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => RecordAddPage(
            mobile: widget.mobile,
            memberId: _selectMember!,
          ),
        ),
      );
    } else {
      Fluttertoast.showToast(
        msg: 'No members data was found',
        toastLength: Toast.LENGTH_LONG,
      );
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
          floatingActionButton: FloatingActionButton(
            onPressed: _onPressedFab,
            backgroundColor: kColorPrimary,
            tooltip: 'Add record',
            child: const Icon(Icons.add),
          ),
          body: _isPageLoaded
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
                                      DashboardPage(mobile: widget.mobile),
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
                                'Record',
                                style: TextStyle(
                                    fontWeight: FontWeight.w500, fontSize: 18),
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
                              left: 20, right: 15, bottom: 12, top: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide:
                                const BorderSide(color: Colors.grey, width: 1),
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
                        onChanged: _onChangeRecordSelect,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Expanded(
                      child: _isPageDataLoaded
                          ? _loadPageData()
                          : const Center(
                              child: CircularProgressIndicator(),
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
  Widget _loadPageData() {
    Size size = MediaQuery.of(context).size;
    return _memberRecordData.isEmpty
        ? const Center(
            child: Text('No record was found!'),
          )
        : ListView(
            children: _memberRecordData.map((record) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 20,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            DateFormat(
                              'EEEE, MM/dd/yyyy hh:mm a',
                            )
                                .format(
                                  DateTime.parse(record['HPD_DateTime']),
                                )
                                .toString(),
                            style: TextStyle(
                              color: Colors.black.withOpacity(0.8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Container(
                    width: size.width,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Card(
                      child: ClipPath(
                        clipper: ShapeBorderClipper(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.only(
                            top: 5,
                            left: 15,
                            bottom: 10,
                          ),
                          decoration: const BoxDecoration(
                            border: Border(
                              left: BorderSide(
                                color: Colors.orange,
                                width: 2,
                                style: BorderStyle.solid,
                              ),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: const Text(
                                        'Blood Pressure',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 40,
                                    height: 15,
                                    child: PopupMenuButton<Menu>(
                                      padding: EdgeInsets.zero,
                                      onSelected: (Menu menu) =>
                                          _onSelectedPopupMenu(
                                        menu,
                                        record['HPD_ID'],
                                      ),
                                      icon: Icon(
                                        Icons.more_vert,
                                        color: Colors.black.withOpacity(0.8),
                                      ),
                                      itemBuilder: (BuildContext context) =>
                                          <PopupMenuEntry<Menu>>[
                                        const PopupMenuItem<Menu>(
                                          value: Menu.removeRecord,
                                          child: Text('Remove'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Container(
                                padding: const EdgeInsets.only(left: 5),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.bloodtype,
                                            color: Colors.red[900],
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          const Text(
                                            'SBP: ',
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Expanded(
                                            child: Text(
                                              record['HPD_SBP'].toString(),
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.bloodtype,
                                            color: Colors.red[900],
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          const Text(
                                            'DBP: ',
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Expanded(
                                            child: Text(
                                              record['HPD_DBP'].toString(),
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Container(
                                padding: const EdgeInsets.only(left: 5),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.monitor_heart,
                                            color: Colors.red[900],
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          const Text(
                                            'Heart Rate: ',
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Expanded(
                                            child: Text(
                                              record['HPD_HeartRate']
                                                  .toString(),
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.medication,
                                            color: Colors.red[900],
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          const Text(
                                            'Medication: ',
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Expanded(
                                            child: Text(
                                              record['HPD_Medication']
                                                  .toString(),
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              const Text(
                                'Blood Glucose',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Container(
                                padding: const EdgeInsets.only(left: 5),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Image(
                                            image: const AssetImage(
                                              'assets/images/blood_glucose_icon.png',
                                            ),
                                            width: 22,
                                            color: Colors.red[900],
                                          ),
                                          const SizedBox(
                                            width: 8,
                                          ),
                                          const Text('Level: '),
                                          Expanded(
                                            child: Text(
                                              '${record['HPD_BloodGlucose'].toString()} mg/dl',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.access_time_outlined,
                                            color: Colors.red[900],
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          Expanded(
                                            child: Text(
                                              record['HPD_GlucoseMeasured']
                                                  .toString(),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              const Text(
                                'Height & Weight',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Container(
                                padding: const EdgeInsets.only(left: 5),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.height,
                                            color: Colors.red[900],
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          const Text('Height: '),
                                          Expanded(
                                            child: Text(
                                              '${record['HPD_Height'].toString()} ft',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.monitor_weight,
                                            color: Colors.red[900],
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          const Text('Weight: '),
                                          Expanded(
                                            child: Text(
                                              '${record['HPD_Weight'].toString()} kg',
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Container(
                                padding: const EdgeInsets.only(left: 5),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.settings_accessibility,
                                            color: Colors.red[900],
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          const Text('Waist: '),
                                          Expanded(
                                            child: Text(
                                              '${record['HPD_Waist'].toString()} in',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Image(
                                            image: const AssetImage(
                                              'assets/images/bmi_icon.png',
                                            ),
                                            width: 20,
                                            color: Colors.red[900],
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            _bmiResult(record['HPD_BMI']),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              Container(
                                padding: const EdgeInsets.only(left: 5),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Image(
                                            image: const AssetImage(
                                                'assets/images/bmi_icon.png'),
                                            width: 30,
                                            color: Colors.red[900],
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          const Text('Body Mass Index (BMI): '),
                                          Expanded(
                                            child: Text(
                                              record['HPD_BMI'].toString(),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                ],
              );
            }).toList(),
          );
  }

  //
  _onChangeRecordSelect(String? val) async {
    setState(() {
      _selectMember = val;
      _isPageDataLoaded = false;
    });
    await _loadMemberRecordData();
    setState(() {
      _isPageDataLoaded = true;
    });
  }

  //
  String _bmiResult(double bmi) {
    String bmiResult = '';
    if (bmi < 18.5) {
      bmiResult = 'Underweight';
    } else if (bmi >= 18.5 && bmi <= 24.9) {
      bmiResult = 'Normal weight';
    } else if (bmi >= 25 && bmi <= 29.9) {
      bmiResult = 'Overweight';
    } else {
      bmiResult = 'Obesity';
    }
    return bmiResult;
  }

  //
  _onSelectedPopupMenu(Menu menu, int recordId) {
    switch (menu) {
      case Menu.removeRecord:
        showConfirmationAlert(
          context,
          _onPressedCancelBtn,
          () => _onPressedContinueBtn(recordId),
          "Warning message",
          "Are you sure you want to remove this record?",
        );
        break;
    }
  }

  //
  _onPressedCancelBtn() {
    Navigator.of(context).pop();
  }

  //
  _onPressedContinueBtn(int recordId) {
    Navigator.of(context).pop();
    if (recordId > 0) {
      showDialogBox(context);
      _onPostRemoveMemberRecord(recordId).then((String message) {
        if (message == 'Success!') {
          _onDoneRemoveMemberRecord(recordId);
        } else {
          Fluttertoast.showToast(
            msg: message,
            toastLength: Toast.LENGTH_LONG,
          );
        }
      });
    }
  }

  //
  Future<String> _onPostRemoveMemberRecord(int recordId) async {
    // check internet connectivity
    final hasInternet = await _hasInternetConnection();
    if (hasInternet) {
      final message =
          await MemberService().onRemoveMemberRecord(widget.mobile, recordId);
      return message;
    } else {
      return 'No internet connection';
    }
  }

  //
  _onDoneRemoveMemberRecord(int recordId) {
    Navigator.of(context).pop();
    setState(() {
      _memberRecordData = List.from(_memberRecordData)
        ..removeWhere((record) => record['HPD_ID'] == recordId);
    });
  }
}

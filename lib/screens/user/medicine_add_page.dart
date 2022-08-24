import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hami/screens/user/medicine_page.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:date_format/date_format.dart';
import 'package:intl/intl.dart';

import '../../services/member_service.dart';
import '../../widget/connectivity_banner.dart';
import '../../widget/show_dialog.dart';

const kColorBg = Colors.white;
const kColorBg2 = Color(0xfff2f6fe);

enum SelectTimeOpt { time1, time2, time3, time4 }

class MedicineAddPage extends StatefulWidget {
  final String mobile;
  final String? memberId;
  const MedicineAddPage({required this.mobile, this.memberId, Key? key})
      : super(key: key);

  @override
  State<MedicineAddPage> createState() => _MedicineAddPageState();
}

class _MedicineAddPageState extends State<MedicineAddPage> {
  final _formKey = GlobalKey<FormState>();

  // select member
  String? _selectMember;
  String? _selectMedDose = '1';

  // data
  List<dynamic> _membersData = [];

  final List<Map<String, String>> _medicineDoseList = [
    {'key': '1', 'value': 'Once a day'},
    {'key': '2', 'value': 'Twice a day'},
    {'key': '3', 'value': 'Thrice a day'},
    {'key': '4', 'value': 'Four time a day'},
  ];

  bool _isTime2Visible = false;
  bool _isTime3Visible = false;
  bool _isTime4Visible = false;

  TimeOfDay _selectedTime1 = TimeOfDay.now();
  TimeOfDay _selectedTime2 = TimeOfDay.now();
  TimeOfDay _selectedTime3 = TimeOfDay.now();
  TimeOfDay _selectedTime4 = TimeOfDay.now();

  final TextEditingController _medNameCtrl = TextEditingController();
  final TextEditingController _timeCtrl1 = TextEditingController();
  final TextEditingController _timeCtrl2 = TextEditingController();
  final TextEditingController _timeCtrl3 = TextEditingController();
  final TextEditingController _timeCtrl4 = TextEditingController();

  // check if page is loaded
  bool _isPageLoaded = false;

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
    //
    _timeCtrl1.text = formatDate(
      DateTime(2019, 08, 1, _selectedTime1.hour, _selectedTime1.minute),
      [hh, ':', nn, " ", am],
    ).toString();
    _timeCtrl2.text = formatDate(
      DateTime(2019, 08, 1, _selectedTime2.hour, _selectedTime2.minute),
      [hh, ':', nn, " ", am],
    ).toString();
    _timeCtrl3.text = formatDate(
      DateTime(2019, 08, 1, _selectedTime3.hour, _selectedTime3.minute),
      [hh, ':', nn, " ", am],
    ).toString();
    _timeCtrl4.text = formatDate(
      DateTime(2019, 08, 1, _selectedTime4.hour, _selectedTime4.minute),
      [hh, ':', nn, " ", am],
    ).toString();
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
    _medNameCtrl.dispose();
    _timeCtrl1.dispose();
    _timeCtrl2.dispose();
    _timeCtrl3.dispose();
    _timeCtrl4.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
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
        body: _isPageLoaded
            ? ListView(
                children: [
                  SizedBox(
                    width: size.width,
                    height: size.height,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(18, 20, 18, 0),
                            child: Row(
                              children: [
                                InkWell(
                                  onTap: () => Navigator.of(context).pop(),
                                  child: const Icon(
                                    Icons.arrow_back_ios,
                                    size: 18,
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.only(
                                        right: size.width * 0.06),
                                    alignment: Alignment.center,
                                    child: const Text(
                                      'Add Medicine',
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
                                    color: Colors.grey,
                                    width: 1,
                                  ),
                                ),
                                filled: true,
                                fillColor: kColorBg2,
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
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return 'This field is required';
                                }
                                return null;
                              },
                            ),
                          ),
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.only(
                                top: 15,
                              ),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: _medNameCtrl,
                                    cursorColor: Colors.black87,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(7),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(7),
                                        borderSide: const BorderSide(
                                          color: Colors.grey,
                                          width: 1,
                                        ),
                                      ),
                                      contentPadding: const EdgeInsets.all(15),
                                      hintText: 'Medicine name',
                                    ),
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    validator: (val) {
                                      if (val == null || val.isEmpty) {
                                        return 'This field is required';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  DropdownButtonFormField<String>(
                                    isExpanded: true,
                                    hint: const Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text('Select an option'),
                                    ),
                                    decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.all(15),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(7),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(7),
                                        borderSide: const BorderSide(
                                          color: Colors.grey,
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                    value: _selectMedDose,
                                    items: _medicineDoseList.map((dose) {
                                      return DropdownMenuItem(
                                        value: dose['key'],
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                dose['value'].toString(),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (String? val) {
                                      FocusScope.of(context)
                                          .requestFocus(FocusNode());
                                      _onChangedDose(val);
                                    },
                                    validator: (val) {
                                      if (val == null || val.isEmpty) {
                                        return 'This field is required';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      FocusScope.of(context)
                                          .requestFocus(FocusNode());
                                      _selectTime(context, SelectTimeOpt.time1);
                                    },
                                    child: IgnorePointer(
                                      child: TextFormField(
                                        controller: _timeCtrl1,
                                        textAlign: TextAlign.center,
                                        decoration: const InputDecoration(
                                          contentPadding: EdgeInsets.all(15),
                                          border: OutlineInputBorder(),
                                          hintText: 'Time of dose no 1',
                                          suffixIcon: Icon(Icons.access_time),
                                          prefixText: 'TIME OF DOSE NO.1: ',
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  _isTime2Visible
                                      ? InkWell(
                                          onTap: () {
                                            FocusScope.of(context)
                                                .requestFocus(FocusNode());
                                            _selectTime(
                                                context, SelectTimeOpt.time2);
                                          },
                                          child: IgnorePointer(
                                            child: TextField(
                                              controller: _timeCtrl2,
                                              textAlign: TextAlign.center,
                                              decoration: const InputDecoration(
                                                contentPadding:
                                                    EdgeInsets.all(15),
                                                border: OutlineInputBorder(),
                                                hintText: 'Time of dose no 2',
                                                suffixIcon:
                                                    Icon(Icons.access_time),
                                                prefixText:
                                                    'TIME OF DOSE NO.2: ',
                                              ),
                                            ),
                                          ),
                                        )
                                      : Container(),
                                  SizedBox(
                                    height: _isTime2Visible ? 10 : 0,
                                  ),
                                  _isTime3Visible
                                      ? InkWell(
                                          onTap: () {
                                            FocusScope.of(context)
                                                .requestFocus(FocusNode());
                                            _selectTime(
                                                context, SelectTimeOpt.time3);
                                          },
                                          child: IgnorePointer(
                                            child: TextField(
                                              controller: _timeCtrl3,
                                              textAlign: TextAlign.center,
                                              decoration: const InputDecoration(
                                                contentPadding:
                                                    EdgeInsets.all(15),
                                                border: OutlineInputBorder(),
                                                hintText: 'Time of dose no 3',
                                                suffixIcon:
                                                    Icon(Icons.access_time),
                                                prefixText:
                                                    'TIME OF DOSE NO.3: ',
                                              ),
                                            ),
                                          ),
                                        )
                                      : Container(),
                                  SizedBox(
                                    height: _isTime3Visible ? 10 : 0,
                                  ),
                                  _isTime4Visible
                                      ? InkWell(
                                          onTap: () {
                                            FocusScope.of(context)
                                                .requestFocus(FocusNode());
                                            _selectTime(
                                                context, SelectTimeOpt.time4);
                                          },
                                          child: IgnorePointer(
                                            child: TextField(
                                              controller: _timeCtrl4,
                                              textAlign: TextAlign.center,
                                              decoration: const InputDecoration(
                                                contentPadding:
                                                    EdgeInsets.all(15),
                                                border: OutlineInputBorder(),
                                                hintText: 'Time of dose no 4',
                                                suffixIcon:
                                                    Icon(Icons.access_time),
                                                prefixText:
                                                    'TIME OF DOSE NO.4: ',
                                              ),
                                            ),
                                          ),
                                        )
                                      : Container(),
                                  SizedBox(
                                    height: _isTime4Visible ? 10 : 0,
                                  ),
                                  Container(
                                    height: 50,
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 7),
                                    margin: const EdgeInsets.only(top: 5),
                                    child: TextButton(
                                      style: TextButton.styleFrom(
                                        backgroundColor: Colors.red.shade900,
                                        primary: Colors.white,
                                      ),
                                      onPressed: _onPressedAddMedicine,
                                      child: const Text(
                                        'Add Medicine',
                                        style: TextStyle(
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : const Center(
                child: CircularProgressIndicator(),
              ),
      ),
    );
  }

  //
  _onChangeRecordSelect(String? val) async {
    setState(() {
      _selectMember = val;
    });
  }

  //
  _onChangedDose(String? val) {
    _selectMedDose = val;
    if (val == '1') {
      _isTime2Visible = false;
      _isTime3Visible = false;
      _isTime4Visible = false;
    } else if (val == '2') {
      _isTime2Visible = true;
      _isTime3Visible = false;
      _isTime4Visible = false;
    } else if (val == '3') {
      _isTime2Visible = true;
      _isTime3Visible = true;
      _isTime4Visible = false;
    } else if (val == '4') {
      _isTime2Visible = true;
      _isTime3Visible = true;
      _isTime4Visible = true;
    }
    setState(() {});
  }

  //
  Future<void> _selectTime(BuildContext context, SelectTimeOpt timeOpt) async {
    switch (timeOpt) {
      case SelectTimeOpt.time1:
        final TimeOfDay? picked = await showTimePicker(
          context: context,
          initialTime: _selectedTime1,
        );
        if (picked != null && picked != _selectedTime1) {
          _selectedTime1 = picked;
          String hour = _selectedTime1.hour.toString();
          String minute = _selectedTime1.minute.toString();
          String time = '$hour : $minute';
          _timeCtrl1.text = time;
          _timeCtrl1.text = formatDate(
            DateTime(2019, 08, 1, _selectedTime1.hour, _selectedTime1.minute),
            [hh, ':', nn, " ", am],
          ).toString();
          setState(() {});
        }
        break;
      case SelectTimeOpt.time2:
        final TimeOfDay? picked = await showTimePicker(
          context: context,
          initialTime: _selectedTime2,
        );
        if (picked != null && picked != _selectedTime2) {
          _selectedTime2 = picked;
          String hour = _selectedTime2.hour.toString();
          String minute = _selectedTime2.minute.toString();
          String time = '$hour : $minute';
          _timeCtrl2.text = time;
          _timeCtrl2.text = formatDate(
            DateTime(2019, 08, 1, _selectedTime2.hour, _selectedTime2.minute),
            [hh, ':', nn, " ", am],
          ).toString();
          setState(() {});
        }
        break;
      case SelectTimeOpt.time3:
        final TimeOfDay? picked = await showTimePicker(
          context: context,
          initialTime: _selectedTime3,
        );
        if (picked != null && picked != _selectedTime3) {
          _selectedTime3 = picked;
          String hour = _selectedTime3.hour.toString();
          String minute = _selectedTime3.minute.toString();
          String time = '$hour : $minute';
          _timeCtrl3.text = time;
          _timeCtrl3.text = formatDate(
            DateTime(2019, 08, 1, _selectedTime3.hour, _selectedTime3.minute),
            [hh, ':', nn, " ", am],
          ).toString();
          setState(() {});
        }
        break;
      case SelectTimeOpt.time4:
        final TimeOfDay? picked = await showTimePicker(
          context: context,
          initialTime: _selectedTime4,
        );
        if (picked != null && picked != _selectedTime4) {
          _selectedTime4 = picked;
          String hour = _selectedTime4.hour.toString();
          String minute = _selectedTime4.minute.toString();
          String time = '$hour : $minute';
          _timeCtrl4.text = time;
          _timeCtrl4.text = formatDate(
            DateTime(2019, 08, 1, _selectedTime4.hour, _selectedTime4.minute),
            [hh, ':', nn, " ", am],
          ).toString();
          setState(() {});
        }
        break;
    }
  }

  //
  _onPressedAddMedicine() async {
    final validate = _formKey.currentState!.validate();
    if (validate) {
      // check internet connectivity
      final hasInternet = await _hasInternetConnection();
      if (hasInternet) {
        final message = await _onPostAddMedicine();
        _onDoneAddMedicine(message);
      } else {
        return {
          'message': 'No internet connection',
        };
      }
    }
  }

  //
  Future<String> _onPostAddMedicine() async {
    if (_selectMember != null) {
      showDialogBox(context);
      DateTime date1 = DateFormat.jm().parse(_timeCtrl1.text);
      String time1 = DateFormat("HH:mm").format(date1);
      DateTime date2 = DateFormat.jm().parse(_timeCtrl2.text);
      String time2 = DateFormat("HH:mm").format(date2);
      DateTime date3 = DateFormat.jm().parse(_timeCtrl3.text);
      String time3 = DateFormat("HH:mm").format(date3);
      DateTime date4 = DateFormat.jm().parse(_timeCtrl4.text);
      String time4 = DateFormat("HH:mm").format(date4);
      final result = await MemberService().onSaveMemberMedicineRecord(
        widget.mobile,
        _selectMember!,
        _medNameCtrl.value.text,
        _selectMedDose!,
        time1,
        time2,
        time3,
        time4,
      );
      final message = result['message'];
      var data = result['data'];
      if (message == 'success') {
        return data[0]['remarks'];
      } else {
        return message;
      }
    } else {
      return 'Invalid';
    }
  }
  //
  _onDoneAddMedicine(String message) {
    Navigator.of(context).pop();
    if(message == 'Success!') {
      Fluttertoast.showToast(
        msg: 'Member medicine added successfully',
        toastLength: Toast.LENGTH_SHORT,
      );
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MedicinePage(mobile: widget.mobile)));
    } else {
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
      );
    }
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hami/services/member_service.dart';
import 'package:flutter_hami/widget/connectivity_banner.dart';
import 'package:flutter_hami/widget/show_dialog.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:intl/intl.dart';
import 'package:flutter_hami/screens/user/record_page.dart';

import '../../colors.dart';

enum SelectMedication { yes, no }

class RecordAddPage extends StatefulWidget {
  final String mobile;
  final String memberId;
  const RecordAddPage({
    required this.mobile,
    required this.memberId,
    Key? key,
  }) : super(key: key);

  @override
  State<RecordAddPage> createState() => _RecordAddPageState();
}

class _RecordAddPageState extends State<RecordAddPage> {
  final _addRecordFormKey = GlobalKey<FormState>();

  // select medication
  SelectMedication _medication = SelectMedication.yes;
  // select member
  String? _selectMember;
  // select measurement
  String? _selectMeasurement;

  // datetime
  DateTime _dateTime = DateTime.now();

  // controllers
  final _sBPCtrl = TextEditingController();
  final _dBPCtrl = TextEditingController();
  final _heartRateCtrl = TextEditingController();
  final _bloodGlucoseCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _waistCtrl = TextEditingController();
  final _dateTimeCtrl = TextEditingController();

  // data
  List<dynamic> _membersData = [];

  final List<String> _measurementScale = [
    'Before Breakfast',
    'After Breakfast',
    'Before Lunch',
    'After Lunch',
    'Before Dinner',
    'After Dinner',
    'Bedtime',
    'Random',
  ];

  // check if page is loaded
  bool _isPageLoaded = false;

  // has internet
  late StreamSubscription internetSubscription;

  @override
  void initState() {
    internetSubscription = InternetConnectionChecker().onStatusChange.listen((status) {
      final hasInternet = status == InternetConnectionStatus.connected;
      if(!hasInternet) {
        connectivityBanner(context, 'No internet connection.', () => ScaffoldMessenger.of(context).hideCurrentMaterialBanner());
      } else {
        ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
        _loadMembersData();
      }
    });
    //
    _selectMeasurement = _measurementScale[0];
    final time = DateFormat('hh:mm a').format(_dateTime);
    _dateTimeCtrl.text = '${_dateTime.year}-${_dateTime.month}-${_dateTime.day} $time';
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
    if(hasInternet) {
      final membersData = await MemberService().onLoadMembers(widget.mobile);
      final message = membersData['message'];
      if(message == 'success') {
        setState(() {
          _selectMember = widget.memberId;
          _membersData = membersData['data'];
          _isPageLoaded = true;
        });
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
    _sBPCtrl.dispose();
    _dBPCtrl.dispose();
    _heartRateCtrl.dispose();
    _bloodGlucoseCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    _waistCtrl.dispose();
    _dateTimeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        backgroundColor: kColorBg,
        drawer: const Drawer(),
        appBar: PreferredSize(
          preferredSize: Size.zero,
          child: AppBar(
            elevation: 0,
            backgroundColor: kColorBg, //ios status bar colors
            systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarColor: kColorBg, //android status bar color
              statusBarBrightness: Brightness.light, // For iOS: (dark icons)
              statusBarIconBrightness: Brightness.dark, // For Android: (dark icons)
            ),
          ),
        ),
        body: _isPageLoaded ? Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 0),
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => RecordPage(
                            mobile: widget.mobile,
                            memberId: _selectMember,
                          ),
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
                        'Add Record',
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
            Expanded(
              child: Form(
                key: _addRecordFormKey,
                child: ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        hint: const Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Select an option'),
                        ),
                        value: _selectMember,
                        borderRadius: BorderRadius.circular(5),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.only(
                              left: 12, right: 12, bottom: 12, top: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
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
                        onChanged: (String? val) {
                          setState(() => _selectMember = val);
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    // form body
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _sBPCtrl,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.only(
                                  left: 12, right: 12, bottom: 12, top: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: const BorderSide(
                                    color: Colors.grey, width: 1),
                              ),
                              hintText: 'Systolic blood pressure',
                            ),
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (String? val) {
                              if (val == null || val.isEmpty) {
                                return 'This field is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            controller: _dBPCtrl,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.only(
                                  left: 12, right: 12, bottom: 12, top: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: const BorderSide(
                                    color: Colors.grey, width: 1),
                              ),
                              hintText: 'Diastolic blood pressure',
                            ),
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (String? val) {
                              if (val == null || val.isEmpty) {
                                return 'This field is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            controller: _heartRateCtrl,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.only(
                                  left: 12, right: 12, bottom: 12, top: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: const BorderSide(
                                    color: Colors.grey, width: 1),
                              ),
                              hintText: 'Heart rate',
                            ),
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (String? val) {
                              if (val == null || val.isEmpty) {
                                return 'This field is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Row(
                            children: [
                              const Text('Medication: '),
                              const SizedBox(
                                width: 5,
                              ),
                              Row(
                                children: [
                                  SizedBox(
                                    height: 20,
                                    width: 30,
                                    child: Radio(
                                      value: SelectMedication.yes,
                                      groupValue: _medication,
                                      onChanged: (SelectMedication? value) {
                                        setState(() => _medication = value!);
                                      },
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() =>
                                          _medication = SelectMedication.yes);
                                    },
                                    child: const Text('Yes'),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                width: 15,
                              ),
                              Row(
                                children: [
                                  SizedBox(
                                    height: 20,
                                    width: 30,
                                    child: Radio(
                                        value: SelectMedication.no,
                                        groupValue: _medication,
                                        onChanged: (SelectMedication? value) {
                                          setState(() => _medication = value!);
                                        }),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() =>
                                          _medication = SelectMedication.no);
                                    },
                                    child: const Text('No'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          TextFormField(
                            controller: _bloodGlucoseCtrl,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.only(
                                  left: 12, right: 12, bottom: 12, top: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: const BorderSide(
                                    color: Colors.grey, width: 1),
                              ),
                              hintText: 'Blood glucose',
                              suffixText: 'mg/dl',
                            ),
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (String? val) {
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
                            borderRadius: BorderRadius.circular(5),
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.only(
                                left: 12,
                                right: 12,
                                bottom: 12,
                                top: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: const BorderSide(
                                    color: Colors.grey, width: 1),
                              ),
                              hintText: 'Blood glucose',
                            ),
                            value: _selectMeasurement,
                            items: _measurementScale.map((item) {
                              return DropdownMenuItem(
                                value: item,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (String? val) =>
                                setState(() => _selectMeasurement = val),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            controller: _heightCtrl,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.only(
                                  left: 12, right: 12, bottom: 12, top: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: const BorderSide(
                                    color: Colors.grey, width: 1),
                              ),
                              hintText: 'Height',
                              suffixText: 'cm',
                            ),
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (String? val) {
                              if (val == null || val.isEmpty) {
                                return 'This field is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            controller: _weightCtrl,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.only(
                                  left: 12, right: 12, bottom: 12, top: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: const BorderSide(
                                    color: Colors.grey, width: 1),
                              ),
                              hintText: 'Weight',
                              suffixText: 'kg',
                            ),
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (String? val) {
                              if (val == null || val.isEmpty) {
                                return 'This field is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            controller: _waistCtrl,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.only(
                                  left: 12, right: 12, bottom: 12, top: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: const BorderSide(
                                    color: Colors.grey, width: 1),
                              ),
                              hintText: 'Waist',
                              suffixText: 'inches',
                            ),
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (String? val) {
                              if (val == null || val.isEmpty) {
                                return 'This field is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Row(
                            children: const [
                              Text(
                                'Compute BMI: ',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  '21.5 Normal Weight',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Row(
                            children: const [
                              Expanded(
                                child: Text(
                                  'BMI = weight in kg / height squared in meters.',
                                  style: TextStyle(
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          InkWell(
                            onTap: _selectDatetime,
                            child: IgnorePointer(
                              child: TextFormField(
                                controller: _dateTimeCtrl,
                                decoration: InputDecoration(
                                  isDense: true,
                                  contentPadding: const EdgeInsets.only(
                                    left: 12,
                                    right: 12,
                                    bottom: 12,
                                    top: 12,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5),
                                    borderSide: const BorderSide(
                                      color: Colors.grey,
                                      width: 1,
                                    ),
                                  ),
                                  hintText: 'Measurement Datetime',
                                  suffixIcon: const Icon(
                                    Icons.date_range_outlined,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: MaterialButton(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              color: kColorPrimary,
                              onPressed: _onPressedSaveRecord,
                              child: const Text(
                                'Save Record',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ) : const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  //
  Future _selectDatetime() async {
    DateTime? date = await _pickDate();
    if (date == null) return; // pressed CANCEL
    TimeOfDay? time = await _pickTime();
    if (time == null) return; // pressed CANCEL
    final dateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    final formatTime = DateFormat('hh:mm a').format(dateTime);
    _dateTimeCtrl.text = '${dateTime.year}-${dateTime.month}-${dateTime.day} $formatTime';
    setState(() => _dateTime = dateTime);
  }

  //
  Future<DateTime?> _pickDate() => showDatePicker(
        context: context,
        initialDate: _dateTime,
        firstDate: DateTime(1900),
        lastDate: DateTime(2100),
      );
  //
  Future<TimeOfDay?> _pickTime() => showTimePicker(
        context: context,
        initialTime: TimeOfDay(hour: _dateTime.hour, minute: _dateTime.minute),
      );
  //
  _onPressedSaveRecord() async {
    bool formValidation = _addRecordFormKey.currentState!.validate();
    if (formValidation) {
      showDialogBox(context);
      final message = await _onPostSaveRecord();
      _onDoneSaveRecord(message);
    }
  }
  //
  _onPostSaveRecord() async {
    // check internet connectivity
    final hasInternet = await _hasInternetConnection();
    if(hasInternet) {
      final time = DateFormat('hh:mm a').format(_dateTime);
      Map<String, String> recordMap = {
        "HPD_HP_ID": _selectMember!,
        "HPD_Date": '${_dateTime.year}-${_dateTime.month}-${_dateTime.day}',
        "HPD_DateTime": '${_dateTime.year}-${_dateTime.month}-${_dateTime.day} $time',
        "HPD_SBP": _sBPCtrl.text,
        "HPD_DBP": _dBPCtrl.text,
        "HPD_HeartRate": _heartRateCtrl.text,
        "HPD_Medication": (_medication == SelectMedication.yes) ? 'Yes' : 'No',
        "HPD_BloodGlucose": _bloodGlucoseCtrl.text,
        "HPD_GlucoseMeasured": _selectMeasurement!,
        "HPD_Height": _heightCtrl.text,
        "HPD_BMI": '21.5',
        "HPD_Type": 'all',
      };
      final message = await MemberService().onSaveMemberRecord(recordMap);
      return message;
    } else {
      return 'No internet connection';
    }
  }
  //
  _onDoneSaveRecord(String message) {
    if(message == 'Successful') {
      Navigator.pop(context);
      Fluttertoast.showToast(
        msg: 'Member record has been added successfully',
        toastLength: Toast.LENGTH_SHORT,
      );
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => RecordPage(
            mobile: widget.mobile,
            memberId: _selectMember,
          ),
        ), (Route<dynamic> route) => false,
      );
    } else {
      Navigator.pop(context);
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
      );
    }
  }
}

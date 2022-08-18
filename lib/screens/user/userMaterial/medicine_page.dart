import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hami/widget/show_confirmation_alert.dart';
import 'package:flutter_hami/widget/show_dialog.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../../../colors.dart';
import '../../../services/member_service.dart';
import '../../../widget/connectivity_banner.dart';
import '../../dashboard_page.dart';
import 'medicine_add_page.dart';

const kColorBg = Color(0xfff2f6fe);

class MedicinePage extends StatefulWidget {
  final String mobile;
  final String? memberId;
  const MedicinePage({required this.mobile, this.memberId, Key? key})
      : super(key: key);

  @override
  State<MedicinePage> createState() => _MedicinePageState();
}

class _MedicinePageState extends State<MedicinePage> {
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
            .onLoadMemberMedicineRecord(widget.mobile, _selectMember!);
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
          builder: (context) => MedicineAddPage(
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
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
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
            statusBarIconBrightness:
                Brightness.dark, // For Android: (dark icons)
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onPressedFab,
        backgroundColor: kColorPrimary,
        tooltip: 'Add medicine',
        child: const Icon(Icons.add),
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
                                padding:
                                    EdgeInsets.only(right: size.width * 0.06),
                                alignment: Alignment.center,
                                child: const Text(
                                  'Medicine',
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
                                left: 20, right: 15, bottom: 12, top: 12),
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
                          onChanged: _onChangeRecordSelect,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Expanded(
                        child: _isPageDataLoaded
                            ? _loadPageData()
                            : Container(
                                alignment: Alignment.center,
                                margin: EdgeInsets.only(
                                  bottom: size.height * 0.15,
                                ),
                                child: const CircularProgressIndicator(),
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
    );
  }

  //
  Widget _loadPageData() {
    // Size size = MediaQuery.of(context).size;
    List<String> medicineCountTrack = [
      'Once a day',
      'Twice a day',
      'Thrice a day',
      'Four time a day',
    ];
    return _memberRecordData.isEmpty
        ? const Center(
            child: Text('No record was found!'),
          )
        : ListView(
            children: _memberRecordData.map(
            (record) {
              return Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10,),
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      offset: Offset(5, 5),
                      blurRadius: 2,
                    )
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.only(
                        left: 20,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(50.0),
                                  child: Image(
                                    image: AssetImage(
                                        (record['HP_Gender'] == 'Male')
                                            ? 'assets/images/male.png'
                                            : 'assets/images/female.png'),
                                    width: 35,
                                  ),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  record['HP_Name'],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: IconButton(
                              onPressed: () => _onPressedRemoveMedicine(record['HM_ID']),
                              icon: Icon(
                                Icons.delete_forever_rounded,
                                size: 30,
                                color: Colors.red[900],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 3,
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: Row(
                        children: [
                          Text(
                            record['HM_Med_Desc'],
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          Text(
                            ' (${medicineCountTrack[record['HM_Dose'] - 1]})',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 3,
                    ),
                    for (int i = 1; i <= record['HM_Dose']; i++)
                      Container(
                        padding: const EdgeInsets.only(left: 10, bottom: 3),
                        child: Column(
                          children: [
                            Container(
                              alignment: Alignment.centerLeft,
                              padding:
                                  const EdgeInsets.only(left: 10, bottom: 2),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.access_time_outlined,
                                            color: Colors.red[900],
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          const Text(
                                            'Time of Dose No ',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            i.toString(),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Expanded(
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.arrow_right_alt_outlined,
                                            ),
                                            Text(
                                              record['HM_DateTime'].substring(
                                                  record['HM_DateTime'].length -
                                                      7),
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
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
                  ],
                ),
              );
            },
          ).toList());
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
  _onPressedRemoveMedicine(int medId) {
    showConfirmationAlert(
      context,
      _onPressedCancel,
      () => _onPressedContinue(medId.toString()),
      "Warning message",
      "Are you sure you want to remove this medicine",
    );
  }

  _onPressedCancel() {
    Navigator.of(context).pop();
  }

  _onPressedContinue(String medId) async {
    Navigator.of(context).pop();
    final memberSelected = _selectMember;
    if(memberSelected != null && int.parse(memberSelected) > 0) {
      final message = await _onPostRemoveMedicine(medId);
      _onDoneRemoveMedicine(message);
    } else {
      Fluttertoast.showToast(
        msg: 'Unable to remove this medicine',
        toastLength: Toast.LENGTH_SHORT,
      );
    }
  }

  _onPostRemoveMedicine(String medId) async {
    showDialogBox(context);
    final result = await MemberService().onRemoveMemberMedicineRecord(widget.mobile, medId);
    final message = result['message'];
    var data = result['data'];
    if(message == 'success') {
      return data[0]['remarks'];
    } else {
      return message;
    }
  }

  _onDoneRemoveMedicine(String message) async {
    Navigator.of(context).pop();
    if(message == 'Success!') {
      await _onChangeRecordSelect(_selectMember);
      Fluttertoast.showToast(
        msg: 'Member medicine removed successfully',
        toastLength: Toast.LENGTH_SHORT,
      );
    } else {
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
      );
    }
  }
}

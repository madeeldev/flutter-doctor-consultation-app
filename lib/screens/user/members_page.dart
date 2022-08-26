import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hami/colors.dart';
import 'package:flutter_hami/screens/dashboard_page.dart';
import 'package:flutter_hami/services/member_service.dart';
import 'package:flutter_hami/widget/animated_list_item.dart';
import 'package:flutter_hami/widget/connectivity_banner.dart';
import 'package:flutter_hami/widget/show_confirmation_alert.dart';
import 'package:flutter_hami/widget/show_dialog.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

const kColorBg = Color(0xfff2f6fe);

enum SlibableAction { delete, cancel }

enum SelectGender { male, female, others }

class MembersPage extends StatefulWidget {
  final String mobile;
  const MembersPage({required this.mobile, Key? key}) : super(key: key);

  @override
  State<MembersPage> createState() => _MembersPageState();
}

class _MembersPageState extends State<MembersPage> {
  final _animatedListKey = GlobalKey<AnimatedListState>();

  // errorMessages
  String _nameErrMsg = '';
  String _ageErrMsg = '';

  // controllers
  final _searchMembersCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();

  // select gender
  SelectGender _gender = SelectGender.male;

  // check if page is loaded
  bool _isPageLoaded = false;

  // data
  List<dynamic> _membersData = [];

  // has internet
  late StreamSubscription internetSubscription;

  @override
  void initState() {
    internetSubscription =
        InternetConnectionChecker().onStatusChange.listen((status) {
      final hasInternet = status == InternetConnectionStatus.connected;
      if (!hasInternet) {
        connectivityBanner(
          context,
          'No internet connection.',
          () => ScaffoldMessenger.of(context).hideCurrentMaterialBanner(),
        );
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
        setState(() {
          // sort if there is data
          _membersData = data.isNotEmpty ? data.reversed.toList() : data;
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

  _clearSearch() {
    _searchMembersCtrl.clear();
    setState(() {});
  }

  @override
  void dispose() {
    _searchMembersCtrl.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  // validators
  _validateName(String? textVal, setState) {
    debugPrint('_validateName');
    setState(() {
      if(textVal == null || textVal.isEmpty) {
        _nameErrMsg = 'Name field is required';
      } else {
        _nameErrMsg = '';
      }
    });
  }

  _validateAge(String? textVal, setState) {
    debugPrint('_validateAge');
    setState(() {
      if(textVal == null || textVal.isEmpty) {
        _ageErrMsg = 'Age field is required';
      } else {
        if (RegExp(r'^[a-z]+$').hasMatch(_ageCtrl.value.text)) {
          _ageErrMsg = 'Age is not a valid number';
        } else {
          _ageErrMsg = '';
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) =>
                DashboardPage(mobile: widget.mobile),
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
            onPressed: _onPressedFabBtn,
            backgroundColor: kColorPrimary,
            child: const Icon(Icons.add),
          ),
          body: _isPageLoaded
              ? ListView(
                  children: [
                    SizedBox(
                      width: double.infinity,
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
                                      'Members',
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
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            child: Container(
                              padding: const EdgeInsets.only(left: 15, right: 15),
                              height: 44,
                              width: double.infinity,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.grey,
                                  width: 0.3,
                                ),
                              ),
                              child: TextFormField(
                                textAlignVertical: TextAlignVertical.center,
                                controller: _searchMembersCtrl,
                                onChanged: (String? textVal) =>
                                    setState(() => {}),
                                cursorColor: Colors.grey,
                                decoration: InputDecoration(
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                  border: InputBorder.none,
                                  icon: Icon(
                                    Icons.search,
                                    color: Colors.grey.shade400,
                                  ),
                                  hintText: 'Search here',
                                  hintStyle: TextStyle(
                                      color: Colors.grey.shade400,
                                      fontWeight: FontWeight.w500),
                                  suffixIcon: _searchMembersCtrl.text.isNotEmpty
                                      ? GestureDetector(
                                          onTap: _clearSearch,
                                          child: const Icon(
                                            Icons.clear,
                                            color: Colors.black87,
                                          ),
                                        )
                                      : null,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              margin: const EdgeInsets.only(
                                bottom: 30,
                              ),
                              child: AnimatedList(
                                key: _animatedListKey,
                                initialItemCount: _membersData.length,
                                itemBuilder: (context, index, animation) {
                                  return Container(
                                    margin: const EdgeInsets.all(4.0),
                                    child: Slidable(
                                      startActionPane: ActionPane(
                                        motion: const ScrollMotion(),
                                        children: [
                                          SlidableAction(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            onPressed: (context) => _onDismissed(
                                              context,
                                              SlibableAction.delete,
                                              index,
                                              _membersData[index]['HP_ID'],
                                            ),
                                            backgroundColor: kColorPrimary,
                                            foregroundColor: Colors.white,
                                            icon: Icons.delete,
                                            label: 'Delete',
                                          ),
                                          SlidableAction(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            onPressed: (context) => _onDismissed(
                                              context,
                                              SlibableAction.cancel,
                                            ),
                                            backgroundColor: Colors.blueAccent,
                                            foregroundColor: Colors.white,
                                            icon: Icons.cancel,
                                            label: 'Cancel',
                                          ),
                                        ],
                                      ),
                                      endActionPane: ActionPane(
                                        motion: const ScrollMotion(),
                                        children: [
                                          SlidableAction(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            onPressed: (context) => _onDismissed(
                                              context,
                                              SlibableAction.delete,
                                              index,
                                              _membersData[index]['HP_ID'],
                                            ),
                                            backgroundColor: kColorPrimary,
                                            foregroundColor: Colors.white,
                                            icon: Icons.delete,
                                            label: 'Delete',
                                          ),
                                          SlidableAction(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            onPressed: (context) => _onDismissed(
                                              context,
                                              SlibableAction.cancel,
                                            ),
                                            backgroundColor: Colors.blueAccent,
                                            foregroundColor: Colors.white,
                                            icon: Icons.cancel,
                                            label: 'Cancel',
                                          ),
                                        ],
                                      ),
                                      child: AnimatedListItem(
                                        item: _membersData[index],
                                        animation: animation,
                                      ),
                                    ),
                                  );
                                },
                              ),
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

  // custom validate form
  bool _customValidateForm() {
    // name
    if (_nameCtrl.value.text.isEmpty) {
      // required
      return false;
    }
    // age
    if (_ageCtrl.value.text.isEmpty) {
      // required
      return false;
    } else {
      // not a number
      if (RegExp(r'^[a-z]+$').hasMatch(_ageCtrl.value.text)) {
        return false;
      }
    }
    return true;
  }

  _onPressedFabBtn() {
    _isPageLoaded ? _openDialogue() : null;
  }

  _openDialogue() => showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => StatefulBuilder(
          builder: (context, setState) => WillPopScope(
            onWillPop: () async {
              return Future.value(false);
            },
            child: AlertDialog(
              contentPadding: EdgeInsets.zero,
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        alignment: Alignment.bottomCenter,
                        padding: const EdgeInsets.only(left: 24),
                        height: 35,
                        child: const Text(
                          'Add New Patient',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          right: 8,
                          top: 10,
                        ),
                        child: InkWell(
                          onTap: () {
                            _nameCtrl.clear();
                            _ageCtrl.clear();
                            _nameErrMsg = '';
                            _ageErrMsg = '';
                            Navigator.of(context).pop();
                          },
                          child: const Icon(
                            Icons.cancel,
                            color: kColorPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(15, 20.0, 15, 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(
                          height: 44,
                          width: double.infinity,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.grey,
                              width: 0.5,
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: TextFormField(
                            controller: _nameCtrl,
                            cursorColor: Colors.grey,
                            autocorrect: false,
                            decoration: const InputDecoration(
                              isDense: true,
                              border: InputBorder.none,
                              hintText: 'Name',
                            ),
                            onChanged: (String? val) => _validateName(
                              val,
                              setState,
                            ),
                          ),
                        ),
                        Container(
                          height: _nameErrMsg.isEmpty ? 0 : null,
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 6, left: 16),
                            child: Text(
                              _nameErrMsg,
                              style: const TextStyle(
                                color: kColorPrimary,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                          height: 44,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.grey,
                              width: 0.5,
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: TextFormField(
                            controller: _ageCtrl,
                            cursorColor: Colors.grey,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              isDense: true,
                              border: InputBorder.none,
                              hintText: 'Age',
                            ),
                            onChanged: (String? val) => _validateAge(
                              val,
                              setState,
                            ),
                          ),
                        ),
                        Container(
                          height: _ageErrMsg.isEmpty ? 0 : null,
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 6, left: 16),
                            child: Text(
                              _ageErrMsg,
                              style: const TextStyle(
                                color: kColorPrimary,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Container(
                          height: 40,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    SizedBox(
                                      height: 20,
                                      width: 30,
                                      child: Radio(
                                        value: SelectGender.male,
                                        groupValue: _gender,
                                        onChanged: (SelectGender? value) {
                                          setState(() => _gender = value!);
                                        },
                                      ),
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(
                                            () => _gender = SelectGender.male,
                                          );
                                        },
                                        child: const Text(
                                          'Male',
                                          style: TextStyle(fontSize: 13),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                width: 12,
                              ),
                              Expanded(
                                flex: 2,
                                child: Row(
                                  children: [
                                    SizedBox(
                                      height: 20,
                                      width: 30,
                                      child: Radio(
                                          value: SelectGender.female,
                                          groupValue: _gender,
                                          onChanged: (SelectGender? value) {
                                            setState(() => _gender = value!);
                                          }),
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(
                                            () => _gender = SelectGender.female,
                                          );
                                        },
                                        child: const Text(
                                          'Female',
                                          style: TextStyle(fontSize: 13),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 5,),
                        Material(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(5),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(5),
                            onTap: () => _onPressedSaveMember(setState),
                            child: Container(
                              height: 30,
                              alignment: Alignment.center,
                              margin: const EdgeInsets.all(8.0),
                              child: const Text(
                                "Save",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  _onDismissed(
    context,
    SlibableAction action, [
    int index = 0,
    int? memberId = 0,
  ]) {
    //debugPrint('removing $index');
    switch (action) {
      case SlibableAction.cancel:
        break;
      case SlibableAction.delete:
        showConfirmationAlert(
          context,
          _onPressedCancelBtn,
          () => _onPressedContinueBtn(index, memberId),
          "Warning message",
          "Are you sure you want to remove this member.",
        );
        break;
    }
  }

  //
  _onPressedSaveMember(setState) {
    // custom inputs error messages
    _validateName(_nameCtrl.value.text, setState);
    _validateAge(_ageCtrl.value.text, setState);
    // form validate
    bool customValidation = _customValidateForm();
    if (customValidation) {
      showDialogBox(context);
      _onPostSaveMember();
    }
  }

  //
  _onPostSaveMember() async {
    // check internet connectivity
    final hasInternet = await _hasInternetConnection();
    if (hasInternet) {
      final gender = _gender == SelectGender.male ? 1 : 0;
      final Map<String, dynamic> member = {
        'HP_Name': _nameCtrl.value.text,
        'HP_Age': _ageCtrl.value.text,
        'HP_Gender': gender,
      };
      final message = await MemberService().onSaveMember(member, widget.mobile);
      _onDoneSaveMember(message);
    } else {
      Fluttertoast.showToast(
        msg: 'No internet connection',
        toastLength: Toast.LENGTH_LONG,
      );
    }
  }

  //
  _onDoneSaveMember(String message) {
    if (message == 'Success!') {
      const newIndex = 0;
      final gender = _gender == SelectGender.male ? true : false;
      final Map<String, dynamic> newItem = {
        'HP_Name': _nameCtrl.value.text,
        'HP_Age': _ageCtrl.value.text,
        'HP_Gender': gender,
      };
      _membersData.insert(newIndex, newItem);
      _animatedListKey.currentState!.insertItem(
        newIndex,
      );
      Fluttertoast.showToast(
        msg: 'New patient added successfully',
        toastLength: Toast.LENGTH_LONG,
      );
      _nameCtrl.clear();
      _ageCtrl.clear();
      Navigator.of(context).pop(); //stop loading
      Navigator.of(context).pop(); //hide form
    } else {
      Navigator.of(context).pop(); //stop loading
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
      );
    }
  }

  //
  _onPressedCancelBtn() {
    Navigator.of(context).pop();
  }

  //
  _onPressedContinueBtn(int index, int? memberId) {
    Navigator.of(context).pop();
    if (memberId != null) {
      showDialogBox(context);
      _onPostRemoveMember(memberId).then((String message) {
        if (message == 'Success!') {
          Navigator.of(context).pop();
          _removeItem(index);
        } else {
          Fluttertoast.showToast(
            msg: message,
            toastLength: Toast.LENGTH_LONG,
          );
        }
      });
    } else {
      Fluttertoast.showToast(
        msg: 'Newly added members are not removable until page is reloaded',
        toastLength: Toast.LENGTH_LONG,
      );
    }
  }

  Future<String> _onPostRemoveMember(int memberId) async {
    // check internet connectivity
    final hasInternet = await _hasInternetConnection();
    if (hasInternet) {
      final message = await MemberService().onRemoveMember(memberId);
      return message;
    } else {
      return 'No internet connection';
    }
  }

  //
  _removeItem(int index) {
    final removedItem = _membersData[index];
    _membersData.removeAt(index);
    _animatedListKey.currentState!.removeItem(
      index,
      (context, animation) => AnimatedListItem(
        item: removedItem,
        animation: animation,
      ),
    );
    Fluttertoast.showToast(
      msg: 'Member has been removed successfully',
      toastLength: Toast.LENGTH_LONG,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hami/colors.dart';
import 'package:flutter_hami/screens/dashboard_page.dart';
import 'package:flutter_hami/widget/animated_list_item.dart';
import 'package:flutter_hami/widget/show_confirmation_alert.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';

const kColorBg = Color(0xfff2f6fe);
enum SlibableAction {delete, cancel}
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

  // node
  final _nameNode = FocusNode();

  // select gender
  SelectGender _gender = SelectGender.male;

  // data
  final List _membersData = [
    {
      'idx': 1,
      'name': 'Adeel Safdar',
      'gender': 'Male',
      'age': 25
    },
    {
      'idx': 2,
      'name': 'Muhammad Anas',
      'gender': 'Male',
      'age': 35
    },
    {
      'idx': 3,
      'name': 'Shehroz Kamal',
      'gender': 'Male',
      'age': 29
    },
    {
      'idx': 4,
      'name': 'Raja Bilal Nazir',
      'gender': 'Male',
      'age': 28
    },
    {
      'idx': 5,
      'name': 'Sajid Mehmood',
      'gender': 'Male',
      'age': 27
    },
    {
      'idx': 6,
      'name': 'Khawaja Wajih Ur Rehman',
      'gender': 'Male',
      'age': 35
    }
  ];

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
    setState(() {
      if(textVal != null && textVal.isNotEmpty) {
        _nameErrMsg = '';
      }else {
        _nameErrMsg = 'Name field is required';
      }
    });
  }
  _validateAge(String? textVal, setState) {
    setState(() {
      if(textVal != null && textVal.isNotEmpty) {
        // not a number
        if(RegExp(r'^[a-z]+$').hasMatch(_ageCtrl.value.text)) {
          _ageErrMsg = 'Age is not a valid number';
        } else {
          _ageErrMsg = '';
        }
      } else {
        _ageErrMsg = 'Age field is required';
      }
    });
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
            backgroundColor: kColorBg,//ios status bar colors
            systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarColor: kColorBg,//android status bar color
              statusBarBrightness: Brightness.light, // For iOS: (dark icons)
              statusBarIconBrightness: Brightness.dark, // For Android: (dark icons)
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _onPressedFabBtn,
          backgroundColor: kColorPrimary,
          child: const Icon(Icons.add),
        ),
        body: ListView(
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
                                builder: (context) => DashboardPage(mobile: widget.mobile),
                              ), (Route<dynamic> route) => false,
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
                              'Members',
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
                  const SizedBox(height: 15,),
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
                        onChanged: (String? textVal) => setState(() => {}),
                        cursorColor: Colors.grey,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          border: InputBorder.none,
                          icon: Icon(Icons.search, color: Colors.grey.shade400,),
                          hintText: 'Search here',
                          hintStyle: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.w500),
                          suffixIcon: _searchMembersCtrl.text.isNotEmpty ? GestureDetector(onTap: _clearSearch,child: const Icon(Icons.clear, color: Colors.black87,),) : null,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15,),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18,),
                      margin: const EdgeInsets.only(bottom: 30,),
                      child: AnimatedList(
                        key: _animatedListKey,
                        initialItemCount: _membersData.length,
                        itemBuilder: (context, idx, animation) {
                          return Container(
                            margin: const EdgeInsets.all(4.0),
                            child: Slidable(
                              startActionPane: ActionPane(
                                motion: const ScrollMotion(),
                                children: [
                                  SlidableAction(
                                    borderRadius: BorderRadius.circular(10),
                                    onPressed: (context) => _onDismissed(context, idx, SlibableAction.delete),
                                    backgroundColor: kColorPrimary,
                                    foregroundColor: Colors.white,
                                    icon: Icons.delete,
                                    label: 'Delete',
                                  ),
                                  SlidableAction(
                                    borderRadius: BorderRadius.circular(10),
                                    onPressed: (context) => _onDismissed(context, idx, SlibableAction.cancel),
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
                                    borderRadius: BorderRadius.circular(10),
                                    onPressed: (context) => _onDismissed(context, idx, SlibableAction.delete),
                                    backgroundColor: kColorPrimary,
                                    foregroundColor: Colors.white,
                                    icon: Icons.delete,
                                    label: 'Delete',
                                  ),
                                  SlidableAction(
                                    borderRadius: BorderRadius.circular(10),
                                    onPressed: (context) => _onDismissed(context, idx, SlibableAction.cancel),
                                    backgroundColor: Colors.blueAccent,
                                    foregroundColor: Colors.white,
                                    icon: Icons.cancel,
                                    label: 'Cancel',
                                  ),
                                ],
                              ),
                              child: AnimatedListItem(
                                item: _membersData[idx],
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
        ),
      ),
    );
  }

  // custom validate form
  bool _customValidateForm() {
    // name
    if(_nameCtrl.value.text.isEmpty) {
      // required
      return false;
    }
    // age
    if(_ageCtrl.value.text.isEmpty) {
      // required
      return false;
    } else {
      // not a number
      if(RegExp(r'^[a-z]+$').hasMatch(_ageCtrl.value.text)) {
        return false;
      }
    }
    return true;
  }

  _onPressedFabBtn() {
    _openDialogue();
  }

  _openDialogue() => showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
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
                        child: const Text('Add New Patient', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: InkWell(
                          onTap: () {
                            _nameCtrl.clear();
                            _ageCtrl.clear();
                            _nameErrMsg = '';
                            _ageErrMsg = '';
                            Navigator.of(context).pop();
                          },
                          child: const Icon(Icons.cancel, color: kColorPrimary,),
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
                                color: Colors.grey, width: 0.5, style: BorderStyle.solid
                            ),
                          ),
                          child: TextFormField(
                            controller: _nameCtrl,
                            cursorColor: Colors.grey,
                            autocorrect: false,
                            decoration: const InputDecoration(
                                isDense: true,
                                border: InputBorder.none,
                                hintText: 'Name'
                            ),
                            onChanged: (String? val) => _validateName(val, setState),
                          ),
                        ),
                        Container(
                          height: _nameErrMsg.isEmpty ? 0: null,
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
                        const SizedBox(height: 10,),
                        Container(
                          height: 44,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: Colors.grey, width: 0.5, style: BorderStyle.solid
                            ),
                          ),
                          child: TextFormField(
                            controller: _ageCtrl,
                            cursorColor: Colors.grey,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                isDense: true,
                                border: InputBorder.none,
                                hintText: 'Age'
                            ),
                            onChanged: (String? val) => _validateAge(val, setState),
                          ),
                        ),
                        Container(
                          height: _ageErrMsg.isEmpty ? 0: null,
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
                        const SizedBox(height: 5,),
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
                                          }
                                      ),
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() => _gender = SelectGender.male);
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
                              const SizedBox(width: 12,),
                              Expanded(
                                flex: 3,
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
                                          }
                                      ),
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() => _gender = SelectGender.female);
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
                        Container(
                          height: 44,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          margin: const EdgeInsets.all(8.0),
                          child: TextButton(
                            child: const Text("Save", style: TextStyle(color: Colors.white),),
                            onPressed: () {
                              // custom inputs error messages
                              _validateName(_nameCtrl.value.text, setState);
                              _validateAge(_ageCtrl.value.text, setState);
                              // form validate
                              bool customValidation = _customValidateForm();
                              if (customValidation) {
                                const newIndex = 0;
                                final newItem = {
                                  'idx': _membersData.length+1,
                                  'name': _nameCtrl.value.text,
                                  'age': _ageCtrl.value.text,
                                  'gender': _gender==SelectGender.male ? 'male':'female',
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
                                Navigator.of(context).pop();
                              }
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            )
      )
  );

  _onDismissed(context, int index, SlibableAction action) {
    //debugPrint('removing $index');
    switch(action) {
      case SlibableAction.cancel:
        break;
      case SlibableAction.delete:
        showConfirmationAlert(context, _onPressedCancelBtn, () => _onPressedContinueBtn(index),
          "Warning message",
          "Are you sure you want to remove this member.",
        );
        break;
    }
  }
  //
  _onPressedCancelBtn() {
    Navigator.of(context).pop();
  }
  //
  _onPressedContinueBtn(int index) {
    Navigator.of(context).pop();
    _removeItem(index);
  }
  //
  _removeItem(int index) {
    debugPrint(index.toString());
    final removedItem = _membersData[index];
    _membersData.removeAt(index);
    _animatedListKey.currentState!.removeItem(
      index,
      (context, animation) => AnimatedListItem(item: removedItem, animation: animation),
    );
  }
}

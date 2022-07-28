import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hami/colors.dart';
import 'package:flutter_hami/screens/dashboard_page.dart';
import 'package:flutter_hami/widget/animated_list_item.dart';
import 'package:flutter_hami/widget/show_confirmation_alert.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

const kColorBg = Color(0xfff2f6fe);
enum SlibableAction {delete, cancel}

class MembersPage extends StatefulWidget {
  final String mobile;
  const MembersPage({required this.mobile, Key? key}) : super(key: key);

  @override
  State<MembersPage> createState() => _MembersPageState();
}

class _MembersPageState extends State<MembersPage> {

  final _animatedListKey = GlobalKey<AnimatedListState>();

  final _searchMembersCtrl = TextEditingController();
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
      'name': 'Sheroz Kamal',
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
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey,
                          width: 0.3,
                        ),
                      ),
                      child: TextFormField(
                        controller: _searchMembersCtrl,
                        onChanged: (String? textVal) => setState(() => {}),
                        cursorColor: Colors.grey,
                        decoration: InputDecoration(
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

  _onDismissed(BuildContext context, int index, SlibableAction action) {
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
    // setState(() => _membersData.removeAt(index));
  }
}

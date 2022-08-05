import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hami/colors.dart';
import 'package:flutter_hami/model/shared_preference.dart';
import 'package:flutter_hami/screens/auth/login_page.dart';
import 'package:flutter_hami/screens/user/awareness_material_page.dart';
import 'package:flutter_hami/screens/user/members_page.dart';
import 'package:flutter_hami/screens/user/record_page.dart';
import 'package:badges/badges.dart';

class DashboardPage extends StatefulWidget {
  final String mobile;
  const DashboardPage({required this.mobile, Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      drawer: const Drawer(),
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
                      onTap: () {},
                      borderRadius: BorderRadius.circular(10),
                      child: Badge(
                        badgeContent: const Text(
                          '3',
                          style: TextStyle(color: Colors.black),
                        ),
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
                                    height: 6,
                                    width: 6,
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
                          onTap: _onPressedMembers,
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
                          onTap: _onPressedRecord,
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
                          onTap: _onPressedAwarenessMaterial,
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
                          onTap: () {},
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
                          onTap: () {},
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
    );
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

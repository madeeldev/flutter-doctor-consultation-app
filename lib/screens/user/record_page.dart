import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hami/screens/dashboard_page.dart';
import 'package:flutter_hami/screens/user/record_add_page.dart';

import '../../colors.dart';

const kColorBg = Color(0xfff2f6fe);
enum Menu { editRecord, removeRecord }

class RecordPage extends StatefulWidget {
  final String mobile;
  const RecordPage({
    required this.mobile,
    Key? key
  }) : super(key: key);

  @override
  State<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {

  // data
  final List _membersData = [
    {
      'idx': 1,
      'name': 'Adeel Safdar',
      'gender': 'male',
      'age': 25
    },
    {
      'idx': 2,
      'name': 'Muhammad Anas',
      'gender': 'male',
      'age': 35
    },
    {
      'idx': 3,
      'name': 'Shehroz Kamal',
      'gender': 'male',
      'age': 29
    },
    {
      'idx': 4,
      'name': 'Raja Bilal Nazir',
      'gender': 'male',
      'age': 28
    },
    {
      'idx': 5,
      'name': 'Sajid Mehmood',
      'gender': 'male',
      'age': 27
    },
    {
      'idx': 6,
      'name': 'Khawaja Wajih Ur Rehman',
      'gender': 'male',
      'age': 35
    },
    {
      'idx': 7,
      'name': 'Rida Zara',
      'gender': 'female',
      'age': 35
    }
  ];

  _onPressedFab() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => RecordAddPage(mobile: widget.mobile,)));
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
          onPressed: _onPressedFab,
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
                              'Record',
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
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      hint: const Align(alignment: Alignment.centerLeft ,child: Text('Select an option'),),
                      borderRadius: BorderRadius.circular(10),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.only(left: 20, right: 15, bottom: 12, top: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(color: Colors.grey, width: 1),
                        ),
                      ),
                      items: _membersData.map((item) {
                        return DropdownMenuItem(
                          value: item['idx'].toString(),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Expanded(
                                child: Text(
                                  item['name'],
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (String? val) {},
                    ),
                  ),
                  const SizedBox(height: 20,),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Thursday, 03/22/2019',
                            style: TextStyle(
                              color: Colors.black.withOpacity(0.8),
                            ),
                          ),
                        ),
                        PopupMenuButton<Menu>(
                          onSelected: (Menu item) {
                            // setState(() {
                            //   _selectedMenu = item.name;
                            // });
                          },
                          icon: Icon(Icons.more_vert, color: Colors.black.withOpacity(0.8),),
                          itemBuilder: (BuildContext context) => <PopupMenuEntry<Menu>>[
                            const PopupMenuItem<Menu>(
                              value: Menu.editRecord,
                              child: Text('Edit'),
                            ),
                            const PopupMenuItem<Menu>(
                              value: Menu.removeRecord,
                              child: Text('Remove'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5,),
                  Container(
                    width: size.width,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Card(
                      child: ClipPath(
                        clipper: ShapeBorderClipper(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(15),
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
                              const Text(
                                'Blood Pressure',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 10,),
                              Container(
                                padding: const EdgeInsets.only(left: 15),
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
                                          const Text('SBP: '),
                                          const Text(
                                            '1.0',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
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
                                          const Text('DBP: '),
                                          const Text(
                                            '1.0',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 5,),
                              Container(
                                padding: const EdgeInsets.only(left: 15),
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
                                          const Text('Heart Rate: '),
                                          const Text(
                                            '1.0',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
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
                                          const Text('Medication: '),
                                          const Text(
                                            'Yes',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 15,),
                              const Text(
                                'Blood Glucose',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 10,),
                              Container(
                                padding: const EdgeInsets.only(left: 15),
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
                                          const Expanded(
                                            child: Text(
                                              '1.0 mg/dl',
                                              style: TextStyle(
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
                                          const Expanded(child: Text('Before Breakfast', overflow: TextOverflow.ellipsis,)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 15,),
                              const Text(
                                'Height & Weight',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 10,),
                              Container(
                                padding: const EdgeInsets.only(left: 15),
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
                                          const Expanded(
                                            child: Text(
                                              '1.0 cm',
                                              style: TextStyle(
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
                                          const Expanded(child: Text('1.0 kg', overflow: TextOverflow.ellipsis,)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 5,),
                              Container(
                                padding: const EdgeInsets.only(left: 15),
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
                                          const Expanded(
                                            child: Text(
                                              '1.0 in',
                                              style: TextStyle(
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
                                            image: const AssetImage('assets/images/bmi_icon.png'),
                                            width: 20,
                                            color: Colors.red[900],
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          const Text('Obesity'),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12,),
                              Container(
                                padding: const EdgeInsets.only(left: 15),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Image(
                                            image: const AssetImage('assets/images/bmi_icon.png'),
                                            width: 30,
                                            color: Colors.red[900],
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          const Text('Body Mass Index (BMI): '),
                                          const Expanded(
                                            child: Text(
                                              '1000.0',
                                              style: TextStyle(
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
                              const SizedBox(height: 10,),
                            ],
                          ),
                        ),
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
}

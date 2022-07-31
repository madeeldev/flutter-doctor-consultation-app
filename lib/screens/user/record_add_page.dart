import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hami/screens/user/record_page.dart';

import '../../colors.dart';


class RecordAddPage extends StatefulWidget {
  final String mobile;
  const RecordAddPage({
    required this.mobile,
    Key? key,
  }) : super(key: key);

  @override
  State<RecordAddPage> createState() => _RecordAddPageState();
}

class _RecordAddPageState extends State<RecordAddPage> {

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
                                builder: (context) => RecordPage(mobile: widget.mobile),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

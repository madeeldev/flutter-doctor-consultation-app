import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hami/screens/dashboard_page.dart';
import 'package:flutter_hami/screens/user/user-material/videos_page.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../colors.dart';

const kColorBg = Color(0xfff2f6fe);

enum TileType {
  videos,
  dietChart,
  bloodPressureRamazan,
  bloodPressureHeartDisease
}

class AwarenessMaterialPage extends StatefulWidget {
  final String mobile;
  const AwarenessMaterialPage({required this.mobile, Key? key})
      : super(key: key);

  @override
  State<AwarenessMaterialPage> createState() => _AwarenessMaterialPageState();
}

class _AwarenessMaterialPageState extends State<AwarenessMaterialPage> {
  final _actionLabel = [
    {
      'en': 'Videos',
      'ur': 'ویڈیوز',
      'icon': TablerIcons.video,
      'action': TileType.videos
    },
    {
      'en': 'Diet Chart',
      'ur': 'ڈائیٹ چارٹ',
      'icon': Icons.medical_information,
      'action': TileType.dietChart
    },
    {
      'en': 'Blood Pressure',
      'en1': '& Ramazan',
      'ur': 'بلڈپریشراوررمضان, ',
      'icon': TablerIcons.stethoscope,
      'action': TileType.bloodPressureRamazan
    },
    {
      'en': 'Blood Pressure',
      'en1': '& Heart Disease',
      'ur': 'بلڈپریشراورامراضِ دل',
      'icon': Icons.monitor_heart_outlined,
      'action': TileType.bloodPressureHeartDisease
    },
  ];

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
          backgroundColor: kColorPrimary, //ios status bar colors
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: kColorPrimary, //android status bar color
            statusBarBrightness: Brightness.dark, // For iOS: (dark icons)
            statusBarIconBrightness:
                Brightness.light, // For Android: (dark icons)
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: size.height * 0.38,
            decoration: const BoxDecoration(
              color: kColorPrimary,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
            ),
            child: Stack(
              children: [
                Positioned(
                  left: size.width * 0.045,
                  top: 20,
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) => DashboardPage(
                                mobile: widget.mobile,
                              ),
                            ),
                            (Route<dynamic> route) => false,
                          );
                        },
                        child: const Icon(
                          Icons.arrow_back_ios,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                      Container(
                        width: size.width * 0.89,
                        padding: EdgeInsets.only(
                          right: size.width * 0.06,
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'Awareness Material',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 25),
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
                        height: size.height * 0.15,
                        width: size.height * 0.15,
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
                              height: size.height * 0.15,
                              width: size.height * 0.15,
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
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: GridView(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisExtent: size.height * 0.22,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 10,
                ),
                children: List.generate(4, (idx) {
                  return Material(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white.withOpacity(0.9),
                    child: InkWell(
                      borderRadius: BorderRadius.all(
                        Radius.circular((size.height * 0.01)),
                      ),
                      onTap: () => _onTapGridTile(
                        _actionLabel[idx]['action'] as TileType,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Transform.rotate(
                            angle: 4,
                            child: Container(
                              width: 60,
                              height: 60,
                              color: kColorPrimary.withOpacity(0.9),
                              child: Transform.rotate(
                                angle: -4,
                                child: Icon(
                                  _actionLabel[idx]['icon'] as IconData,
                                  size: 35,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          _actionLabel[idx]['en1'] == null
                              ? Column(
                                  children: [
                                    Text(
                                      _actionLabel[idx]['en'].toString(),
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 3,
                                    ),
                                    Text(
                                      _actionLabel[idx]['ur'].toString(),
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'Jameel-Noori-Nastaleeq',
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  //mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _actionLabel[idx]['en'].toString(),
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      _actionLabel[idx]['en1'].toString(),
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 4,
                                    ),
                                    Text(
                                      _actionLabel[idx]['ur'].toString(),
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'Jameel-Noori-Nastaleeq',
                                      ),
                                    ),
                                  ],
                                ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  //
  _onTapGridTile(TileType action) {
    debugPrint(action.toString());
    switch (action) {
      case TileType.videos:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const VideosPage(),
          ),
        );
        break;
      case TileType.dietChart:
        break;
      case TileType.bloodPressureRamazan:
        break;
      case TileType.bloodPressureHeartDisease:
        break;
    }
  }
}

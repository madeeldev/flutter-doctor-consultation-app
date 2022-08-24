import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TermsAndConditionsPage extends StatelessWidget {
  const TermsAndConditionsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.zero,
        child: AppBar(
          elevation: 0,
          backgroundColor: Colors.white, //ios status bar colors
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.white, //android status bar color
            statusBarBrightness: Brightness.light, // For iOS: (dark icons)
            statusBarIconBrightness:
            Brightness.dark, // For Android: (dark icons)
          ),
        ),
      ),
      body: ListView(
        children: [
          SizedBox(
            height: size.height,
            width: size.width,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 20, 18, 0),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
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
                            'Terms & Conditions',
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
                const SizedBox(
                  height: 20,
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    child: const Text.rich(
                      TextSpan(
                        style: TextStyle(fontSize: 14, height: 1.3),
                        children: [
                          TextSpan(text: 'By '),
                          TextSpan(
                            text: 'downloading or using the app',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text:
                            ' these terms & conditions will automatically apply to you!',
                          ),
                        ],
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

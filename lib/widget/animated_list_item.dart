import 'package:flutter/material.dart';
import 'package:flutter_hami/colors.dart';

class AnimatedListItem extends StatelessWidget {
  final Map<String, dynamic> item;
  final Animation<double> animation;
  const AnimatedListItem(
      {required this.item, required this.animation, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) => SizeTransition(
        sizeFactor: animation,
        child: buildItem(),
      );

  Widget buildItem() => SizedBox(
        height: 90,
        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: 5,
            vertical: 5,
          ),
          decoration: const BoxDecoration(
            color: Colors.orange,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(7),
              bottomLeft: Radius.circular(7),
            ),
            boxShadow:  [
              BoxShadow(
                color: Colors.black12,
                offset: Offset(5, 5),
                blurRadius: 2,
              ),
            ],
          ),
          child: Container(
            margin: const EdgeInsets.only(
              left: 3,
            ),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white,
                    backgroundImage: AssetImage(
                      item['HP_Gender']
                          ? 'assets/images/male.png'
                          : 'assets/images/female.png',
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['HP_Name'],
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
                          height: 2,
                        ),
                        Row(
                          children: [
                            Text(
                              item['HP_Gender'] ? 'Male' : 'Female',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Text(
                              '- ${item['HP_Age']} years old',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    child: Icon(Icons.swipe, color: kColorPrimary,),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}

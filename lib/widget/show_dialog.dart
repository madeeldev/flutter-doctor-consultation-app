import 'package:flutter/material.dart';

showDialogBox(BuildContext context) => showDialog(context: context, barrierDismissible: false, builder: (BuildContext context) {
  return Dialog(
    child: SizedBox(
      height: 100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: const [
          CircularProgressIndicator(),
          SizedBox(
            height: 10,
          ),
          Text("Loading..."),
        ],
      ),
    ),
  );
});
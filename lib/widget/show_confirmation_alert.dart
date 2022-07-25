import 'package:flutter/material.dart';

Future showConfirmationAlert(BuildContext context, onPressedCancelBtn, onPressedContinueBtn, alertTitle, alertMessage) {
  Widget cancelButton = TextButton(
    style: TextButton.styleFrom(
      primary: Colors.blue,
    ),
    onPressed: onPressedCancelBtn,
    child: const Text("Cancel"),
  );
  Widget continueButton = TextButton(
    style: TextButton.styleFrom(
      primary: Colors.blue,
    ),
    onPressed: onPressedContinueBtn,
    child: const Text("Continue"),
  );

  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(alertTitle),
        content: Text(alertMessage),
        actions: [
          cancelButton,
          continueButton,
        ],
      );
    },
  );
}
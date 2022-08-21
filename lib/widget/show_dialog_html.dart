import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

showDialogHtml(BuildContext context, String title, String content, actions) {
  return showDialog(
    barrierDismissible: false,
    context: context,
    builder: (_) => AlertDialog(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 18,
      ),
      title: Center(child: Text(title)),
      content: SingleChildScrollView(
        child: Column(
          children: [
            Html(
              data: """
              <span style='color: #2d2d2d; font-size: 14; font-weight: 500;'>$content<bird></bird></span>
              """,
            ),
          ],
        ),
      ),
      actions: actions,
    ),
  );
}

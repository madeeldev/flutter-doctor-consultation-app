import 'package:flutter/material.dart';

connectivityBanner(context, String contentText, onPressed) => ScaffoldMessenger.of(context)
  ..removeCurrentMaterialBanner()
  ..showMaterialBanner(
    MaterialBanner(
      elevation: 1,
      backgroundColor: const Color(0xff2c3e50),
      leadingPadding: const EdgeInsets.only(right: 12),
      content: Text(
        contentText,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: Colors.white,),
      ),
      contentTextStyle: const TextStyle(color: Colors.white),
      forceActionsBelow: true,
      actions: [
        TextButton(
          onPressed: onPressed,
          child: const Text('Dismiss', style: TextStyle(color: Colors.white),),
        ),
      ],
    ),
  );
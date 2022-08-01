import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_hami/config.dart';
import 'package:http/http.dart' as http;
class MemberService {

  Future<Map<String, dynamic>> onLoadMembers(String mobile) async {
    try {
      final postUrl = '${Config.getMembersUrl}?mobile=$mobile&api_key=${Config.apiKey}';
      final res = await http.get(Uri.parse(postUrl), headers: {
        "Accept": "application/json",
        "Access-Control-Allow-Origin": "*"
      });
      if (res.statusCode == 200) {
        final result = json.decode(res.body)['sp_Hami_Patient_Result'];
        return {
          'message' : 'success',
          'data': result
        };
      } else {
        return {
          'message' : 'Server error occurred',
        };
      }
    } on SocketException catch (_) {
      return {
        'message' : 'Internet is not connected',
      };
    }
  }

}
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config.dart';

class AwarenessDataService {

  Future<Map<String, dynamic>> loadData(String mobile) async {
    try {
      final postUrl = '${Config.getAwarenessDataUrl}?mobile=$mobile&api_key=${Config.apiKey}';
      final res = await http.get(Uri.parse(postUrl), headers: {
        "Accept": "application/json",
        "Access-Control-Allow-Origin": "*"
      });
      if (res.statusCode == 200) {
        final result = json.decode(res.body)['_Hami_Awareness_Material_Result'];
        return {
          'message': 'success',
          'data': result
        };
      } else {
        return {
          'message': 'Server error occurred',
          'data': []
        };
      }
    } on SocketException catch (_) {
      return {
        'message': 'Internet is not connected',
        'data': []
      };
    }
  }

}
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_hami/config.dart';
import 'package:http/http.dart' as http;
class MemberService {

  Future<String> onSaveMember(Map<String, dynamic> member, String mobile) async {
    try {
      final postUrl = '${Config.saveMemberUrl}?mobile=$mobile&pName=${member['HP_Name']}&age=${member['HP_Age']}&gender=${member['HP_Gender']}&api_key=${Config.apiKey}';
      final res = await http.get(Uri.parse(postUrl), headers: {
        "Accept": "application/json",
        "Access-Control-Allow-Origin": "*"
      });
      if (res.statusCode == 200) {
        final result = json.decode(res.body)['hAMI_AP_Result'][0]['remarks'];
        return result;
      } else {
        return 'Server error occurred';
      }
    } on SocketException catch (_) {
      return 'Internet is not connected';
    }
  }

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
  //
  Future<String> onRemoveMember(int memberId) async {
    try {
      final postUrl = '${Config.removeMemberUrl}?pID=$memberId&api_key=${Config.apiKey}';
      final res = await http.get(Uri.parse(postUrl), headers: {
        "Accept": "application/json",
        "Access-Control-Allow-Origin": "*"
      });
      if (res.statusCode == 200) {
        final result = json.decode(res.body)['_HAMI_DP_Result'][0]['remarks'];
        return result;
      } else {
        return 'Server error occurred';
      }
    } on SocketException catch (_) {
      return 'Internet is not connected';
    }
  }
  //
  Future<Map<String, dynamic>> onLoadMemberRecord(String mobile, String memberId) async {
    try {
      final postUrl = '${Config.getMemberRecordUrl}?mobile=$mobile&hp_id=$memberId&api_key=${Config.apiKey}';
      final res = await http.get(Uri.parse(postUrl), headers: {
        "Accept": "application/json",
        "Access-Control-Allow-Origin": "*"
      });
      if (res.statusCode == 200) {
        final result = json.decode(res.body)['_Hami_Patient_Diary_Result'];
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
  //
  Future<String> onSaveMemberRecord(Map<String, String> recordMap) async {
    try {
      final postUrl = Config.saveMemberRecordUrl;
      final res = await http.post(
        Uri.parse(postUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, List<Map<String, String>>>{
          'Hami_Patient_Diary': [recordMap],
        }),
      );
      if (res.statusCode == 200) {
        final result = json.decode(res.body)['message'];
        return result;
      } else {
        return 'Server error occurred';
      }
    } on SocketException catch (_) {
      return 'Internet is not connected';
    }
  }

  Future<String> onRemoveMemberRecord(String mobile, int recordId) async {
    try {
      final postUrl = '${Config.removeMemberRecordUrl}?mobile=$mobile&hpd_id=$recordId&api_key=${Config.apiKey}';
      final res = await http.get(Uri.parse(postUrl), headers: {
        "Accept": "application/json",
        "Access-Control-Allow-Origin": "*"
      });
      if (res.statusCode == 200) {
        final result = json.decode(res.body)['_HDPD_Result'][0]['remarks'];
        return result;
      } else {
        return 'Server error occurred';
      }
    } on SocketException catch (_) {
      return 'Internet is not connected';
    }
  }

  Future<Map<String, dynamic>> onLoadMemberMedicineRecord(String mobile, String memberId) async {
    try {
      final postUrl = '${Config.getMemberMedicineRecordUrl}?mobile=$mobile&hp_id=$memberId&api_key=${Config.apiKey}';
      final res = await http.get(Uri.parse(postUrl), headers: {
        "Accept": "application/json",
        "Access-Control-Allow-Origin": "*"
      });
      if (res.statusCode == 200) {
        final result = json.decode(res.body)['_Hami_Medicine_Result'];
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

  Future<Map<String, dynamic>> onRemoveMemberMedicineRecord(String mobile, String medId) async {
    try {
      final postUrl = '${Config.removeMemberMedicineRecord}?mobile=$mobile&hm_id=$medId&api_key=${Config.apiKey}';
      final res = await http.get(Uri.parse(postUrl), headers: {
        "Accept": "application/json",
        "Access-Control-Allow-Origin": "*"
      });
      if (res.statusCode == 200) {
        final result = json.decode(res.body)['_Hami_DeleteMedicine_Result'];
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
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_hami/config.dart';
import 'package:http/http.dart' as http;

class MemberService {
  Future<String> onSaveMember(
      Map<String, dynamic> member, String mobile) async {
    try {
      final postUrl =
          '${Config.saveMemberUrl}?mobile=$mobile&pName=${member['HP_Name']}&age=${member['HP_Age']}&gender=${member['HP_Gender']}&api_key=${Config.apiKey}';
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
      final postUrl =
          '${Config.getMembersUrl}?mobile=$mobile&api_key=${Config.apiKey}';
      final res = await http.get(Uri.parse(postUrl), headers: {
        "Accept": "application/json",
        "Access-Control-Allow-Origin": "*"
      });
      if (res.statusCode == 200) {
        final result = json.decode(res.body)['sp_Hami_Patient_Result'];
        return {'message': 'success', 'data': result};
      } else {
        return {
          'message': 'Server error occurred',
        };
      }
    } on SocketException catch (_) {
      return {
        'message': 'Internet is not connected',
      };
    }
  }

  //
  Future<String> onRemoveMember(int memberId) async {
    try {
      final postUrl =
          '${Config.removeMemberUrl}?pID=$memberId&api_key=${Config.apiKey}';
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
  Future<Map<String, dynamic>> onLoadMemberRecord(
      String mobile, String memberId) async {
    try {
      final postUrl =
          '${Config.getMemberRecordUrl}?mobile=$mobile&hp_id=$memberId&api_key=${Config.apiKey}';
      final res = await http.get(Uri.parse(postUrl), headers: {
        "Accept": "application/json",
        "Access-Control-Allow-Origin": "*"
      });
      if (res.statusCode == 200) {
        final result = json.decode(res.body)['_Hami_Patient_Diary_Result'];
        return {'message': 'success', 'data': result};
      } else {
        return {
          'message': 'Server error occurred',
        };
      }
    } on SocketException catch (_) {
      return {
        'message': 'Internet is not connected',
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
      final postUrl =
          '${Config.removeMemberRecordUrl}?mobile=$mobile&hpd_id=$recordId&api_key=${Config.apiKey}';
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

  Future<Map<String, dynamic>> onLoadMemberMedicineRecord(
      String mobile, String memberId) async {
    try {
      final postUrl =
          '${Config.getMemberMedicineRecordUrl}?mobile=$mobile&hp_id=$memberId&api_key=${Config.apiKey}';
      final res = await http.get(Uri.parse(postUrl), headers: {
        "Accept": "application/json",
        "Access-Control-Allow-Origin": "*"
      });
      if (res.statusCode == 200) {
        final result = json.decode(res.body)['_Hami_Medicine_Result'];
        return {'message': 'success', 'data': result};
      } else {
        return {
          'message': 'Server error occurred',
        };
      }
    } on SocketException catch (_) {
      return {
        'message': 'Internet is not connected',
      };
    }
  }

  Future<Map<String, dynamic>> onSaveMemberMedicineRecord(
    String mobile,
    String memberId,
    String medName,
    String dose,
    String tim1,
    String tim2,
    String tim3,
    String tim4,
  ) async {
    try {
      final postUrl =
          '${Config.saveMemberMedicineRecordUrl}?mobile=$mobile&pt_id=$memberId&med_desc=$medName&dose=$dose&time1=$tim1&time2=$tim2&time3=$tim3&time4=$tim4&api_key=${Config.apiKey}';
      final res = await http.get(Uri.parse(postUrl), headers: {
        "Accept": "application/json",
        "Access-Control-Allow-Origin": "*"
      });
      if (res.statusCode == 200) {
        final result = json.decode(res.body)['aDD_MED_Result'];
        return {'message': 'success', 'data': result};
      } else {
        return {
          'message': 'Server error occurred',
        };
      }
    } on SocketException catch (_) {
      return {
        'message': 'Internet is not connected',
      };
    }
  }

  Future<Map<String, dynamic>> onRemoveMemberMedicineRecord(
    String mobile,
    String medId,
  ) async {
    try {
      final postUrl =
          '${Config.removeMemberMedicineRecordUrl}?mobile=$mobile&hm_id=$medId&api_key=${Config.apiKey}';
      final res = await http.get(Uri.parse(postUrl), headers: {
        "Accept": "application/json",
        "Access-Control-Allow-Origin": "*"
      });
      if (res.statusCode == 200) {
        final result = json.decode(res.body)['_Hami_DeleteMedicine_Result'];
        return {'message': 'success', 'data': result};
      } else {
        return {
          'message': 'Server error occurred',
        };
      }
    } on SocketException catch (_) {
      return {
        'message': 'Internet is not connected',
      };
    }
  }

  Future<Map<String, dynamic>> onUploadMemberRXImage(
    String mobile,
    File image,
  ) async {
    try {
      String uniqueImgID = DateTime.now()
          .toString()
          .split("-")
          .join("")
          .split(" ")
          .join("")
          .split(":")
          .join("")
          .split(".")[0] +
          mobile;
      String ext = image.path.split('/').last.split('.').last;
      final postUrl = Config.saveMemberRXImageUrl;
      final req = http.MultipartRequest("POST", Uri.parse(postUrl));
      req.fields["name"] = uniqueImgID;
      final uploadImage = await http.MultipartFile.fromPath("file", image.path);
      req.files.add(uploadImage);
      var res = await req.send();
      var resData = await res.stream.toBytes();
      var resString = String.fromCharCodes(resData);
      var result = json.decode(resString);
      return {
        'result': result,
        'uniqueImgID': uniqueImgID,
        'ext': ext
      };
    } on SocketException catch (_) {
      return {
        'result': {
          'success': false,
          'message': 'Internet is not connected'
        },
      };
    }
  }

  Future<Map<String, dynamic>> onSaveMemberRXImageData(
      String mobile,
      String memberId,
      String uniqueImgID,
      String ext,
      ) async {
    try {
      final postUrl =
          '${Config.saveMemberRXImageDataUrl}?mobile=$mobile&pt_id=$memberId&url=${Config.saveMemberRXImageFolderUrl}$uniqueImgID.$ext&api_key=${Config.apiKey}';
      final res = await http.get(Uri.parse(postUrl), headers: {
        "Accept": "application/json",
        "Access-Control-Allow-Origin": "*"
      });
      if (res.statusCode == 200) {
        final result = json.decode(res.body)['hami_Add_Medicine_Image_Result'];
        return {'message': 'success', 'data': result};
      } else {
        return {
          'message': 'Server error occurred',
        };
      }
    } on SocketException catch (_) {
      return {
        'message': 'Internet is not connected',
      };
    }
  }

  Future<Map<String, dynamic>> onLoadMemberRXImage(
      String mobile,
      String memberId,
      ) async {
    try {
      final postUrl = '${Config.getMemberRXImageUrl}?mobile=$mobile&pt_id=$memberId&api_key=${Config.apiKey}';
      final res = await http.get(Uri.parse(postUrl), headers: {
        "Accept": "application/json",
        "Access-Control-Allow-Origin": "*"
      });
      if (res.statusCode == 200) {
        final result = json.decode(res.body)['hami_Medicine_Image_Result'];
        return {'message': 'success', 'data': result};
      } else {
        return {
          'message': 'Server error occurred',
        };
      }
    } on SocketException catch (_) {
      return {
        'message': 'Internet is not connected',
      };
    }
  }

  Future<Map<String, dynamic>> onSendMemberMsg(
      String mobile,
      String memberId,
      String msg,
      ) async {
    try {
      final postUrl = '${Config.saveMemberMsgUrl}?mobile=$mobile&hp_id=$memberId&ask=$msg&api_key=${Config.apiKey}';
      final res = await http.get(Uri.parse(postUrl), headers: {
        "Accept": "application/json",
        "Access-Control-Allow-Origin": "*"
      });
      if (res.statusCode == 200) {
        final result = json.decode(res.body)['aSK_Result'];
        return {'message': 'success', 'data': result};
      } else {
        return {
          'message': 'Server error occurred',
        };
      }
    } on SocketException catch (_) {
      return {
        'message': 'Internet is not connected',
      };
    }
  }

  Future<Map<String, dynamic>> onLoadMemberNotifications(
      String mobile,
      ) async {
    try {
      final postUrl = '${Config.getNotificationsUrl}?mobile=$mobile&api_key=${Config.apiKey}';
      final res = await http.get(Uri.parse(postUrl), headers: {
        "Accept": "application/json",
        "Access-Control-Allow-Origin": "*"
      });
      if (res.statusCode == 200) {
        final result = json.decode(res.body)['_Hami_Notifications_Result'];
        return {'message': 'success', 'data': result};
      } else {
        return {
          'message': 'Server error occurred',
        };
      }
    } on SocketException catch (_) {
      return {
        'message': 'Internet is not connected',
      };
    }
  }

  Future<Map<String, dynamic>> onUpdateMemberNotification(
      int aId
      ) async {
    try {
      final postUrl = '${Config.updateNotificationUrl}?haa_id=$aId&api_key=${Config.apiKey}';
      final res = await http.get(Uri.parse(postUrl), headers: {
        "Accept": "application/json",
        "Access-Control-Allow-Origin": "*"
      });
      if (res.statusCode == 200) {
        final result = json.decode(res.body)['_Hami_UpdateAnswerView_Result'];
        return {'message': 'success', 'data': result};
      } else {
        return {
          'message': 'Server error occurred',
        };
      }
    } on SocketException catch (_) {
      return {
        'message': 'Internet is not connected',
      };
    }
  }
}

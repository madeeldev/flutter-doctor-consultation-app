import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hami/widget/show_confirmation_alert.dart';
import 'package:flutter_hami/widget/show_dialog.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../../colors.dart';
import '../../services/member_service.dart';
import '../../widget/connectivity_banner.dart';
import '../dashboard_page.dart';
import 'medicine_add_page.dart';

const kColorBg = Color(0xfff2f6fe);

enum Menu { removeRecord }

class MedicinePage extends StatefulWidget {
  final String mobile;
  final String? memberId;
  const MedicinePage({required this.mobile, this.memberId, Key? key})
      : super(key: key);

  @override
  State<MedicinePage> createState() => _MedicinePageState();
}

class _MedicinePageState extends State<MedicinePage> {
  // select member
  String? _selectMember;

  // data
  List<dynamic> _membersData = [];
  List<dynamic> _memberRecordData = [];

  // check if page is loaded
  bool _isPageLoaded = false;
  bool _isPageDataLoaded = true;

  File? _pickedFile;

  // has internet
  late StreamSubscription internetSubscription;

  @override
  void initState() {
    internetSubscription =
        InternetConnectionChecker().onStatusChange.listen((status) {
      final hasInternet = status == InternetConnectionStatus.connected;
      if (!hasInternet) {
        connectivityBanner(context, 'No internet connection.',
            () => ScaffoldMessenger.of(context).hideCurrentMaterialBanner());
      } else {
        ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
      }
    });
    // load members data
    _loadMembersData();
    super.initState();
  }

  // check internet
  Future<bool> _hasInternetConnection() async {
    return await InternetConnectionChecker().hasConnection;
  }

  Future _loadMembersData() async {
    // check internet connectivity
    final hasInternet = await _hasInternetConnection();
    if (hasInternet) {
      final membersData = await MemberService().onLoadMembers(widget.mobile);
      final message = membersData['message'];
      if (message == 'success') {
        final data = membersData['data'];
        if (widget.memberId != null) {
          _selectMember = widget.memberId;
        } else {
          if (data.isNotEmpty) {
            _selectMember = data[0]['HP_ID'].toString();
          }
        }
        _membersData = data;
        await _loadMemberRecordData();
      } else {
        Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_LONG,
        );
      }
    } else {
      Fluttertoast.showToast(
        msg: 'No internet connection',
        toastLength: Toast.LENGTH_LONG,
      );
    }
  }

  //
  Future _loadMemberRecordData() async {
    // check internet connectivity
    final hasInternet = await _hasInternetConnection();
    if (hasInternet) {
      if (_selectMember != null) {
        final memberRecordData = await MemberService()
            .onLoadMemberMedicineRecord(widget.mobile, _selectMember!);
        final message = memberRecordData['message'];
        if (message == 'success') {
          final data = memberRecordData['data'];
          setState(() {
            _memberRecordData = data;
            _isPageLoaded = true;
          });
        }
      } else {
        setState(() {
          _isPageLoaded = true;
        });
      }
    } else {
      Fluttertoast.showToast(
        msg: 'No internet connection',
        toastLength: Toast.LENGTH_LONG,
      );
    }
  }

  _onPressedFab() {
    if (_membersData.isNotEmpty) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => MedicineAddPage(
            mobile: widget.mobile,
            memberId: _selectMember!,
          ),
        ),
      );
    } else {
      Fluttertoast.showToast(
        msg: 'No members data was found',
        toastLength: Toast.LENGTH_LONG,
      );
    }
  }

  @override
  void dispose() {
    internetSubscription.cancel();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => DashboardPage(
              mobile: widget.mobile,
            ),
          ),
              (Route<dynamic> route) => false,
        );
        return Future.value(true);
      },
      child: Scaffold(
        backgroundColor: kColorBg,
        appBar: PreferredSize(
          preferredSize: Size.zero,
          child: AppBar(
            elevation: 0,
            backgroundColor: kColorBg, //ios status bar colors
            systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarColor: kColorBg, //android status bar color
              statusBarBrightness: Brightness.light, // For iOS: (dark icons)
              statusBarIconBrightness:
                  Brightness.dark, // For Android: (dark icons)
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _isPageLoaded ? _onPressedFab : null,
          backgroundColor: kColorPrimary,
          tooltip: 'Add medicine',
          child: const Icon(Icons.add),
        ),
        body: _isPageLoaded
            ? ListView(
                children: [
                  SizedBox(
                    width: size.width,
                    height: size.height,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(18, 20, 18, 0),
                          child: Row(
                            children: [
                              InkWell(
                                onTap: () {
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          DashboardPage(mobile: widget.mobile),
                                    ),
                                    (Route<dynamic> route) => false,
                                  );
                                },
                                child: const Icon(
                                  Icons.arrow_back_ios,
                                  size: 18,
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  padding:
                                      EdgeInsets.only(right: size.width * 0.06),
                                  alignment: Alignment.center,
                                  child: const Text(
                                    'Medicine',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: DropdownButtonFormField<String>(
                            isExpanded: true,
                            hint: const Align(
                              alignment: Alignment.centerLeft,
                              child: Text('Select an option'),
                            ),
                            value: _selectMember,
                            borderRadius: BorderRadius.circular(10),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.only(
                                  left: 20, right: 15, bottom: 12, top: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: const BorderSide(
                                    color: Colors.grey, width: 1),
                              ),
                            ),
                            items: _membersData.map((item) {
                              return DropdownMenuItem(
                                value: item['HP_ID'].toString(),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item['HP_Name'],
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: _onChangeRecordSelect,
                          ),
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: Colors.white,
                                onPrimary: Colors.black,
                              ),
                              onPressed: _onPressedUploadRX,
                              child: Row(
                                children: const [
                                  Icon(Icons.photo_camera_back_outlined),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text('Upload RX')
                                ],
                              ),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: Colors.white,
                                onPrimary: Colors.black,
                              ),
                              onPressed: _onPressedViewRX,
                              child: Row(
                                children: const [
                                  Icon(Icons.photo_library_outlined),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text('View RX')
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Expanded(
                          child: _isPageDataLoaded
                              ? _loadPageData()
                              : Container(
                                  alignment: Alignment.center,
                                  margin: EdgeInsets.only(
                                    bottom: size.height * 0.15,
                                  ),
                                  child: const CircularProgressIndicator(),
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : const Center(
                child: CircularProgressIndicator(),
              ),
      ),
    );
  }

  //
  Widget _loadPageData() {
    // Size size = MediaQuery.of(context).size;
    List<String> medicineCountTrack = [
      'Once a day',
      'Twice a day',
      'Thrice a day',
      'Four time a day',
    ];
    return _memberRecordData.isEmpty
        ? const Center(
            child: Text('No record was found!'),
          )
        : ListView(
            children: _memberRecordData.map(
            (record) {
              return Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                padding: const EdgeInsets.only(bottom: 15),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    left: BorderSide(
                      color: Colors.orange,
                      width: 3,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      offset: Offset(5, 5),
                      blurRadius: 2,
                    )
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(
                        left: 15,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.medication,
                                    color: Colors.red[900],
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Expanded(
                                    child: Text(
                                      record['HM_Med_Desc'],
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    "(${medicineCountTrack[record['HM_Dose'] - 1]})",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          SizedBox(
                            width: 40,
                            height: 15,
                            child: PopupMenuButton<Menu>(
                              padding: EdgeInsets.zero,
                              onSelected: (Menu menu) => _onSelectedPopupMenu(
                                menu,
                                record['HM_ID'],
                              ),
                              icon: Icon(
                                Icons.more_vert,
                                color: Colors.black.withOpacity(0.8),
                              ),
                              itemBuilder: (BuildContext context) =>
                                  <PopupMenuEntry<Menu>>[
                                const PopupMenuItem<Menu>(
                                  value: Menu.removeRecord,
                                  child: Text('Remove'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 7,
                    ),
                    Container(
                      padding: const EdgeInsets.only(left: 20, bottom: 3),
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        'TIME OF ALL DOSES:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    for (int i = 1; i <= record['HM_Dose']; i++)
                      Container(
                        padding: const EdgeInsets.only(left: 30, bottom: 3),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.fiber_manual_record,
                                  size: 7,
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                const Text(
                                  'Daily Dose at: ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                Expanded(
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.arrow_right_alt_outlined,
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        record['HM_DateTime'].substring(
                                          record['HM_DateTime'].length - 7,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            },
          ).toList());
  }

  //
  _onChangeRecordSelect(String? val) async {
    setState(() {
      _selectMember = val;
      _isPageDataLoaded = false;
    });
    await _loadMemberRecordData();
    setState(() {
      _isPageDataLoaded = true;
    });
  }

  _onSelectedPopupMenu(Menu menu, int medId) {
    switch (menu) {
      case Menu.removeRecord:
        _onPressedRemoveMedicine(medId);
        break;
    }
  }

  //
  _onPressedRemoveMedicine(int medId) {
    showConfirmationAlert(
      context,
      _onPressedCancel,
      () => _onPressedContinue(medId.toString()),
      "Warning message",
      "Are you sure you want to remove this medicine",
    );
  }

  _onPressedCancel() {
    Navigator.of(context).pop();
  }

  _onPressedContinue(String medId) async {
    Navigator.of(context).pop();
    final memberSelected = _selectMember;
    if (memberSelected != null && int.parse(memberSelected) > 0) {
      final message = await _onPostRemoveMedicine(medId);
      _onDoneRemoveMedicine(message);
    } else {
      Fluttertoast.showToast(
        msg: 'Unable to remove this medicine',
        toastLength: Toast.LENGTH_SHORT,
      );
    }
  }

  Future<String> _onPostRemoveMedicine(String medId) async {
    showDialogBox(context);
    final result = await MemberService()
        .onRemoveMemberMedicineRecord(widget.mobile, medId);
    final message = result['message'];
    var data = result['data'];
    if (message == 'success') {
      return data[0]['remarks'];
    } else {
      return message;
    }
  }

  _onDoneRemoveMedicine(String message) async {
    Navigator.of(context).pop();
    if (message == 'Success!') {
      await _onChangeRecordSelect(_selectMember);
      Fluttertoast.showToast(
        msg: 'Member medicine removed successfully',
        toastLength: Toast.LENGTH_SHORT,
      );
    } else {
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
      );
    }
  }

  //
  _onPressedUploadRX() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return SizedBox(
            height: 120.0,
            child: Column(
              children: [
                Expanded(
                  child: ListTile(
                    leading: const Icon(Icons.photo_camera_sharp),
                    title: const Text('Camera'),
                    contentPadding: const EdgeInsets.only(left: 25),
                    onTap: () {
                      Navigator.of(context).pop();
                      _pickImage(ImageSource.camera);
                    },
                  ),
                ),
                Expanded(
                  child: ListTile(
                    leading: const Icon(Icons.image_sharp),
                    title: const Text('Gallery'),
                    contentPadding: const EdgeInsets.only(left: 25),
                    onTap: () {
                      Navigator.of(context).pop();
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                ),
              ],
            ),
          );
        });
  }

  //
  _onPressedViewRX() async {
    // check internet connectivity
    final hasInternet = await _hasInternetConnection();
    if (hasInternet) {
      _onPostViewRX();
    } else {
      Fluttertoast.showToast(
        msg: 'No internet connection',
        toastLength: Toast.LENGTH_SHORT,
      );
    }
  }

  //
  _onPostViewRX() async {
    showDialogBox(context);
    final result = await MemberService()
        .onLoadMemberRXImage(widget.mobile, _selectMember!);
    _onDoneViewRX(result);
  }

  //
  _onDoneViewRX(result) {
    Navigator.of(context).pop();
    final message = result['message'];
    if (message == 'success') {
      final data = result['data'];
      if(data.isNotEmpty) {
        final imageUrl = data[0]['HMI_URL'];
        _showNetworkImage(imageUrl);
      } else {
        Fluttertoast.showToast(
          msg: 'No RX was found on the system',
          toastLength: Toast.LENGTH_SHORT,
        );
      }
    } else {
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
      );
    }
  }

  //
  _showNetworkImage(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: SingleChildScrollView(
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            progressIndicatorBuilder: (_, url, download) {
              if(download.progress != null) {
                final percent = download.progress! * 100;
                return Center(child: Text('${percent.toInt()}% done loading'));
              }
              return const Center(child: Text('Done Loading'));
            },
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
        ),
      ),
    );
  }

  //
  _pickImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return null;
      final tempFile = File(image.path);
      _pickedFile = tempFile;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Center(child: Text('Upload RX')),
          content: SizedBox(
            width: double.maxFinite,
            child: _pickedFile != null
                ? Image.file(
                    _pickedFile!,
                    frameBuilder: (
                      BuildContext context,
                      Widget child,
                      int? frame,
                      bool wasSynchronouslyLoaded,
                    ) {
                      // debugPrint(frame.toString());
                      if (frame != null) {
                        return child;
                      }
                      return Container(
                        height: 5,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFFB71C1C),
                            width: 5,
                          ),
                        ),
                      );
                    },
                  )
                : const Text('Unable to load image!'),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _onPressedUploadImage,
              child: const Text('Upload'),
            )
          ],
        ),
      );
    } on PlatformException catch (e) {
      _pickedFile = null;
      debugPrint('Image not picked');
    }
  }

  //
  _onPressedUploadImage() async {
    if (_pickedFile != null) {
      showDialogBox(context);
      final result = await _onPostUploadImage();
      _onDoneUploadImage(result);
    }
  }

  //
  _onPostUploadImage() async {
    // check internet connectivity
    final hasInternet = await _hasInternetConnection();
    if (hasInternet) {
      final result = await MemberService()
          .onUploadMemberRXImage(widget.mobile, _pickedFile!);
      final res = result['result'];
      if (res['success'] == true) {
        final message = res['message'];
        final uniqueImgID = result['uniqueImgID'];
        final ext = result['ext'];
        return {
          'message': message, //Successfully Uploaded
          'uniqueImgID': uniqueImgID,
          'ext': ext
        };
      } else {
        return {
          'message': 'Unable to upload image. Please try again later',
        };
      }
    } else {
      return {
        'message': 'No internet connection',
      };
    }
  }

  //
  _onDoneUploadImage(result) async {
    final message = result['message'];
    if (message == 'Successfully Uploaded') {
      // save image data
      final uniqueImgID = result['uniqueImgID'];
      final ext = result['ext'];
      final res = await _onSaveImageData(uniqueImgID, ext);
      _onDoneSaveImageData(res);
    } else {
      Navigator.of(context).pop();
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
      );
    }
  }

  //
  _onSaveImageData(String uniqueImgID, String ext) async {
    final result = await MemberService().onSaveMemberRXImageData(
      widget.mobile,
      _selectMember!,
      uniqueImgID,
      ext,
    );
    final message = result['message'];
    if (message == 'success') {
      final data = result['data'];
      return data[0]['remarks'];
    } else {
      return 'Error occurred. Please try again later';
    }
  }

  //
  _onDoneSaveImageData(String message) {
    if (message == 'Success!') {
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      Fluttertoast.showToast(
        msg: 'RX Image has been uploaded successfully',
        toastLength: Toast.LENGTH_SHORT,
      );
    } else {
      Navigator.of(context).pop();
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
      );
    }
  }
}

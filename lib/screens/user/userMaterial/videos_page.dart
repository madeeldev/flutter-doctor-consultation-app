import 'dart:async';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hami/colors.dart';
import 'package:flutter_hami/screens/user/awareness_material_page.dart';
import 'package:flutter_hami/services/awareness_data_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:video_player/video_player.dart';

import '../../../widget/connectivity_banner.dart';

class VideosPage extends StatefulWidget {
  final String mobile;
  const VideosPage({required this.mobile, Key? key}) : super(key: key);

  @override
  State<VideosPage> createState() => _VideosPageState();
}

class _VideosPageState extends State<VideosPage> {
  List _videosData = [];
  bool _isPageLoaded = false;
  bool _playArea = false;
  bool _isPlaying = false;
  bool _disposed = false;
  int _isPlayingIndex = -1;
  VideoPlayerController? _videoPlayerController;

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
    // load data
    _initData();
    super.initState();
  }

  // check internet
  Future<bool> _hasInternetConnection() async {
    return await InternetConnectionChecker().hasConnection;
  }

  _initData() async {
    // check internet connectivity
    final hasInternet = await _hasInternetConnection();
    if (hasInternet) {
      final data = await AwarenessDataService().loadData(widget.mobile);
      final message = data['message'];
      final materialData = data['data'];
      if (message == 'success') {
        final videos = materialData.where((e) => e['HAM_Type'] == 2).toList();
        if (mounted) {
          setState(() {
            _isPageLoaded = true;
            _videosData = videos;
          });
        }
      }
    } else {
      setState(() {
        _isPageLoaded = true;
      });
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _videoPlayerController?.pause();
    _videoPlayerController?.dispose();
    _videoPlayerController = null;
    internetSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => AwarenessMaterialPage(mobile: widget.mobile),
          ),
        );
        return Future.value(true);
      },
      child: Scaffold(
        backgroundColor: kColorPrimary,
        appBar: PreferredSize(
          preferredSize: Size.zero,
          child: AppBar(
            elevation: 0,
            backgroundColor: kColorPrimary, //ios status bar colors
            systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarColor: kColorPrimary, //android status bar color
              statusBarBrightness: Brightness.dark, // For iOS: (dark icons)
              statusBarIconBrightness:
                  Brightness.light, // For Android: (dark icons)
            ),
          ),
        ),
        body: Container(
          width: size.width,
          height: size.height,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                kColorPrimary,
                Colors.white,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            children: [
              _playArea == false
                  ? SizedBox(
                      height: 320,
                      width: size.width,
                      child: Column(
                        children: [
                          Container(
                            height: 20,
                            width: size.width,
                            margin: const EdgeInsets.only(
                              left: 15,
                              top: 20,
                              right: 15,
                            ),
                            alignment: Alignment.topLeft,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => AwarenessMaterialPage(
                                          mobile: widget.mobile,
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Icon(
                                    Icons.arrow_back_ios,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.only(bottom: 30),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: const [
                                        Text(
                                          'HAMI',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 30,
                                            letterSpacing: 4,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          'Awareness Videos',
                                          style: TextStyle(
                                            color: Colors.white,
                                            letterSpacing: 1.5,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : SizedBox(
                      height: 320,
                      width: size.width,
                      child: Column(
                        children: [
                          Expanded(
                            child: _playView(context),
                          ),
                          _controlView(),
                        ],
                      ),
                    ),
              Expanded(
                child: Container(
                  width: size.width,
                  padding: const EdgeInsets.only(top: 30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(size.height * 0.07),
                    ),
                  ),
                  child: _isPageLoaded
                      ? _videosData.isNotEmpty
                          ? ListView.builder(
                              itemCount: _videosData.length,
                              itemBuilder: (_, int idx) {
                                return GestureDetector(
                                  onTap: () {
                                    _onTapVideo(idx);
                                    setState(() {
                                      if (_playArea == false) {
                                        _playArea = true;
                                      }
                                    });
                                  },
                                  child: Column(
                                    children: [
                                      Container(
                                        height: 70,
                                        margin: const EdgeInsets.only(
                                          left: 20,
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              height: 70,
                                              width: 70,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                border: Border.all(
                                                  color: Colors.black26,
                                                ),
                                                image: DecorationImage(
                                                  image:
                                                      CachedNetworkImageProvider(
                                                    _videosData[idx]
                                                        ['HAM_Thumbnail'],
                                                  ),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              child: const Icon(
                                                Icons.play_circle,
                                                color: Colors.white,
                                              ),
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 10),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    SizedBox(
                                                      child: Text(
                                                        _videosData[idx]
                                                            ['HAM_Desc'],
                                                        style: const TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 8,
                                                    ),
                                                    Text(
                                                      'Click on video to play',
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.black
                                                            .withOpacity(0.5),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        children: [
                                          const SizedBox(
                                            width: 20,
                                          ),
                                          for (var i = 0; i < 70; i++)
                                            i.isEven
                                                ? Container(
                                                    width: 3,
                                                    height: 1,
                                                    decoration: BoxDecoration(
                                                      color: Colors.red,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              2),
                                                    ),
                                                  )
                                                : Container(
                                                    width: 3,
                                                    height: 1,
                                                    color: Colors.white,
                                                  ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            )
                          : Container(
                              alignment: Alignment.center,
                              margin: const EdgeInsets.only(
                                bottom: 20,
                              ),
                              child: const Text('No videos was found to play.'),
                            )
                      : Container(
                          alignment: Alignment.center,
                          margin: const EdgeInsets.only(
                            bottom: 20,
                          ),
                          child: const CircularProgressIndicator(),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //
  _onTapVideo(int index) {
    _initializeVideo(index);
  }

  //
  _initializeVideo(int index) {
    final controller =
        VideoPlayerController.network(_videosData[index]['HAM_URL']);
    final old = _videoPlayerController;
    _videoPlayerController = controller;
    if (old != null) {
      old.removeListener(_onVideoControllerUpdate);
      old.pause();
    }
    setState(() {});
    controller.initialize().then((_) {
      old?.dispose();
      _isPlayingIndex = index;
      controller.addListener(_onVideoControllerUpdate);
      controller.play();
      setState(() {});
    });
  }

  //
  var _onUpdateVideoControllerTime = 0;
  Duration? _duration;
  Duration? _position;
  var _progress = 0.0;
  //
  void _onVideoControllerUpdate() async {
    if (_disposed) {
      return;
    }
    _onUpdateVideoControllerTime = 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    if (_onUpdateVideoControllerTime > now) {
      return;
    }
    _onUpdateVideoControllerTime = now + 500;
    //end

    final controller = _videoPlayerController;
    if (controller == null) {
      debugPrint("Controller is null");
      return;
    }
    if (!controller.value.isInitialized) {
      debugPrint("Controller is not initialized");
      return;
    }

    _duration ??= _videoPlayerController?.value.duration;
    var duration = _duration;
    if (duration == null) return;

    var position = await controller.position;
    _position = position;

    final playing = controller.value.isPlaying;
    if (_playArea) {
      if (_disposed) return;
      setState(() {
        _progress = position!.inMilliseconds.ceilToDouble() /
            duration.inMilliseconds.ceilToDouble();
      });
    }
    _isPlaying = playing;
  }

  //
  Widget _playView(BuildContext context) {
    final controller = _videoPlayerController;
    if (controller != null && controller.value.isInitialized) {
      return Container(
        padding: const EdgeInsets.only(top: 7),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
        ),
        child: VideoPlayer(controller),
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          CircularProgressIndicator(
            color: Colors.white,
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            'Preparing...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
            ),
          ),
        ],
      );
    }
  }

  //
  String convertTwo(int value) {
    return value < 10 ? "0$value" : "$value";
  }

  //
  Widget _controlView() {
    final noMute = (_videoPlayerController?.value.volume ?? 0) > 0;
    final duration = _duration?.inSeconds ?? 0;
    final head = _position?.inSeconds ?? 0;
    final remained = max(0, duration - head);
    final minutes = convertTwo(remained ~/ 60.0);
    final seconds = convertTwo(remained % 60);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 20,
          padding: const EdgeInsets.only(top: 10),
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Colors.red[700],
              inactiveTrackColor: Colors.red[100],
              trackShape: const RoundedRectSliderTrackShape(),
              trackHeight: 2.0,
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 8.0,
              ),
              thumbColor: Colors.redAccent,
              overlayColor: Colors.red.withAlpha(32),
              overlayShape: const RoundSliderOverlayShape(
                overlayRadius: 28,
              ),
              tickMarkShape: const RoundSliderTickMarkShape(),
              activeTickMarkColor: Colors.red[700],
              inactiveTickMarkColor: Colors.red[100],
              valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
              valueIndicatorColor: Colors.redAccent,
              valueIndicatorTextStyle: const TextStyle(
                color: Colors.white,
              ),
            ),
            child: Slider(
              value: max(0, min(_progress * 100, 100)),
              min: 0,
              max: 100,
              divisions: 100,
              label: _position?.toString().split(".")[0],
              onChanged: (value) {
                setState(() {
                  _progress = value * 0.01;
                });
              },
              onChangeStart: (value) {
                _videoPlayerController?.pause();
              },
              onChangeEnd: (value) {
                final duration = _videoPlayerController?.value.duration;
                if (duration != null) {
                  var newValue = max(0, min(value, 99)) * 0.01;
                  var milliSeconds =
                      (duration.inMilliseconds * newValue).toInt();
                  _videoPlayerController
                      ?.seekTo(Duration(milliseconds: milliSeconds));
                  _videoPlayerController?.play();
                }
              },
            ),
          ),
        ),
        SizedBox(
          height: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {
                  if (noMute) {
                    _videoPlayerController?.setVolume(0);
                  } else {
                    _videoPlayerController?.setVolume(1);
                  }
                  setState(() {});
                },
                icon: Icon(
                  noMute ? Icons.volume_up : Icons.volume_off,
                  color: Colors.white,
                ),
              ),
              IconButton(
                onPressed: () async {
                  final index = _isPlayingIndex - 1;
                  if (index >= 0 && _videosData.isNotEmpty) {
                    _initializeVideo(index);
                  } else {
                    Fluttertoast.showToast(msg: 'No more videos to play');
                  }
                },
                icon: const Icon(
                  Icons.fast_rewind,
                  color: Colors.white,
                ),
              ),
              IconButton(
                onPressed: () async {
                  if (_isPlaying) {
                    setState(() {
                      _isPlaying = false;
                    });
                    _videoPlayerController?.pause();
                  } else {
                    setState(() {
                      _isPlaying = true;
                    });
                    _videoPlayerController?.play();
                  }
                },
                icon: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                ),
              ),
              IconButton(
                onPressed: () async {
                  final index = _isPlayingIndex + 1;
                  if (index <= _videosData.length - 1) {
                    _initializeVideo(index);
                  } else {
                    Fluttertoast.showToast(msg: 'No more videos in the list');
                  }
                },
                icon: const Icon(
                  Icons.fast_forward,
                  color: Colors.white,
                ),
              ),
              Text(
                "$minutes:$seconds",
                style: const TextStyle(color: Colors.white, shadows: <Shadow>[
                  Shadow(
                    offset: Offset(0, 1),
                    blurRadius: 4,
                    color: Color.fromARGB(150, 0, 0, 0),
                  ),
                ]),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

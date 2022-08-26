import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:photo_view/photo_view.dart';

import '../../../services/awareness_data_service.dart';
import '../../../widget/connectivity_banner.dart';
import '../awareness_material_page.dart';

const kColorBg = Colors.white;

class DietChartPage extends StatefulWidget {
  final String mobile;
  const DietChartPage({required this.mobile, Key? key}) : super(key: key);

  @override
  State<DietChartPage> createState() => _DietChartPageState();
}

class _DietChartPageState extends State<DietChartPage> {
  bool _isPageLoaded = false;
  bool _isGridview = true;
  List _imagesData = [];

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
        final dietChartImages =
            materialData.where((e) => e['HAM_Type'] == 1).toList();
        if (mounted) {
          setState(() {
            _isPageLoaded = true;
            _imagesData = dietChartImages;
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
    internetSubscription.cancel();
    // TODO: implement dispose
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
            builder: (_) => AwarenessMaterialPage(
              mobile: widget.mobile,
            ),
          ),
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
        body: SizedBox(
          width: size.width,
          height: size.height,
          child: _isPageLoaded
              ? Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(18, 20, 18, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
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
                            ),
                          ),
                          Container(
                            alignment: Alignment.center,
                            child: const Text(
                              'Diet Chart',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                _isGridview = !_isGridview;
                              });
                            },
                            child: Icon(
                              _isGridview ? Icons.grid_view : Icons.toc_outlined,
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    _imagesData.isNotEmpty
                        ? Container(
                            width: size.width,
                            padding: const EdgeInsets.only(left: 15, bottom: 10),
                            child: Text(
                              'All images',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.black.withOpacity(0.8),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        : Container(),
                    Expanded(
                      child: _imagesData.isNotEmpty
                          ? _isGridview
                              ? _buildGridView()
                              : _buildListView()
                          : const Center(
                              child: Text('No data was found to show!'),
                            ),
                    ),
                  ],
                )
              : const Center(
                  child: CircularProgressIndicator(),
                ),
        ),
      ),
    );
  }

  //
  Widget _buildGridView() {
    Size size = MediaQuery.of(context).size;
    return ListView.builder(
      itemCount: (_imagesData.length / 4).ceil(),
      itemBuilder: (BuildContext context, int idx) {
        var a = idx * 4;
        var b = (idx * 4) + 1;
        var c = (idx * 4) + 2;
        var d = (idx * 4) + 3;
        return Container(
          margin: const EdgeInsets.only(
            left: 10,
            right: 10,
            bottom: 10,
          ),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: size.height * 0.12,
                  child: _buildCachedImage(a),
                ),
              ),
              const SizedBox(
                width: 6,
              ),
              Expanded(
                child: SizedBox(
                  height: size.height * 0.12,
                  child: _buildCachedImage(b),
                ),
              ),
              const SizedBox(
                width: 6,
              ),
              Expanded(
                child: SizedBox(
                  height: size.height * 0.12,
                  child: _buildCachedImage(c),
                ),
              ),
              const SizedBox(
                width: 6,
              ),
              Expanded(
                child: SizedBox(
                  height: size.height * 0.12,
                  child: _buildCachedImage(d),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  //
  _buildCachedImage(int index) {
    return (index <= (_imagesData.length - 1))
        ? GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ViewImage(
                  url: _imagesData[index]['HAM_URL'],
                  label: _imagesData[index]['HAM_Desc'],
                ),
              ),
            ),
            child: CachedNetworkImage(
              imageUrl: _imagesData[index]['HAM_URL'],
              imageBuilder: (context, imageProvider) => Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(
                    color: Colors.black12,
                  ),
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              placeholder: (context, url) => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 30.0,
                    width: 30.0,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
                ],
              ),
              errorWidget: (context, url, error) => const Icon(
                Icons.error,
              ),
            ),
          )
        : Container();
  }

  //
  Widget _buildListView() {
    return ListView.builder(
      itemCount: _imagesData.length,
      itemBuilder: (BuildContext context, int idx) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8, left: 5, right: 5),
          child: Material(
            color: Colors.white,
            elevation: 2,
            borderRadius: BorderRadius.circular(5),
            child: InkWell(
              borderRadius: BorderRadius.circular(5),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ViewImage(
                    url: _imagesData[idx]['HAM_URL'],
                    label: _imagesData[idx]['HAM_Desc'],
                  ),
                ),
              ),
              child: SizedBox(
                height: 90,
                child: Card(
                  margin: EdgeInsets.zero,
                  elevation: 0,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(15),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 35,
                          backgroundColor: Colors.white,
                          child: CachedNetworkImage(
                            imageUrl: _imagesData[idx]['HAM_URL'],
                            imageBuilder: (context, imageProvider) => Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(
                                  color: Colors.black12,
                                ),
                                image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            placeholder: (context, url) => Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  height: 20.0,
                                  width: 20.0,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                  ),
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ],
                            ),
                            errorWidget: (context, url, error) => const Icon(
                              Icons.error,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Text(
                            _imagesData[idx]['HAM_Desc'],
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class ViewImage extends StatelessWidget {
  final String url;
  final String label;
  const ViewImage({required this.url, required this.label, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: PreferredSize(
        preferredSize: Size.zero,
        child: AppBar(
          elevation: 0,
          backgroundColor: Colors.black, //ios status bar colors
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.black, //android status bar color
            statusBarBrightness: Brightness.dark, // For iOS: (dark icons)
            statusBarIconBrightness:
                Brightness.light, // For Android: (dark icons)
          ),
        ),
      ),
      body: SizedBox(
        width: size.width,
        height: size.height,
        child: Stack(
          children: [
            Center(
              child: PhotoView(
                imageProvider: CachedNetworkImageProvider(url),
              ),
              // child: CachedNetworkImage(
              //   imageUrl: url,
              // ),
            ),
            Positioned(
              top: 20,
              left: 12,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: const Icon(
                  Icons.arrow_back_ios,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  backgroundColor: Colors.black,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class CityApiModel {
  List<CityModel>? data;
  CityApiModel({this.data});

  fromJson(Map<String, dynamic> json) {
    data = (json['_TOF_Cities_Result'] as List)
        .map((i) => CityModel.fromJson(i))
        .toList();
  }
}

class CityModel {
  final String cityCode;
  final String cityDesc;

  CityModel({
    required this.cityCode,
    required this.cityDesc,
  });

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      cityCode: json['City_Code'],
      cityDesc: json['City_Desc'],
    );
  }

  static Map<String, dynamic> toMap(CityModel cityModel) {
    var map = <String, dynamic>{};
    map['City_Code'] = cityModel.cityCode;
    map['City_Desc'] = cityModel.cityDesc;
    //
    return map;
  }
}
import 'dart:convert';

GetAllIndustriesModel getAllIndustriesModelFromJson(String str) => GetAllIndustriesModel.fromJson(json.decode(str));

String getAllIndustriesModelToJson(GetAllIndustriesModel data) => json.encode(data.toJson());

class GetAllIndustriesModel {
  bool success;
  String message;
  List<GetAllIndustriesData> data;

  GetAllIndustriesModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory GetAllIndustriesModel.fromJson(Map<String, dynamic> json) => GetAllIndustriesModel(
    success: json["success"],
    message: json["message"],
    data: List<GetAllIndustriesData>.from(json["data"].map((x) => GetAllIndustriesData.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class GetAllIndustriesData {
  String id;
  String title;
  String image;
  bool isActive;

  GetAllIndustriesData({
    required this.id,
    required this.title,
    required this.image,
    required this.isActive,
  });

  factory GetAllIndustriesData.fromJson(Map<String, dynamic> json) => GetAllIndustriesData(
    id: json["_id"],
    title: json["title"],
    image: json["image"],
    isActive: json["isActive"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "title": title,
    "image": image,
    "isActive": isActive,
  };
}

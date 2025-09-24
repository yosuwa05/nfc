class SelectIndustriesModel {
  bool? status;
  String? message;
  List<SelectIndustriesData>? data;

  SelectIndustriesModel({this.status, this.message, this.data});

  SelectIndustriesModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <SelectIndustriesData>[];
      json['data'].forEach((v) {
        data!.add(new SelectIndustriesData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class SelectIndustriesData {
  Industry? industry;
  List<String>? tags;
  String? sId;

  SelectIndustriesData({this.industry, this.tags, this.sId});

  SelectIndustriesData.fromJson(Map<String, dynamic> json) {
    industry = json['industry'] != null
        ? new Industry.fromJson(json['industry'])
        : null;
    tags = json['tags'].cast<String>();
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.industry != null) {
      data['industry'] = this.industry!.toJson();
    }
    data['tags'] = this.tags;
    data['_id'] = this.sId;
    return data;
  }
}

class Industry {
  String? sId;
  String? title;
  String? image;
  bool? isActive;
  String? updatedAt;

  Industry({this.sId, this.title, this.image, this.isActive, this.updatedAt});

  Industry.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    title = json['title'];
    image = json['image'];
    isActive = json['isActive'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['title'] = this.title;
    data['image'] = this.image;
    data['isActive'] = this.isActive;
    data['updatedAt'] = this.updatedAt;
    return data;
  }
}

class GetAttachLinksModel {
  bool? success;
  String? message;
  List<AttachLinksData>? data;

  GetAttachLinksModel({this.success, this.message, this.data});

  GetAttachLinksModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    if (json['data'] != null) {
      data = <AttachLinksData>[];
      json['data'].forEach((v) {
        data!.add(new AttachLinksData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class AttachLinksData {
  String? sId;
  String? name;
  List<SubCategories>? subCategories;
  bool? isActive;
  String? createdAt;
  String? updatedAt;
  int? iV;

  AttachLinksData(
      {this.sId,
        this.name,
        this.subCategories,
        this.isActive,
        this.createdAt,
        this.updatedAt,
        this.iV});

  AttachLinksData.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    if (json['subCategories'] != null) {
      subCategories = <SubCategories>[];
      json['subCategories'].forEach((v) {
        subCategories!.add(new SubCategories.fromJson(v));
      });
    }
    isActive = json['isActive'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    if (this.subCategories != null) {
      data['subCategories'] =
          this.subCategories!.map((v) => v.toJson()).toList();
    }
    data['isActive'] = this.isActive;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    return data;
  }
}

class SubCategories {
  String? name;
  String? icon;
  bool? isActive;
  String? sId;

  SubCategories({this.name, this.icon, this.isActive, this.sId});

  SubCategories.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    icon = json['icon'];
    isActive = json['isActive'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['icon'] = this.icon;
    data['isActive'] = this.isActive;
    data['_id'] = this.sId;
    return data;
  }
}

class UpdatedAttachLinksModel {
  bool? status;
  String? message;
  List<UpdateAttachLinksData>? data;

  UpdatedAttachLinksModel({this.status, this.message, this.data});

  UpdatedAttachLinksModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <UpdateAttachLinksData>[];
      json['data'].forEach((v) {
        data!.add(new UpdateAttachLinksData.fromJson(v));
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

class UpdateAttachLinksData {
  Category? category;
  List<UpdateSubCategories>? subCategories;
  String? sId;

  UpdateAttachLinksData({this.category, this.subCategories, this.sId});

  UpdateAttachLinksData.fromJson(Map<String, dynamic> json) {
    category = json['category'] != null
        ? new Category.fromJson(json['category'])
        : null;
    if (json['subCategories'] != null) {
      subCategories = <UpdateSubCategories>[];
      json['subCategories'].forEach((v) {
        subCategories!.add(new UpdateSubCategories.fromJson(v));
      });
    }
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.category != null) {
      data['category'] = this.category!.toJson();
    }
    if (this.subCategories != null) {
      data['subCategories'] =
          this.subCategories!.map((v) => v.toJson()).toList();
    }
    data['_id'] = this.sId;
    return data;
  }
}

class Category {
  String? sId;
  String? name;
  List<UpdateSubCategories>? subCategories;
  bool? isActive;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Category(
      {this.sId,
        this.name,
        this.subCategories,
        this.isActive,
        this.createdAt,
        this.updatedAt,
        this.iV});

  Category.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    if (json['subCategories'] != null) {
      subCategories = <UpdateSubCategories>[];
      json['subCategories'].forEach((v) {
        subCategories!.add(new UpdateSubCategories.fromJson(v));
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

class UpdateSubCategories {
  String? name;
  String? icon;
  bool? isActive;
  String? sId;

  UpdateSubCategories({this.name, this.icon, this.isActive, this.sId});

  UpdateSubCategories.fromJson(Map<String, dynamic> json) {
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

class SubCategoriesLink {
  String? subCategoryId;
  String? url;
  String? sId;

  SubCategoriesLink({this.subCategoryId, this.url, this.sId});

  SubCategoriesLink.fromJson(Map<String, dynamic> json) {
    subCategoryId = json['subCategoryId'];
    url = json['url'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['subCategoryId'] = this.subCategoryId;
    data['url'] = this.url;
    data['_id'] = this.sId;
    return data;
  }
}

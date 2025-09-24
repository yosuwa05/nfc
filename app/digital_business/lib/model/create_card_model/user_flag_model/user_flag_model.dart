class UserFlagModel {
  bool? status;
  String? message;
  Flags? flags;
  UserFlagData? data;

  UserFlagModel({this.status, this.message, this.flags, this.data});

  UserFlagModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    flags = json['flags'] != null ? new Flags.fromJson(json['flags']) : null;
    data = json['data'] != null ? new UserFlagData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.flags != null) {
      data['flags'] = this.flags!.toJson();
    }
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Flags {
  bool? businessDetails;
  bool? profilePicture;
  bool? selectedIndustries;
  bool? attachedLinks;
  bool? businessImages;

  Flags(
      {this.businessDetails,
        this.profilePicture,
        this.selectedIndustries,
        this.attachedLinks,
        this.businessImages});

  Flags.fromJson(Map<String, dynamic> json) {
    businessDetails = json['businessDetails'];
    profilePicture = json['profilePicture'];
    selectedIndustries = json['selectedIndustries'];
    attachedLinks = json['attachedLinks'];
    businessImages = json['businessImages'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['businessDetails'] = this.businessDetails;
    data['profilePicture'] = this.profilePicture;
    data['selectedIndustries'] = this.selectedIndustries;
    data['attachedLinks'] = this.attachedLinks;
    data['businessImages'] = this.businessImages;
    return data;
  }
}

class UserFlagData {
  BusinessDetails? businessDetails;
  String? profilePicture;
  List<SelectedIndustries>? selectedIndustries;
  List<AttachedLinks>? attachedLinks;
  List<String>? businessImages;

  UserFlagData(
      {this.businessDetails,
        this.profilePicture,
        this.selectedIndustries,
        this.attachedLinks,
        this.businessImages});

  UserFlagData.fromJson(Map<String, dynamic> json) {
    businessDetails = json['businessDetails'] != null
        ? new BusinessDetails.fromJson(json['businessDetails'])
        : null;
    profilePicture = json['profilePicture'];
    if (json['selectedIndustries'] != null) {
      selectedIndustries = <SelectedIndustries>[];
      json['selectedIndustries'].forEach((v) {
        selectedIndustries!.add(new SelectedIndustries.fromJson(v));
      });
    }
    if (json['attachedLinks'] != null) {
      attachedLinks = <AttachedLinks>[];
      json['attachedLinks'].forEach((v) {
        attachedLinks!.add(new AttachedLinks.fromJson(v));
      });
    }
    businessImages = json['businessImages'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.businessDetails != null) {
      data['businessDetails'] = this.businessDetails!.toJson();
    }
    data['profilePicture'] = this.profilePicture;
    if (this.selectedIndustries != null) {
      data['selectedIndustries'] =
          this.selectedIndustries!.map((v) => v.toJson()).toList();
    }
    if (this.attachedLinks != null) {
      data['attachedLinks'] =
          this.attachedLinks!.map((v) => v.toJson()).toList();
    }
    data['businessImages'] = this.businessImages;
    return data;
  }
}

class BusinessDetails {
  String? companyName;
  String? companyAddress;
  String? companyMobile;
  String? companyEmail;
  String? companyWebsite;
  String? companyLogo;
  String? sId;

  BusinessDetails(
      {this.companyName,
        this.companyAddress,
        this.companyMobile,
        this.companyEmail,
        this.companyWebsite,
        this.companyLogo,
        this.sId});

  BusinessDetails.fromJson(Map<String, dynamic> json) {
    companyName = json['companyName'];
    companyAddress = json['companyAddress'];
    companyMobile = json['companyMobile'];
    companyEmail = json['companyEmail'];
    companyWebsite = json['companyWebsite'];
    companyLogo = json['companyLogo'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['companyName'] = this.companyName;
    data['companyAddress'] = this.companyAddress;
    data['companyMobile'] = this.companyMobile;
    data['companyEmail'] = this.companyEmail;
    data['companyWebsite'] = this.companyWebsite;
    data['companyLogo'] = this.companyLogo;
    data['_id'] = this.sId;
    return data;
  }
}

class SelectedIndustries {
  String? industry;
  List<String>? tags;
  String? sId;

  SelectedIndustries({this.industry, this.tags, this.sId});

  SelectedIndustries.fromJson(Map<String, dynamic> json) {
    industry = json['industry'];
    tags = json['tags'].cast<String>();
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['industry'] = this.industry;
    data['tags'] = this.tags;
    data['_id'] = this.sId;
    return data;
  }
}

class AttachedLinks {
  String? category;
  List<SubCategories>? subCategories;
  String? sId;

  AttachedLinks({this.category, this.subCategories, this.sId});

  AttachedLinks.fromJson(Map<String, dynamic> json) {
    category = json['category'];
    if (json['subCategories'] != null) {
      subCategories = <SubCategories>[];
      json['subCategories'].forEach((v) {
        subCategories!.add(new SubCategories.fromJson(v));
      });
    }
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['category'] = this.category;
    if (this.subCategories != null) {
      data['subCategories'] =
          this.subCategories!.map((v) => v.toJson()).toList();
    }
    data['_id'] = this.sId;
    return data;
  }
}

class SubCategories {
  String? subCategoryId;
  String? url;
  String? sId;

  SubCategories({this.subCategoryId, this.url, this.sId});

  SubCategories.fromJson(Map<String, dynamic> json) {
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

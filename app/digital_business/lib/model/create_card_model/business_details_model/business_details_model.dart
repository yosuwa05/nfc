class BusinessDetailsModel {
  bool? status;
  String? message;
  BusinessDetailsData? data;

  BusinessDetailsModel({this.status, this.message, this.data});

  BusinessDetailsModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? new BusinessDetailsData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class BusinessDetailsData {
  String? companyName;
  String? companyAddress;
  String? companyMobile;
  String? companyEmail;
  String? companyWebsite;
  String? companyLogo;
  String? sId;

  BusinessDetailsData(
      {this.companyName,
        this.companyAddress,
        this.companyMobile,
        this.companyEmail,
        this.companyWebsite,
        this.companyLogo,
        this.sId});

  BusinessDetailsData.fromJson(Map<String, dynamic> json) {
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

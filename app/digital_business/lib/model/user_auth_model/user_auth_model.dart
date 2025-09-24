class UserAuthModel {
  String? message;
  bool? status;
  bool? isNewUser;
  UserData? data;

  UserAuthModel({this.message, this.status, this.isNewUser, this.data});

  UserAuthModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    status = json['status'];
    isNewUser = json['isNewUser'];
    data = json['data'] != null ? new UserData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    data['status'] = this.status;
    data['isNewUser'] = this.isNewUser;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class UserData {
  String? userId;
  String? username;
  String? mobile;
  String? subscriptionPlan;
  bool? isActive;
  String? lastLogin;
  String? token;

  UserData(
      {this.userId,
        this.username,
        this.mobile,
        this.subscriptionPlan,
        this.isActive,
        this.lastLogin,
        this.token});

  UserData.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    username = json['username'];
    mobile = json['mobile'];
    subscriptionPlan = json['subscriptionPlan'];
    isActive = json['isActive'];
    lastLogin = json['lastLogin'];
    token = json['token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userId'] = this.userId;
    data['username'] = this.username;
    data['mobile'] = this.mobile;
    data['subscriptionPlan'] = this.subscriptionPlan;
    data['isActive'] = this.isActive;
    data['lastLogin'] = this.lastLogin;
    data['token'] = this.token;
    return data;
  }
}

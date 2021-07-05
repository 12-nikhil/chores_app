class GroupMember {
  int groupId;
  String groupName;
  List<UserInfo> userInfo;
  GroupMember({this.groupId, this.groupName, this.userInfo});

  GroupMember.fromJson(Map<String, dynamic> json) {
    groupId = json['groupId'];
    groupName = json['groupName'];
    if (json['userInfo'] != null) {
      userInfo = new List<UserInfo>();
      json['userInfo'].forEach((v) {
        userInfo.add(new UserInfo.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['groupId'] = this.groupId;
    data['groupName'] = this.groupName;
    if (this.userInfo != null) {
      data['userInfo'] = this.userInfo.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class UserInfo {
  int userId;
  String role;
  String name;
  String mobile;
  String status;
  String createdDate;

  UserInfo(
      {this.userId,
        this.role,
        this.name,
        this.mobile,
        this.status,
        this.createdDate});

  UserInfo.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    role = json['role'];
    name = json['name'];
    mobile = json['mobile'];
    status = json['status'];
    createdDate = json['createdDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userId'] = this.userId;
    data['role'] = this.role;
    data['name'] = this.name;
    data['mobile'] = this.mobile;
    data['status'] = this.status;
    data['createdDate'] = this.createdDate;
    return data;
  }
}
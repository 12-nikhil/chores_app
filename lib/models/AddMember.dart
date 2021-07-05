class AddGroup {
  String groupId;
  String adminName;
  String adminMobileNo;
  int adminId;
  List<JoinUsersRequest> joinUsersRequest;

  AddGroup({this.groupId,this.adminId,this.adminName,this.adminMobileNo, this.joinUsersRequest});

  AddGroup.fromJson(Map<String, dynamic> json) {
    groupId = json['groupId'];
    adminId = json['adminId'];
    adminName = json['adminName'];
    adminMobileNo = json['adminMobileNo'];
    if (json['joinUsersRequest'] != null) {
      joinUsersRequest = new List<JoinUsersRequest>();
      json['joinUsersRequest'].forEach((v) {
        joinUsersRequest.add(new JoinUsersRequest.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['groupId'] = this.groupId;
    data['adminId'] = this.adminId;
    data['adminName'] = this.adminName;
    data['adminMobileNo'] = this.adminMobileNo;
    if (this.joinUsersRequest != null) {
      data['joinUsersRequest'] =
          this.joinUsersRequest.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class JoinUsersRequest {
  String mobile;
  String name;
  String role;

  JoinUsersRequest({this.mobile, this.name, this.role});

  JoinUsersRequest.fromJson(Map<String, dynamic> json) {
    mobile = json['mobile'];
    name = json['name'];
    role = json['role'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['mobile'] = this.mobile;
    data['name'] = this.name;
    data['role'] = this.role;
    return data;
  }
}
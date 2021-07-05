class AcceptedMember{
  int userId;
  Group group;
  String mobile;
  String name;
  String role;
  String status;
  String createdDate;

  AcceptedMember(
      {this.userId,
        this.group,
        this.mobile,
        this.name,
        this.role,
        this.status,
        this.createdDate});

  AcceptedMember.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    group = json['group'] != null ? new Group.fromJson(json['group']) : null;
    mobile = json['mobile'];
    name = json['name'];
    role = json['role'];
    status = json['status'];
    createdDate = json['createdDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userId'] = this.userId;
    if (this.group != null) {
      data['group'] = this.group.toJson();
    }
    data['mobile'] = this.mobile;
    data['name'] = this.name;
    data['role'] = this.role;
    data['status'] = this.status;
    data['createdDate'] = this.createdDate;
    return data;
  }
}

class Group {
  int groupId;
  String groupName;
  String createdDate;

  Group({this.groupId, this.groupName, this.createdDate});

  Group.fromJson(Map<String, dynamic> json) {
    groupId = json['groupId'];
    groupName = json['groupName'];
    createdDate = json['createdDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['groupId'] = this.groupId;
    data['groupName'] = this.groupName;
    data['createdDate'] = this.createdDate;
    return data;
  }
}
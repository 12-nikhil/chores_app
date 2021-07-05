class MyGroup {
  int groupId;
  String groupName;
  String createdDate;
  int userId;
  String role;
  String name;
  String mobile;
  String status;

  MyGroup(
      {this.groupId,
        this.groupName,
        this.createdDate,
        this.userId,
        this.role,
        this.name,
        this.mobile,
        this.status});

  MyGroup.fromJson(Map<String, dynamic> json) {
    groupId = json['groupId'];
    groupName = json['groupName'];
    createdDate = json['createdDate'];
    userId = json['userId'];
    role = json['role'];
    name = json['name'];
    mobile = json['mobile'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['groupId'] = this.groupId;
    data['groupName'] = this.groupName;
    data['createdDate'] = this.createdDate;
    data['userId'] = this.userId;
    data['role'] = this.role;
    data['name'] = this.name;
    data['mobile'] = this.mobile;
    data['status'] = this.status;
    return data;
  }
}

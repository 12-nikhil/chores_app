class NotificationGroupJoin{
  String role;
  String group_name;
  int userId;
  int adminId;
  int group_id;
  String adminName;
  String adminMobileNumber;

  NotificationGroupJoin({this.role, this.group_name, this.userId,this.adminId,this.adminName,this.adminMobileNumber,this.group_id});

  NotificationGroupJoin.fromJson(Map<String, dynamic> json) {
    role = json['role'];
    group_name = json['group_name'];
    userId = json['userId'];
    adminId = json['adminId'];
    group_id = json['group_id'];
    adminName = json['adminName'];
    adminMobileNumber = json['adminMobileNo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['role'] = this.role;
    data['group_name'] = this.group_name;
    data['userId'] = this.userId;
    data['adminId'] = this.adminId;
    data['group_id'] = this.group_id;
    data['adminName'] = this.adminName;
    data['adminMobileNo'] = this.adminMobileNumber;
    return data;
  }
}
class NotificationAcceptedMember {
  String role;
  String createdDate;
  int groupId;
  int userId;
  String name;
  String mobile;
  int adminId;
  String status;

  NotificationAcceptedMember(
      {this.role,
        this.createdDate,
        this.groupId,
        this.userId,
        this.name,
        this.mobile,
        this.adminId,
        this.status});

  NotificationAcceptedMember.fromJson(Map<String, dynamic> json) {
    role = json['role'];
    createdDate = json['createdDate'];
    groupId = json['group_id'];
    userId = json['user_id'];
    name = json['name'];
    mobile = json['mobile'];
    adminId = json['adminId'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['role'] = this.role;
    data['createdDate'] = this.createdDate;
    data['group_id'] = this.groupId;
    data['user_id'] = this.userId;
    data['name'] = this.name;
    data['mobile'] = this.mobile;
    data['adminId'] = this.adminId;
    data['status'] = this.status;
    return data;
  }
}
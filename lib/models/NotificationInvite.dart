class NotificationInvite{
  String role;
  String group_name;
  String userId;
  String adminName;

  NotificationInvite(
      {this.role,
        this.group_name,
        this.userId,});

  NotificationInvite.fromJson(Map<String, dynamic> json) {
    role = json['role'];
    group_name = json['group_name'];
    userId = json['userId'];
    adminName = json['adminName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['role'] = this.role;
    data['group_name'] = this.group_name;
    data['userId'] = this.userId;
    data['adminName'] = this.adminName;
    return data;
  }
}
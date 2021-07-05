class TaskNotificationBody {
  int memberId;
  String memberName;
  int adminId;
  String adminMobileNo;
  int taskId;
  int taskPoint;
  String taskName;
  String status;

  TaskNotificationBody(
      {this.adminMobileNo,
        this.adminId,
        this.memberId,
        this.memberName,
        this.taskPoint,
        this.status,
        this.taskId,
        this.taskName});

  TaskNotificationBody.fromJson(Map<String, dynamic> json) {
    adminMobileNo = json['adminMobileNo'];
    adminId = json['adminId'];
    memberId = json['memberId'];
    memberName = json['memberName'];
    taskPoint = json['taskPoint'];
    status = json['status'];
    taskId = json['taskId'];
    taskName = json['taskName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['adminMobileNo'] = this.adminMobileNo;
    data['adminId'] = this.adminId;
    data['memberId'] = this.memberId;
    data['memberName'] = this.memberName;
    data['taskPoint'] = this.taskPoint;
    data['status'] = this.status;
    data['taskId'] = this.taskId;
    data['taskName'] = this.taskName;
    return data;
  }
}

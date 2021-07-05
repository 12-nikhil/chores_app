class NotificationTaskComplete{
  int memberId;
  String memberName;
  String memberMobile;
  int adminId;
  String assigneeName;
  String adminMobileNo;
  int taskId;
  int taskPoint;
  int groupId;
  String taskName;
  String taskType;
  String custom;
  String taskDescription;
  String dueDate;
  String dueTime;
  int scored;
  String status;

  NotificationTaskComplete(
      {this.memberId,
        this.memberName,
        this.memberMobile,
        this.adminId,
        this.assigneeName,
        this.adminMobileNo,
        this.taskId,
        this.taskPoint,
        this.groupId,
        this.taskName,
        this.taskType,
        this.custom,
        this.taskDescription,
        this.dueTime,
        this.dueDate,
        this.scored,
        this.status});

  NotificationTaskComplete.fromJson(Map<String, dynamic> json) {
    memberId = json['memberId'];
    memberName = json['memberName'];
    memberMobile = json['memberMobile'];
    adminId = json['adminId'];
    assigneeName = json['assigneeName'];
    adminMobileNo = json['adminMobileNo'];
    taskId = json['taskId'];
    taskPoint = json['taskPoint'];
    taskName = json['taskName'];
    taskType = json['taskType'];
    custom = json['custom'];
    taskDescription = json['taskDescription'];
    dueDate = json['dueDate'];
    dueTime = json['dueTime'];
    scored = json['scored'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['memberId'] = memberId;
    data['memberName'] = memberName;
    data['memberMobile'] = memberMobile;
    data['adminId'] = adminId;
    data['assigneeName'] = assigneeName;
    data['adminMobileNo'] = adminMobileNo;
    data['taskId'] = taskId;
    data['taskPoint'] = taskPoint;
    data['taskName'] = taskName;
    data['taskType'] = taskType;
    data['custom'] = custom;
    data['taskDescription'] = taskDescription;
    data['dueDate'] = dueDate;
    data['dueTime'] = dueTime;
    data['scored'] = scored;
    data['status'] = status;
    return data;
  }
}
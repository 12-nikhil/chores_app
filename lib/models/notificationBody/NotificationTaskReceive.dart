class NotificationTaskReceived {
  String taskName;
  String taskDescription;
  String dueTime;
  int adminUserId;
  int taskPoint;
  int memberUserId;
  String dueDate;
  String mobileNo;
  int taskId;
  String createdDate;
  String taskType;
  String custom;

  int group_id;
  String status;
  int score;
  int recurringTaskId;
  String fromDate;
  String toDate;

  NotificationTaskReceived(
      {this.taskName,
      this.taskDescription,
      this.dueTime,
      this.adminUserId,
      this.taskPoint,
      this.memberUserId,
      this.dueDate,
      this.mobileNo,
      this.taskId,
      this.createdDate,
      this.taskType,
      this.custom,
      this.group_id,
      this.status,
      this.score,
      this.recurringTaskId,
      this.fromDate,
      this.toDate});

  NotificationTaskReceived.fromJson(Map<String, dynamic> json) {
    taskName = json['task_name'];
    taskDescription = json['task_description'];
    dueTime = json['due_time'];
    adminUserId = json['admin_user_id'];
    taskPoint = json['task_point'];
    memberUserId = json['member_user_id'];
    dueDate = json['due_date'];
    mobileNo = json['mobile_no'];
    taskId = json['task_id'];
    createdDate = json['created_date'];
    taskType = json['task_type'];
    custom = json['custom'];
    group_id = json['group_id'];
    status = json['status'];
    recurringTaskId = json['recurringTaskId'];
    fromDate = json['fromDate'];
    toDate = json['toDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['task_name'] = this.taskName;
    data['task_description'] = this.taskDescription;
    data['due_time'] = this.dueTime;
    data['admin_user_id'] = this.adminUserId;
    data['task_point'] = this.taskPoint;
    data['member_user_id'] = this.memberUserId;
    data['due_date'] = this.dueDate;
    data['mobile_no'] = this.mobileNo;
    data['task_id'] = this.taskId;
    data['created_date'] = this.createdDate;
    data['task_type'] = this.taskType;
    data['custom'] = this.custom;
    data['group_id'] = this.group_id;
    data['status'] = this.status;
    data['score'] = this.score;
    data['recurringTaskId'] = this.recurringTaskId;
    data['fromDate'] = this.fromDate;
    data['toDate'] = this.toDate;
    return data;
  }
}

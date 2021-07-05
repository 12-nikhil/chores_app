class Task {
  int taskId;
  int adminUserId;
  List<dynamic> memberUserId;
  int taskPoint;
  int groupId;
  String taskName;
  String taskType;
  String custom;
  String taskDescription;
  String dueDate;
  String dueTime;
  String status;
  List<String> selectedDate = List();
  String fromDate;
  String toDate;

  Task(
      {this.taskId,
        this.taskName,
        this.taskPoint,
        this.taskType,
        this.custom,
        this.taskDescription,
        this.adminUserId,
        this.memberUserId,
        this.dueDate,
        this.dueTime,
        this.groupId,this.status,
      this.selectedDate,this.fromDate,this.toDate});

  Task.fromJson(Map<String, dynamic> json) {
    taskId = json['taskId'];
    groupId = json['groupId'];
    taskName = json['taskName'];
    taskPoint = json['taskPoint'];
    taskType = json['taskType'];
    custom = json['custom'];
    taskDescription = json['taskDescription'];
    adminUserId = json['adminUserId'];
    memberUserId = json['memberUserId'];
    dueDate = json['dueDate'];
    dueTime = json['dueTime'];
    status = json['status'];
    selectedDate = json['selectedDate'];
    fromDate = json['fromDate'];
    toDate = json['toDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['taskId'] = this.taskId;
    data['groupId'] = this.groupId;
    data['taskName'] = this.taskName;
    data['taskPoint'] = this.taskPoint;
    data['taskType'] = this.taskType;
    data['custom'] = this.custom;
    data['taskDescription'] = this.taskDescription;
    data['adminUserId'] = this.adminUserId;
    data['memberUserId'] = this.memberUserId;
    data['dueDate'] = this.dueDate;
    data['dueTime'] = this.dueTime;
    data['status'] = this.status;
    data['selectedDate'] = this.selectedDate;
    data['fromDate'] = this.fromDate;
    data['toDate'] = this.toDate;
    return data;
  }
}
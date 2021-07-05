class NotificationId{
  int memberUserId;
  int taskId;
  int group_id;

  NotificationId(
      {
        this.memberUserId,
        this.taskId,
       this.group_id});

  NotificationId.fromJson(Map<String, dynamic> json) {
    memberUserId = json['user_id'];
    taskId = json['task_id'];
    group_id = json['group_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_id'] = this.memberUserId;
    data['task_id'] = this.taskId;
    data['group_id'] = this.group_id;
    return data;
  }
}
class TaskAcceptReject {
  String taskStatus;
  int userId;
  int taskId;
  int taskScore;
  String taskType;

  TaskAcceptReject({this.taskStatus, this.userId, this.taskId, this.taskScore});

  TaskAcceptReject.fromJson(Map<String, dynamic> json) {
    taskStatus = json['task_status'];
    userId = json['user_id'];
    taskId = json['task_id'];
    taskScore = json['task_score'];
    taskType = json['task_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['task_status'] = this.taskStatus;
    data['user_id'] = this.userId;
    data['task_id'] = this.taskId;
    data['task_score'] = this.taskScore;
    data['task_type'] = this.taskType;
    return data;
  }
}
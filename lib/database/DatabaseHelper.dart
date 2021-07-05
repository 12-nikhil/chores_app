import 'package:chores_app/database/entity/DBTask.dart';
import 'package:chores_app/database/entity/DbInvitation.dart';
import 'package:chores_app/database/entity/DbLogin.dart';
import 'package:chores_app/helper/method_helper.dart';
import 'package:chores_app/models/GroupMember.dart';
import 'package:chores_app/models/notificationBody/NotificationGroupJoin.dart';
import 'package:chores_app/ui/member_dashboard_screen.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io' as io;

import 'package:sqflite/sqflite.dart';
import 'package:chores_app/utils/Utils.dart';
import 'package:chores_app/database/entity/DbGroup.dart';
import 'package:chores_app/database/entity/DbMember.dart';
import 'package:chores_app/database/entity/DbRecurringTask.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = new DatabaseHelper.internal();

  factory DatabaseHelper() => _instance;

  static Database _db;

  Future<Database> get db async {
    if (_db != null) return _db;
    _db = await initDb();
    return _db;
  }

  /*onUpgrade: (db, oldVersion, newVersion) {
  _onUpgrade(db, 1,2);
  },*/

  initDb() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "chores_new.db");
    var theDb = await openDatabase(path, version: 2,
        onCreate: (Database db, int version) async {
      await db.execute('''create table $tableLogin(
      $columnId integer primary key autoincrement,
        $uId integer , 
          $uName text not null,
          $uMobile text not null,
          $uRole text not null)''');
      await db.execute("create table $tableGroup($columnId INTEGER PRIMARY KEY,"
          "$gpId integer,"
          "$groupName TEXT,"
          "$groupMobile TEXT)");
      await db.execute('''create table $tableMember(
      $columnId integer primary key autoincrement,
        $userId integer , 
         $gId integer , 
          $name text not null,
          $mobile text not null,
          $role text not null,
           $status text not null,
          $createdDate text not null)''');
      await db.execute('''create table $tableTask(
      $columnId integer primary key autoincrement,
        $taskId INTEGER , 
         $tRecurringTaskId INTEGER , 
        $tAssigneeId INTEGER, 
        $tMemberId INTEGER, 
        $tPoint INTEGER,
         $tGroupId INTEGER,
        $tScore INTEGER, 
          $tType TEXT NOT NULL,
           $tCustom TEXT,
          $tName TEXT NOT NULL,
          $tDescription TEXT NOT NULL,
          $tLastUpdatedDate TEXT NOT NULL,
          $tStatus TEXT,
           $tDueDate TEXT,
          $tDueTime TEXT)''');
      await db.execute('''create table $tableInvitation(
      $columnId integer primary key autoincrement,
        $iUId integer , 
         $iGId integer , 
          $iGroupName text not null,
          $iAdminName text not null,
          $iAdminMobile text not null,
           $iRole text not null)''');
      /* await db.execute('''create table $tableRecurringTask(
      $columnId integer primary key autoincrement,
        $rTaskId integer ,
          $rTaskType text not null,
          $rCustomDay text not null,
           $rLastUpdatedDate text not null,
           $rStatus text not null)''');*/
    });
    return theDb;
  }

  /* // UPGRADE DATABASE TABLES
  void _onUpgrade(Database db, int oldVersion, int newVersion) async{
    if (oldVersion < newVersion) {
      print("Alter call ${oldVersion} ${newVersion}");
      db.execute("ALTER TABLE ${tableTask} ADD COLUMN ${tStatus} TEXT;");
    }
  }*/

  DatabaseHelper.internal();

  // **************** Login table ******************
  Future<DbLogin> insertLogin(DbLogin dbLogin) async {
    var dbClient = await db;
    dbLogin.id = (await dbClient.insert(tableLogin, dbLogin.toMap()));
    return dbLogin;
  }

  Future<DbLogin> getLoginDetails(int id) async {
    var dbClient = await db;
    List<Map> maps = await dbClient.query(tableLogin,
        columns: [uId, uName, uMobile, uRole],
        where: '$uId = ?',
        whereArgs: [id]);
    if (maps.length > 0) {
      return DbLogin.fromMap(maps.first);
    }
    return null;
  }

  Future<DbLogin> getAllLoginDetails() async {
    var dbClient = await db;
    List<Map> maps = await dbClient.query(
      tableLogin,
      columns: [uId, uName, uMobile, uRole],
    );
    if (maps.length > 0) {
      return DbLogin.fromMap(maps.first);
    }
    return null;
  }

  // *****************  Group  ****************************
  Future<DBGroup> insert(DBGroup dbGroup) async {
    var dbClient = await db;
    dbGroup.id = (await dbClient.insert(tableGroup, dbGroup.toMap()));
    return dbGroup;
  }

  Future<DBGroup> getGroup(int id) async {
    var dbClient = await db;
    List<Map> maps = await dbClient.query(tableGroup,
        columns: [gpId, groupName, groupMobile],
        where: '$gpId = ?',
        whereArgs: [id]);
    if (maps.length > 0) {
      return DBGroup.fromMap(maps.first);
    }
    return null;
  }

  Future<int> deleteGroup(int id) async {
    var dbClient = await db;
    return await dbClient
        .delete(tableGroup, where: '$gpId = ?', whereArgs: [id]);
  }

  Future<int> update(DBGroup dbGroup) async {
    var dbClient = await db;
    return await dbClient.update(tableGroup, dbGroup.toMap(),
        where: '$gpId = ?', whereArgs: [dbGroup.id]);
  }

  Future<int> updateMemberStatus(int usId, String status) async {
    var dbClient = await db;
    Map<String, dynamic> map = {
      tStatus: status,
    };
    return await dbClient
        .update(tableMember, map, where: '$userId = ?', whereArgs: [usId]);
  }

  Future<List> getAllGroup() async {
    List<DBGroup> user = List();
    var dbClient = await db;
    List<Map> maps = await dbClient
        .query(tableGroup, columns: [gpId, groupName, groupMobile]);
    if (maps.length > 0) {
      maps.forEach((f) {
        user.add(DBGroup.fromMap(f));
//          print("getAllUsers"+ User.fromMap(f).toString());
      });
    }
    return user;
  }

  Future<DBGroup> getSingleGroupById(int groupId) async {
    var dbClient = await db;
    List<Map> maps = await dbClient.query(tableGroup,
        columns: [gpId, groupName, groupMobile],
        where: '$gpId = ?',
        whereArgs: [groupId]);
    if (maps.length > 0) {
      return DBGroup.fromMap(maps.first);
    }
    return null;
  }
  Future<DBGroup> getSingleGroup() async {
    var dbClient = await db;
    List<Map> maps = await dbClient.query(tableGroup,
        columns: [gpId, groupName, groupMobile]);
    if (maps.length > 0) {
      return DBGroup.fromMap(maps.first);
    }
    return null;
  }

  Future<int> getAllGroupCount() async {
    int count = 0;
    var dbClient = await db;
    List<Map> maps = await dbClient
        .query(tableGroup, columns: [gpId, groupName, groupMobile]);
    if (maps.length > 0) {
      count = maps.length;
    }
    return count;
  }

  Future<List> getAllGroupByUserId(int userId) async {
    List<DBGroup> user = List();
    var dbClient = await db;
    List<Map> maps = await dbClient
        .query(tableGroup, columns: [gpId, groupName, groupMobile]);
    if (maps.length > 0) {
      maps.forEach((f) {
        user.add(DBGroup.fromMap(f));
//          print("getAllUsers"+ User.fromMap(f).toString());
      });
    }
    return user;
  }

  // *****************  member  ****************************
  Future<DBMember> insertMember(DBMember dbMember) async {
    var dbClient = await db;
    dbMember.uId = (await dbClient.insert(tableMember, dbMember.toMap()));
    return dbMember;
  }

  Future<List<DBMember>> insertMemberList(
      List<UserInfo> userInfoList,int userId,int groupId) async {
    var dbClient = await db;
    Batch batch = dbClient.batch();
    DBMember dbMember = DBMember();
    List<DBMember> dbMemberList = List();
    for (UserInfo userInfo in userInfoList) {
      if (userInfo.userId == userId) {
        // save data in shared Preference for future use
        saveDataInSharedPreference(
            userInfo.userId, userInfo.role, userInfo.mobile, userInfo.name);
        // save LoginData in shared Preference for future use,cause in background sp not fetch data(only in my project)
        // cause i am using old plugin version
        saveLoginDetailsInLocalDB(userInfo);
        dbMember.memberStatus = status;
      } else {
        dbMember.memberStatus = userInfo.status;
      }
      dbMember.uId = userInfo.userId;
      dbMember.groupId = groupId;
      dbMember.memberName = userInfo.name;
      dbMember.memberMobile = userInfo.mobile;
      dbMember.memberRole = userInfo.role;
      dbMember.memberCreationDate = userInfo.createdDate;
      dbMemberList.add(dbMember);
      batch.insert(tableMember, dbMember.toMap());
    }
    batch.commit();
    return dbMemberList;
  }

  Future<DBMember> getDbMember(int id) async {
    var dbClient = await db;

    List<Map> maps = await dbClient.query(tableMember,
        columns: [userId, name, mobile, role, status, createdDate],
        where: '$userId = ?',
        whereArgs: [id]);
    if (maps.length > 0) {
      return DBMember.fromMap(maps.first);
    }
    return null;
  }

  Future<DBMember> getDbMemberByMobile(String mobileNo) async {
    var dbClient = await db;
    List<Map> maps = await dbClient.query(tableMember,
        columns: [columnId, userId, name, mobile, role, status, createdDate],
        where: '$mobile = ?',
        whereArgs: [mobileNo]);
    if (maps.length > 0) {
      return DBMember.fromMap(maps.first);
    }
    return null;
  }

  Future<DBMember> getDbMemberByUserId(int memberId) async {
    var dbClient = await db;
    List<Map> maps = await dbClient.query(tableMember,
        columns: [
          columnId,
          userId,
          name,
          mobile,
          role,
          status,
          createdDate,
          gId
        ],
        where: '$userId = ?',
        whereArgs: [memberId]);
    if (maps.length > 0) {
      return DBMember.fromMap(maps.first);
    }
    return null;
  }

  Future<int> getDbMemberCountByGroupId(int group_id) async {
    var dbClient = await db;
    List<Map> maps = await dbClient.query(tableMember,
        columns: [columnId, userId, name, mobile, role, status, createdDate],
        where: '$gId = ?',
        whereArgs: [group_id]);
    if (maps.length > 0) {
      return maps.length;
    }
    return null;
  }

  Future<int> deleteMember(int uId) async {
    print("delete user id ${userId}");
    var dbClient = await db;
    return await dbClient
        .delete(tableMember, where: 'user_id = ?', whereArgs: [uId]);
  }

  Future<int> updateMember(DBMember dbMember) async {
    var dbClient = await db;
    return await dbClient.update(tableMember, dbMember.toMap(),
        where: '$userId = ?', whereArgs: [dbMember.id]);
  }

  Future<List> getAllMember() async {
    List<DBMember> user = List();
    var dbClient = await db;
    List<Map> maps = await dbClient.query(tableMember,
        columns: [userId, name, mobile, role, status, createdDate]);
    if (maps.length > 0) {
      maps.forEach((f) {
        user.add(DBMember.fromMap(f));
//          print("getAllUsers"+ User.fromMap(f).toString());
      });
    }
    return user;
  }

  Future<List> getAllMemberFilterByMobile(String loginMobile) async {
    List<DBMember> user = List();
    var dbClient = await db;
    List<Map> maps = await dbClient.query(tableMember,
        columns: [userId, name, mobile, role, status, createdDate],
        where: '$mobile != ?',
        whereArgs: [loginMobile]);
    if (maps.length > 0) {
      maps.forEach((f) {
        user.add(DBMember.fromMap(f));
      });
    }
    return user;
  }
  Future<List> getAllMemberByGroupId(int groupId) async {
    List<DBMember> user = List();
    var dbClient = await db;
    List<Map> maps = await dbClient.query(tableMember,
        columns: [userId, name, mobile, role, status, createdDate,gId],
        where: '$gId != ?',
        whereArgs: [groupId]);
    if (maps.length > 0) {
      maps.forEach((f) {
        user.add(DBMember.fromMap(f));
      });
    }
    return user;
  }

  // ========================== TASK =========================

  Future<DBTask> insertTask(DBTask dbTask) async {
    var dbClient = await db;
    dbTask.tId = await dbClient.insert(tableTask, dbTask.toMap());
    return dbTask;
  }

  Future<List<DBTask>> insertTaskList(List<DBTask> taskList) async {
    var dbClient = await db;
    Batch batch = dbClient.batch();
    for (DBTask task in taskList) {
      batch.insert(tableTask, task.toMap());
    }
    batch.commit();
    return taskList;
  }

  Future<List> getDbTaskByAssigneeId(int assigneeId, int groupId) async {
    List<DBTask> taskList = List();
    var dbClient = await db;
    List<Map> maps = await dbClient.query(tableTask,
        columns: [
          taskId,
          tAssigneeId,
          tMemberId,
          tGroupId,
          tName,
          tDescription,
          tPoint,
          tScore,
          tType,
          tCustom,
          tDueDate,
          tDueTime,
          tStatus,
          tLastUpdatedDate
        ],
        where: '$assigneeId = ? and $groupId = ?',
        whereArgs: [tAssigneeId, tGroupId]);
    if (maps.length > 0) {
      maps.forEach((f) {
        taskList.add(DBTask.fromMap(f));
      });
      return taskList;
    }
  }

  Future<List> getDbTaskByMemberId(int memberId) async {
    List<DBTask> taskList = List();
    var dbClient = await db;
    List<Map> maps = await dbClient.query(tableTask,
        columns: [
          taskId,
          tGroupId,
          tAssigneeId,
          tMemberId,
          tName,
          tDescription,
          tPoint,
          tScore,
          tType,
          tCustom,
          tDueDate,
          tDueTime,
          tStatus,
          tLastUpdatedDate
        ],
        where: '$tMemberId = ?',
        whereArgs: [memberId]);
    if (maps.length > 0) {
      maps.forEach((f) {
        taskList.add(DBTask.fromMap(f));
      });
      return taskList;
    }
  }

  Future<List> getCustomTaskByMemberId(int memberId) async {
    List<DBTask> taskList = List();
    var dbClient = await db;
    List<Map> maps = await dbClient.query(tableTask,
        columns: [
          taskId,
          tGroupId,
          tAssigneeId,
          tMemberId,
          tName,
          tDescription,
          tPoint,
          tScore,
          tType,
          tCustom,
          tDueDate,
          tDueTime,
          tStatus,
          tLastUpdatedDate
        ],
        where: '$tMemberId = ? and $tCustom = ?',
        whereArgs: [memberId]);
    if (maps.length > 0) {
      maps.forEach((f) {
        taskList.add(DBTask.fromMap(f));
      });
      return taskList;
    }
  }

  Future<List> getDbTaskByGroupId(int groupId) async {
    List<DBTask> taskList = List();
    var dbClient = await db;
    List<Map> maps = await dbClient.query(tableTask,
        columns: [
          taskId,
          tGroupId,
          tAssigneeId,
          tMemberId,
          tName,
          tDescription,
          tPoint,
          tScore,
          tType,
          tCustom,
          tDueDate,
          tDueTime,
          tStatus,
          tLastUpdatedDate
        ],
        where: '$tGroupId = ?',
        whereArgs: [groupId]);
    print('Map ${maps}');
    if (maps.length > 0) {
      maps.forEach((f) {
        taskList.add(DBTask.fromMap(f));
      });
      return taskList;
    }
  }

  Future<DBTask> getDbTaskByTaskId(int tId) async {
    List<DBTask> taskList = List();
    var dbClient = await db;
    List<Map> maps = await dbClient.query(tableTask,
        columns: [
          taskId,
          tGroupId,
          tAssigneeId,
          tMemberId,
          tName,
          tDescription,
          tPoint,
          tScore,
          tType,
          tCustom,
          tDueDate,
          tDueTime,
          tStatus,
          tLastUpdatedDate
        ],
        where: '$taskId = ?',
        whereArgs: [tId]);
    print('Map ${maps}');
    if (maps.length > 0) {
      return DBTask.fromMap(maps.first);
    }
    return null;
  }

  Future<List<DBTask>> getDbTaskByRecurringTaskId(int tId) async {
    List<DBTask> taskList = List();
    var dbClient = await db;
    List<Map> maps = await dbClient.query(tableTask,
        columns: [
          taskId,
          tGroupId,
          tAssigneeId,
          tMemberId,
          tName,
          tDescription,
          tPoint,
          tScore,
          tType,
          tCustom,
          tDueDate,
          tDueTime,
          tStatus,
          tLastUpdatedDate,
          tRecurringTaskId,
        ],
        where: '$tRecurringTaskId = ?',
        whereArgs: [tId]);
    print('Map ${maps}');
    if (maps.length > 0) {
      maps.forEach((f) {
        taskList.add(DBTask.fromMap(f));
      });
    }
    return taskList;
  }

  Future<List> getDBAllTask() async {
    List<DBTask> taskList = List();
    var dbClient = await db;
    List<Map> maps = await dbClient.query(tableTask, columns: [
      taskId,
      tGroupId,
      tAssigneeId,
      tMemberId,
      tName,
      tDescription,
      tPoint,
      tScore,
      tType,
      tCustom,
      tDueDate,
      tDueTime,
      tStatus,
      tLastUpdatedDate
    ]);
    if (maps.length > 0) {
      maps.forEach((f) {
        taskList.add(DBTask.fromMap(f));
      });
      return taskList;
    }
  }

  /* Future<int> updateTaskStatus(int tId, String status, int score) async {
    var dbClient = await db;
    Map<String, dynamic> map = {
      tStatus: status,
      tScore: score,
    };
    return await dbClient
        .update(tableTask, map, where: '$taskId = ?', whereArgs: [tId]);
  }*/
  Future<int> updateTaskStatus(int tId, String status, int score) async {
    var dbClient = await db;
    Map<String, dynamic> map = {
      tStatus: status,
      tScore: score,
      tLastUpdatedDate: getCurrentDateTime(),
    };
    return await dbClient
        .update(tableTask, map, where: '$taskId = ?', whereArgs: [tId]);
  }

  Future<int> getDbTaskCountByMemberId(int memberId) async {
    var dbClient = await db;
    List<Map> maps = await dbClient.query(tableTask,
        columns: [
          taskId,
          tGroupId,
          tAssigneeId,
          tMemberId,
          tName,
          tDescription,
          tPoint,
          tScore,
          tType,
          tCustom,
          tDueDate,
          tDueTime,
          tStatus,
          tLastUpdatedDate
        ],
        where: '$tMemberId = ?',
        whereArgs: [memberId]);
    if (maps.length > 0) {
      return maps.length;
    }
    return null;
  }

  Future<int> getDbTaskCount() async {
    var dbClient = await db;
    List<Map> maps = await dbClient.query(
      tableTask,
      columns: [
        taskId,
        tGroupId,
        tAssigneeId,
        tMemberId,
        tName,
        tDescription,
        tPoint,
        tScore,
        tType,
        tCustom,
        tDueDate,
        tDueTime,
        tStatus,
        tLastUpdatedDate
      ],
    );
    if (maps.length > 0) {
      return maps.length;
    }
    return null;
  }

  Future<List<DBTask>> getDbTaskListByMemberId(int memberId) async {
    List<DBTask> taskList = List();
    var dbClient = await db;
    List<Map> maps = await dbClient.query(tableTask,
        columns: [
          taskId,
          tGroupId,
          tAssigneeId,
          tMemberId,
          tName,
          tDescription,
          tPoint,
          tScore,
          tType,
          tCustom,
          tDueDate,
          tDueTime,
          tStatus,
          tLastUpdatedDate
        ],
        where: '$tMemberId = ?',
        whereArgs: [memberId]);
    if (maps.length > 0) {
      maps.forEach((f) {
        taskList.add(DBTask.fromMap(f));
      });
    }
    return taskList;
  }

  Future<List<int>> deleteTaskList(List<DBTask> taskList) async {
    var dbClient = await db;
    List<int> taskId = List();
    Batch batch = dbClient.batch();
    for (DBTask task in taskList) {
      taskId.add(task.tId);
      batch.delete(tableTask, where: '$taskId = ?', whereArgs: [task.tId]);
    }
    batch.commit();
    return taskId;
  }

  Future<int> deleteTask(int id) async {
    var dbClient = await db;
    return await dbClient
        .delete(tableTask, where: '$taskId = ?', whereArgs: [id]);
  }

  Future deleteGroupTable() async {
    var dbClient = await db;
    await dbClient.execute("DROP TABLE IF EXISTS $tableGroup");
  }

  Future deleteMemberTable() async {
    var dbClient = await db;
    await dbClient.execute("DROP TABLE IF EXISTS $tableMember");
  }

  Future deleteTaskTable() async {
    var dbClient = await db;
    await dbClient.execute("DROP TABLE IF EXISTS $tableTask");
  }

  Future deleteLoginTable() async {
    var dbClient = await db;
    await dbClient.execute("DROP TABLE IF EXISTS $tableLogin");
  }

  Future deleteInvitation() async {
    var dbClient = await db;
    await dbClient.execute("DROP TABLE IF EXISTS $tableInvitation");
  }

  Future<void> cleanDatabase() async {
    try {
      var dbClient = await db;
      await dbClient.transaction((txn) async {
        var batch = txn.batch();
        batch.delete(tableTask);
        batch.delete(tableMember);
        batch.delete(tableGroup);
        // batch.delete(tableInvitation);
        await batch.commit();
      });
    } catch (error) {
      throw Exception('DbBase.cleanDatabase: ' + error.toString());
    }
  }

  // ********************** Recurring task *******************

  /*Future<DbRecurringTask> insertRecurringTask(DbRecurringTask dbRecurringTask) async {
    var dbClient = await db;
    dbRecurringTask.id = (await dbClient.insert(tableRecurringTask, dbRecurringTask.toMap()));
    return dbRecurringTask;
  }
  Future<DbRecurringTask> getSingleRecurringTaskDetails() async {
    var dbClient = await db;
    List<Map> maps = await dbClient.query(
      tableRecurringTask,
      columns: [columnId,rTaskId,rTaskType,rCustomDay,rLastUpdatedDate,rStatus],
    );
    if (maps.length > 0) {
      return DbRecurringTask.fromMap(maps.last);
    }
    return null;
  }
  Future<List<DbRecurringTask>> getListRecurringTaskDetails(int taskId) async {
    List<DbRecurringTask> taskList = List();
    var dbClient = await db;
    List<Map> maps = await dbClient.query(
      tableRecurringTask,
      columns: [columnId,rTaskId,rTaskType,rCustomDay,rLastUpdatedDate,rStatus],
        where: '$rTaskId = ?',
        whereArgs: [taskId]);
    if (maps.length > 0) {
      maps.forEach((f) {
        taskList.add(DbRecurringTask.fromMap(f));
      });
      return taskList;
    }
    return null;
  }*/

  // ******************* invitation *******************************

  Future<DbInvitation> insertInvitation(DbInvitation dbInvitation) async {
    var dbClient = await db;
    dbInvitation.id =
        (await dbClient.insert(tableInvitation, dbInvitation.toMap()));
    return dbInvitation;
  }

  Future<DbInvitation> getInvitationDetails() async {
    var dbClient = await db;
    List<Map> maps = await dbClient.query(
      tableInvitation,
      columns: [iUId, iGId, iGroupName, iAdminName, iAdminMobile, iRole],
    );
    if (maps.length > 0) {
      return DbInvitation.fromMap(maps.first);
    }
    return null;
  }

  Future close() async {
    var dbClient = await db;
    dbClient.close();
  }
}

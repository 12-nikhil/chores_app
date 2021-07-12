import 'dart:convert';
import 'package:chores_app/database/DatabaseHelper.dart';
import 'package:chores_app/database/entity/DBTask.dart';
import 'package:chores_app/helper/method_helper.dart';
import 'package:chores_app/models/notificationBody/NotificationAcceptedMember.dart';
import 'package:chores_app/models/notificationBody/NotificationGroupJoin.dart';
import 'package:chores_app/models/notificationBody/NotificationIDs.dart';
import 'package:chores_app/models/notificationBody/NotificationSaveData.dart';
import 'package:chores_app/models/notificationBody/NotificationTaskAccepted.dart';
import 'package:chores_app/models/notificationBody/NotificationTaskComplete.dart';
import 'package:chores_app/services/api_service.dart';
import 'package:chores_app/theme/colors/light_colors.dart';
import 'package:chores_app/ui/main_dashboard_screen.dart';
import 'package:chores_app/ui/member_dashboard_screen.dart';
import 'package:chores_app/ui/splash_screen.dart';
import 'package:chores_app/utils/Utils.dart';
import 'package:chores_app/utils/chores_constant.dart';
import 'package:cron/cron.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chores_app/models/notificationBody/NotificationTaskReceive.dart';
import 'package:chores_app/models/notificationBody/NotificationTaskRecurringIDs.dart';


// this is updated code
/*
* This is FCM background message handler
* it called when app is in background or killed or process kill
* */
// Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) async {
//   /* It clear shared preference ayt background and set default values*/
//   SharedPreferences.setMockInitialValues({});
//   if (message.containsKey('data')) {
//    // MyHomePage().createState().displayNotification(message);
//   }
// }


        Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
          // If you're going to use other Firebase services in the background, such as Firestore,
          // make sure you call `initializeApp` before using other Firebase services.
          await Firebase.initializeApp();
          print('Handling a background message ${message.messageId}');
          print('notification in');
        }

/* I am using the wrong approach
* cause cron only run when app is in foreground
* when app goes in background or kill this code will not work
* But it works*/


                  /// Create a [AndroidNotificationChannel] for heads up notifications
                  AndroidNotificationChannel channel;

                  /// Initialize the [FlutterLocalNotificationsPlugin] package.
                  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

                  Future<void> firebaseInitialize()async{

                    WidgetsFlutterBinding.ensureInitialized();
                    await Firebase.initializeApp();

                    // Set the background messaging handler early on, as a named top-level function
                    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);


                    if (!kIsWeb) {
                      channel = const AndroidNotificationChannel(
                        'high_importance_channel', // id
                        'High Importance Notifications', // title
                        'This channel is used for important notifications.', // description
                        importance: Importance.high,
                      );
                      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

                      /// Create an Android Notification Channel.
                      ///
                      /// We use this channel in the `AndroidManifest.xml` file to override the
                      /// default FCM channel to enable heads up notifications.
                      await flutterLocalNotificationsPlugin
                          .resolvePlatformSpecificImplementation<
                          AndroidFlutterLocalNotificationsPlugin>()
                          ?.createNotificationChannel(channel);

                      /// Update the iOS foreground notification presentation options to allow
                      /// heads up notifications.
                      await FirebaseMessaging.instance
                          .setForegroundNotificationPresentationOptions(
                        alert: true,
                        badge: true,
                        sound: true,
                      );
                    }


                  }
                  Future<void> firebaseInitializw1()async{


                    WidgetsFlutterBinding.ensureInitialized();
                    await Firebase.initializeApp();


                    FirebaseMessaging.instance.setAutoInitEnabled(true);
                      FirebaseMessaging.onBackgroundMessage((message) => _firebaseMessagingBackgroundHandler(message));
                      FirebaseMessaging.instance.getInitialMessage().then((value) => {
                        print('on message ${value}'),
                       // if(value!=null)
                          {
                           // onBackgroundMessageHandler(value.data),
                          }//
                      });
                      //FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
                      FirebaseMessaging.onMessage.listen((event) async {
                       await print('on message on ${event.notification} ${event.data}');
                      });
                      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
                        print('A new onMessageOpenedApp event was published! ${message.notification}');
                      });
                      FirebaseMessaging.instance.getToken().then((String token) {
                        assert(token != null);
                        print("Notification token ${token}");
                      });
                  }


Future<void> main() async {
  /* it schedule notification at every morning at 7:00 AM*/
  final cron = Cron();
  // cron.schedule(Schedule.parse('sec min hours days months weekdays'), () async {
  cron.schedule(Schedule.parse('0 0 7 * * *'), () async {
    //().createState().getTaskFromLocalDB();
  });

  // New FCM function called



  runApp(MyApp());
}

final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      // to hide debug banner
      debugShowCheckedModeBanner: false,
      title: APP_NAME,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: MyHomePage(title: APP_NAME),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  // FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  //     new FlutterLocalNotificationsPlugin();





  var uId;
  var loginRole;
  var gpName;


  @override
  initState() {
    // TODO: implement initState
    super.initState();
    //getTaskFromLocalDB();
   // FCMConfigurationForMessage();
    firebaseInitializw1();
    // firebaseConfig for message

                      // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
                      //
                      //   print('notification in');
                      //   RemoteNotification notification = message.notification;
                      //   AndroidNotification android = message.notification?.android;
                      //   if (notification != null && android != null && !kIsWeb) {
                      //     flutterLocalNotificationsPlugin.show(
                      //         notification.hashCode,
                      //         notification.title,
                      //         notification.body,
                      //         NotificationDetails(
                      //           android: AndroidNotificationDetails(
                      //             channel.id,
                      //             channel.name,
                      //             channel.description,
                      //             // TODO add a proper drawable resource to android, for now using
                      //             //      one that already exists in example app.
                      //             icon: 'launch_background',
                      //           ),
                      //         ));
                      //   }
                      // });
                      //
                      // FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
                      //   print('A new onMessageOpenedApp event was published!');
                      //
                      // });

  }



  /*
  * Set Firebase FCM - for Android And iOs
  *
  * */
  // ignore: non_constant_identifier_names
  // Future<void> FCMConfigurationForMessage()async
  // {
  //   var initializationSettingsAndroid =
  //   new AndroidInitializationSettings('@mipmap/ic_launcher');
  //
  //   var initializationSettingsIOS = new IOSInitializationSettings(
  //       onDidReceiveLocalNotification: onDidReceiveLocalNotification);
  //
  //   var initializationSettings = new InitializationSettings(
  //       android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
  //
  //   flutterLocalNotificationsPlugin.initialize(initializationSettings,
  //       onSelectNotification: onSelectNotification);
  //
  //   _firebaseMessaging.configure(
  //     //When the app is open and it receives a push notification
  //     // ignore: missing_return
  //     onMessage: (Map<String, dynamic> message) {
  //       displayNotification(message);
  //     },
  //     onBackgroundMessage: myBackgroundMessageHandler,
  //
  //     // When the app is in the background and opened directly from the push notification.
  //     // ignore: missing_return
  //     onResume: (Map<String, dynamic> message) {
  //       displayNotification(message);
  //     },
  //     // When the app is completely closed (not in the background) and opened directly from the push notification
  //     // ignore: missing_return
  //     onLaunch: (Map<String, dynamic> message) {
  //       displayNotification(message);
  //     },
  //   );
  //
  //   _firebaseMessaging.requestNotificationPermissions(
  //       const IosNotificationSettings(sound: true, badge: true, alert: true));
  //
  //   // for iOs setting
  //   _firebaseMessaging.onIosSettingsRegistered
  //       .listen((IosNotificationSettings settings) {
  //   });
  // }

  Future<void> scheduledTestNotification(
      NotificationTaskReceived taskReceived, DateTime date) async {
    FlutterLocalNotificationsPlugin fLNP =
        new FlutterLocalNotificationsPlugin();
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'ReminderChannel', 'Reminders', 'Reminder Notifications',
        color: LightColors.kPrimaryDark,
        ledColor: LightColors.kPrimaryDark,
        ledOnMs: 1000,
        ledOffMs: 1000);

    var iOSPlatformChannelSpecifics = IOSNotificationDetails();

    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);
    if (date != null) {
      var scheduledNotificationDateTime = date;
      // ignore: deprecated_member_use
      await fLNP.schedule(
          taskReceived.taskId,
          A_GENTLE_REMINDER,
          taskReceived.taskName,
          scheduledNotificationDateTime,
          platformChannelSpecifics,
          payload: 'item x');
    }
  }

  Future<void> cancelReminderNotification(int notificationId) async {
    if (flutterLocalNotificationsPlugin == null) {
      flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    }
    await flutterLocalNotificationsPlugin.cancel(notificationId);
  }

  /* Check is any task available in local dB or not*/
  // show daily notification / reminder for task pending
  Future<void> getTaskFromLocalDB() async {
    var dbHelper = DatabaseHelper();
    //var count = await dbHelper.getDbTaskCount();
    var loginRole = await getLoginRole();
    if ("Member" == loginRole) {
      var listDbTask = await dbHelper.getDBAllTask();
      if (listDbTask != null) {
        if (listDbTask.length > 0) {
          // show daily notification
          if (flutterLocalNotificationsPlugin != null) {
            var androidPlatformChannelSpecifics = AndroidNotificationDetails(
                'ReminderChannel', 'Reminders', 'Reminder Notifications',
                color: LightColors.kPrimaryDark,
                ledColor: LightColors.kPrimaryDark,
                ledOnMs: 1000,
                ledOffMs: 1000);
            var iOSPlatformChannelSpecifics = IOSNotificationDetails();
            var platformChannelSpecifics = NotificationDetails(
                android: androidPlatformChannelSpecifics,
                iOS: iOSPlatformChannelSpecifics);
            var time = new Time(7, 0, 0); //at 7:00 AM
            // ignore: deprecated_member_use
            flutterLocalNotificationsPlugin.showDailyAtTime(
                101,
                A_GENTLE_DAILY_REMINDER,
                YOUR_DAILY_TASK_IS_PENDING_REMINDER,
                time,
                platformChannelSpecifics);
            // cancel all Submitted notification
            for (DBTask dbTask in listDbTask) {
              if(SUBMITTED==dbTask.status)
                {
                  cancelReminderNotification(dbTask.tId);
                }
            }
          }
        }
      }
    }
  }

  /* Subscribe topic for FCM Notifications
  * this method is called when login successful*/
  Future<void> subscribeTopic(String mobile) async {
    await FirebaseMessaging.instance.subscribeToTopic(mobile);    //old line  _firebaseMessaging.subscribeToTopic(mobile);
  }
  /* Unsubscribe topic for FCM Notifications
  * this method is called when user remove or account remove by admin*/
  Future<void> unSubscribeTopic(String mobile) async {
    await FirebaseMessaging.instance.unsubscribeFromTopic(mobile); // old line _firebaseMessaging.unsubscribeFromTopic(mobile);
  }

  Future displayNotification(Map<String, dynamic> message) async {
    var title = message['data']['title'] ?? '';
    SharedPreferences sp = await SharedPreferences.getInstance();
    uId = await sp.getInt(SP_USER_ID) ?? 0;
    loginRole = await sp.getString(SP_ROLE) ?? null;
    gpName = await sp.getString(SP_GROUP_NAME) ?? null;
    var dbHelper = DatabaseHelper();
    if (loginRole == null) {
      await dbHelper.getAllLoginDetails().then((value) => {
            if (value != null)
              {
                uId = value.userId,
                loginRole = value.role,
                viewNotification(message, uId, loginRole)
              }
            else if ("1" == title)
              {viewNotification(message, uId, loginRole)}
          });
    } else {
      viewNotification(message, uId, loginRole);
    }
  }

  void viewNotification(
      Map<String, dynamic> message, int uId, String loginRole) {
    final title = message['data']['title'] ?? '';
    final body = message['data']['body'] ?? '';
    String notificationTitle;
    switch (title) {
      case "1":
        notificationTitle = NOTIFICATION_GROUP_JOIN;
        if (loginRole == null) {
          NotificationGroupJoin groupJoin =
              NotificationGroupJoin.fromJson(json.decode(body));
          if (groupJoin != null) {
            // getGroupAndMemberByMobileFromServer(sp, groupJoin);
            if ("Member" == loginRole) {
              saveInvitationDetailsInLocalDb(
                  groupJoin); // save invitation details in local db
            }
            showNotification(message, notificationTitle);
          }
        }
        // save data in local db
        break;
      case "2":
        // save task data in local db (taskTable)
        NotificationTaskReceived taskReceived =
            NotificationTaskReceived.fromJson(json.decode(body));
        saveTaskDetailsInDB(taskReceived, role, uId); //
        List<int> taskIdList = List();
        taskIdList.add(taskReceived.taskId);
        taskDataReceived(taskIdList, taskReceived.group_id, uId); // update data received counter on server
        if (taskReceived.memberUserId == uId) {
          if (taskReceived.dueDate != null && taskReceived.dueDate.isNotEmpty) {
            prepareForScheduleReminder(taskReceived, uId);
          } else {
            scheduledTestNotification(taskReceived, null);
          }
          notificationTitle = NOTIFICATION_NEW_TASK;
          showNotification(message, notificationTitle);
          _launchMainDashboardScreen(role, taskReceived.taskType);
        }
        break;
      case "3": // only admin can get the notification
        NotificationTaskComplete taskComplete =
            NotificationTaskComplete.fromJson(json.decode(body));
        notificationTitle = NOTIFICATION_TASK_SUBMITTED; // (Add task title)
        updateTaskStatusLocalDB(taskComplete);
        if (uId == taskComplete.adminId) {
          showNotification(message, notificationTitle);
          _launchMainDashboardScreen(role, COMPLETE_TASK_STATUS);
        }
        break;
      case "4": // only task member can view the notification and rest of member
        TaskAcceptReject taskAccept =
            TaskAcceptReject.fromJson(json.decode(body));
        if (ACCEPT == taskAccept.taskStatus) {
          notificationTitle = NOTIFICATION_TASK_ACCEPTED;
        } else {
          notificationTitle = NOTIFICATION_TASK_REJECTED;
        }
        // ((Accepted/Rejected) - Based on message)
        updateTaskStatusWithScoreLocalDB(taskAccept);
        if (uId == taskAccept.userId) {
          showNotification(message, notificationTitle);
          _openMainDashboardScreen(role, taskAccept.taskId);
        }
        // save data in local db
        break;
      case "5":
        NotificationId notificationId =
            NotificationId.fromJson(json.decode(body));
        var taskID = notificationId.taskId;
        notificationTitle =
            NOTIFICATION_TASK_DELETED; // (Don't show notification)
        // delete task entry from local db
        removeTaskFromLocalDB(taskID);
        _openMainDashboardScreen(role, taskID);
        break;
      // member delete
      case "6":
        NotificationId notificationId =
            NotificationId.fromJson(json.decode(body));
        var memberId = notificationId.memberUserId;
        notificationTitle =
            NOTIFICATION_MEMBER_REMOVE; // (Don't show notification - only update data in local db)
        // delete member entry from local db
        removeMemberFromLocalDB(memberId).then((value) => {
              if (memberId == uId && "Member" == loginRole)
                {
                  removeGroupFromLocalDB(notificationId.group_id)
                      .then((value) => {
                            openLoginScreen(),
                          })
                }
            });
        break;
      // account delete
      case "7":
        NotificationId notificationId =
            NotificationId.fromJson(json.decode(body));
        var groupId = notificationId.group_id;
        notificationTitle =
            NOTIFICATION_ACCOUNT_REMOVE; // (Don't show notification - only update data in local db)
        // delete group entry from local db
        removeGroupFromLocalDB(groupId).then((value) => {
              openLoginScreen(),
            });
        break;
      case "8":
        NotificationAcceptedMember acceptedMember =
            NotificationAcceptedMember.fromJson(json.decode(body));
        updateUserStatusLocalDB(acceptedMember);
        break;
      case "9":
        NotificationTaskRecurringIDs recurringIDs =
        NotificationTaskRecurringIDs.fromJson(json.decode(body));
        saveRecurringTaskListInDB(recurringIDs,uId);
        break;
    }
  }

  Future<void> _openMainDashboardScreen(String role, int taskId) async {
    var dbHelper = DatabaseHelper();
    await dbHelper.getDbTaskByTaskId(taskId).then((value) => {
          _launchMainDashboardScreen(role, value.taskType),
        });
  }

  Future openLoginScreen() async{
    SystemNavigator.pop();
  }

  Future prepareForScheduleReminder(
      NotificationTaskReceived taskReceived, int uid) async {
    if (uid == taskReceived.memberUserId) {
      DateTime dt = getDateTimeDate(taskReceived.dueDate.replaceAll(r'\', r''));
      TimeOfDay tod = stringToTimeOfDay(taskReceived.dueTime);
      TimeOfDay oneHourBeforeTod =
          TimeOfDay(hour: tod.hour - 1, minute: tod.minute);
      DateTime finalDate = constructDate(dt, oneHourBeforeTod);
      scheduledTestNotification(taskReceived, finalDate);
    }
  }

  Future showNotification(
      Map<String, dynamic> message, String notificationTitle) async {
    final body = message['data']['body'] ?? '';
    final title = message['data']['title'] ?? '';
    String bodyTitle = body + "@" + title;
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      NOTIFICATION_CHANNEL_ID,
      'flutterfcm',
      NOTIFICATION_CHANNEL_DESCRIPTION,
      importance: Importance.max,
      priority: Priority.high,
    );
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      APP_NAME,
      notificationTitle,
      platformChannelSpecifics,
      payload: bodyTitle,
    );
  }

  Future onSelectNotification(var payload) async {
    if (payload != null) {
      var bodyTitle = payload.toString().split("@");
      var body = bodyTitle[0];
      var title = bodyTitle[1];
      try {
        //var title= "1";
        switch (title) {
          case "1": //new group join
            navigatorKey.currentState.pushReplacement(MaterialPageRoute(
                builder: (_) => MemberDashboardScreen(
                      notification: body,
                      isNewMember: true,
                    )));
            break;
          case "2": // new task assign
            NotificationTaskReceived taskReceived =
                NotificationTaskReceived.fromJson(json.decode(body));
            int mPageIndex = 1;
            if ("Recurring" == taskReceived.taskType) {
              mPageIndex = 2;
            }
            navigatorKey.currentState.pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (BuildContext context) => MainDashboardScreen(
                      lohginRole: role,
                      pageIndex: mPageIndex,
                      groupName: gpName,
                    )),
                    (Route<dynamic> route) => false);
          /*  navigatorKey.currentState.pushReplacement(MaterialPageRoute(
                builder: (_) => MainDashboardScreen(
                      lohginRole: loginRole,
                      pageIndex: mPageIndex,
                    )));*/
            /* navigatorKey.currentState.push(
                MaterialPageRoute(builder: (_) => MemberTaskListScreen()));*/
            break;
          case "3": // task complete
            NotificationTaskComplete taskComplete =
                NotificationTaskComplete.fromJson(json.decode(body));
            int mPageIndex = 1;
            if ("Recurring" == taskComplete.taskType) {
              mPageIndex = 2;
            }
            navigatorKey.currentState.pushReplacement(MaterialPageRoute(
                builder: (_) => MainDashboardScreen(
                      lohginRole: loginRole,
                      pageIndex: mPageIndex,
                  groupName: gpName,
                    )));
            /* navigatorKey.currentState
                .push(MaterialPageRoute(builder: (_) => TaskListScreen()));*/

            break;
          case "4": // task submission
            TaskAcceptReject taskAccept =
                TaskAcceptReject.fromJson(json.decode(body));
            navigatorKey.currentState.pushReplacement(MaterialPageRoute(
                builder: (_) => MainDashboardScreen(
                      lohginRole: loginRole,
                      pageIndex: 0,
                  groupName: gpName,
                    )));
            /* navigatorKey.currentState.push(
                MaterialPageRoute(builder: (_) => MemberTaskListScreen()));*/
            break;
        }
      } catch (error) {
        print(error);
      }
    }
  }

  Future onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    // display a dialog with the notification details, tap ok to go to another page
    showDialog(
      context: context,
      builder: (BuildContext context) => new CupertinoAlertDialog(
        title: new Text(title),
        content: new Text(body),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: new Text('Ok'),
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop();
              await Fluttertoast.showToast(
                  msg: "Notification Clicked",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIos: 1,
                  backgroundColor: Colors.black54,
                  textColor: Colors.white,
                  fontSize: 16.0);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _launchMainDashboardScreen(String role, String taskType) async {
    if ("Member" == role) {
      int index = 0;
      if ('One Time' == taskType.trim()) {
        index = 1;
      } else if ("Recurring" == taskType.trim()) {
        index = 2;
      }
      navigatorKey.currentState.pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (BuildContext context) => MainDashboardScreen(
                lohginRole: role,
                pageIndex: index,
              )),
              (Route<dynamic> route) => false);
     /* navigatorKey.currentState.pushReplacement(MaterialPageRoute(
          builder: (_) => MainDashboardScreen(
                lohginRole: loginRole,
                pageIndex: index,
              )));*/
      /* Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => MainDashboardScreen(
                  lohginRole: role,
                  pageIndex: index,
                )),
        (Route<dynamic> route) => false);*/
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      body: SplashScreen(),
    );
  }
}

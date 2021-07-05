import 'package:shared_preferences/shared_preferences.dart';

final String APP_NAME = 'Chores';
final String NOTIFICATION_CHANNEL_ID = 'softwise.mechatronics.chores_app';
final String NOTIFICATION_CHANNEL_DESCRIPTION = 'Chores app';

// form label
const String BTN_REGISTER = 'REGISTER';
const String BTN_LOGIN = 'LOGIN';
const String NOT_USER = 'Not an user? Register';
const String UNASSIGN = 'Unassign';
const String ASSIGN = 'Assigned';
const String DASHBOARD = 'Dashboard';
const String LABEL_SKIP = 'Skip';

final String SELECT_MEMBER = 'Select Member';
final String ADMIN = 'Admin';
final String MEMBER = 'Member';
final String SEARCH_MEMBER = 'Search Member';
final String SOMETHING_WENT_WRONG = 'Something went wrong, Try again';
final String SEND = 'SEND';
final String ERROR = 'ERROR';
final String DUE_DATE = 'Due Date';
final String DUE_TIME = 'Due Time';
final String SCORE = 'Score';
final String POINT = 'Points';
final String ASSIGN_BY = 'Assigned By';
final String BY = 'By';
final String FOR = 'For';
final String STATUS = 'Status';
final String REPEAT = 'Repeat';
final String ENTER_TASK_NAME = 'Title';
final String ENTER_TASK_DESCRIPTION = 'Description';
final String SET_POINTS = 'Points';
final String SELECT_TYPE = 'Select Type';
final String SET_DATE = 'Set Date';
final String SET_TIME = 'Set Time';
final String SET_DATE_FROM = 'Start From';
final String SET_DATE_TO = 'End To';
final String COMPLETION_DATE = 'Completion Date';
final String COMPLETION_TIME = 'Completion Time';
final String SELECT_WEEK_DAYS = 'Select Days';
final String ONE_TIME = 'One Time';
final String RECURRING = 'Recurring';
final String TASK_NOT_FOUND = 'No Data Found';
final String TIME_AM = 'am';
final String TIME_PM = 'pm';
const String APPLY = 'APPLY';
const String CANCEL = 'CANCEL';
const String COMPLETE_TASK = 'Submit';
const String COMPLETE_TASK_STATUS = 'Submitted';
const String TASK_COMPLETE_STATUS_SEND = 'Send';
const String TASK_COMPLETE_STATUS_ERROR = 'Error';
const String TASK_COMPLETE = 'TASK COMPLETE';
const String ENTER_TASK_SCORE = 'Enter Score';
const String ACCEPT = 'Accept';
const String REJECT = 'Reject';
const String PENDING = 'Pending';
const String SUBMITTED = 'Submitted';
const String REMOVE_ACCOUNT = 'Remove Account';
const String DIALOG_OK = 'YES';
const String DIALOG_CANCEL = 'NO';
const String DIALOG_CONFIRMATION = 'Confirmation';
const String DIALOG_WARNING = 'Warning';
const String ACCOUNT_REMOVE_MESSAGE = 'Are you sure you want to remove this account? ';
const String A_GENTLE_REMINDER = 'Pending Task Reminder';
const String A_GENTLE_DAILY_REMINDER = 'Task Reminder';
const String YOUR_TASK_IS_PENDING_REMINDER = 'Your task is pending';
const String YOUR_DAILY_TASK_IS_PENDING_REMINDER = 'Your task is pending';
const String LAST_UPDATED_DATE = 'Last updated date';
const String UPDATED_DATE = 'Updated date';
const String DIALOG_SOMETHING_WRONG = 'Something went wrong';

// toast msg
const String TOAST_MSG_INVALID_FIELD = 'Invalid Field';
const String TOAST_MSG_INVALID_SCORE_FIELD = 'Invalid Score';
const String TOAST_MSG_SCORE_NOT_GREATER_THAN_POINTS = 'Score should not be greater than assign points';
const String TOAST_MSG_ENTER_DUE_DATE = 'Please Enter Due Date';
const String TOAST_MSG_ENTER_DUE_TIME = 'Please Enter Due Time';
const String TOAST_MSG_SELECT_REPEAT_DAYS ='Please Select Repeat Days';
const String TOAST_MSG_ENTER_VALID_TASK_POINT = 'Please enter valid task point';
const String TOAST_MSG_ENTER_VALID_TASK_NAME = 'Please enter task title';
const String TOAST_MSG_ENTER_VALID_TASK_DESCRIPTION = 'Please enter task description';
const String TOAST_MSG_NOT_AUTHENTICATED_USER = 'Unauthorised user';
const String TOAST_TASK_SUBMITTED ='Task Submitted';
const String TOAST_TASK_ACCEPTED ='Task Accepted';
const String TOAST_TASK_REJECTED ='Task Rejected';
const String TOAST_MSG_ENTER_START_DATE = 'Please Enter Start Date';
const String TOAST_MSG_ENTER_END_DATE = 'Please Enter End Date';
const String INTERNET_NOT_CONNECTED_MSG = 'Internet Not Connected';

// Notification Title
const String NOTIFICATION_GROUP_JOIN ='Group Join Invitation';
const String NOTIFICATION_NEW_TASK ='New Task Assign';
const String NOTIFICATION_TASK_SUBMITTED ='Task Submitted';
const String NOTIFICATION_TASK_ACCEPTED ='Task Accepted';
const String NOTIFICATION_TASK_REJECTED ='Task Rejected';
const String NOTIFICATION_TASK_DELETED ='Task Deleted';
const String NOTIFICATION_MEMBER_REMOVE ='Member Remove';
const String NOTIFICATION_ACCOUNT_REMOVE ='Account Remove';

// Popup menu
const String POPUP_MY_ACCOUNT ='My Account';
const String POPUP_TASK_HISTORY ='Task History';
const String POPUP_ABOUT ='About Us';



// Dialog titles and Message

const String MSG_TITLE_CONGRATULATION = 'Congratulation';
const String MSG_TITLE_MESSAGE = 'Message';
const String MSG_TITLE_WARNING = 'Warning';
const String INVITE_GROUP_MSG = 'Invitation';
const String JOIN_GROUP_INVITATION = 'Would you like to join this group?';
const String MEMBER_NOT_FOUND = 'Member Not Found';
const String MEMBER_NOT_SELECTED = 'Please select a member';
const String MEMBER_NOT_AVAILABLE = 'No Data Found';
const String GROUP_NOT_FOUND = 'Sorry!! You\'re not part of any group. You can either create a new group or contact your admin. ';
const String MEMBER_ADD_REQUEST_SEND_SUCCESSFULLY = 'Request send successfully';



// SharedPreferences constants

const String SP_GROUP_ID = 'group_id';
const String SP_GROUP_NAME = 'group_name';
const String SP_USER_ID = 'user_id';
const String SP_MOBILE = 'mobile';
const String SP_NAME = 'name';
const String SP_ROLE = 'role';
const String SP_COUNTRY_CODE = 'country_code';
const String SP_MEMBER_SAVED = 'memberSaved';
const String WEL_COME =  'WELCOME TO CHORES';
const String CREATE_GROUP =  'CREATE GROUP';
const String MY_CONTACTS = 'Contacts';

// ********************* Image **********************
const String WEL_COME_ICON = 'assets/images/chors_app_intro1.jpg'; //selection_screen.dart
const String BG_TOP_ICON = 'assets/images/main_top.png'; // background.dart
const String BG_BOTTOM_ICON = 'assets/images/main_bottom.png';// background.dart
const String BG_LOGIN_BOTTOM_ICON = 'assets/images/login_bottom.png'; // background.dart




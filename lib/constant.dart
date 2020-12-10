import 'dart:ui';

import 'package:basic_utils/basic_utils.dart';
import 'package:dash_chat/dash_chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:huna/call/callscreen_ravi.dart';
import 'package:huna/database/database_helper.dart';
import 'package:sqflite/utils/utils.dart';

var MSG_TARGET = "";

BuildContext  incomingCallWindow;
BuildContext  outgoingCallWindow;
BuildContext audioSessionScreen;
BuildContext videoSessionScreen;

var isOnIncomingCallWindow = false;
var isOnOutGoingCallWindow = false;
var isOnSessionAudioCall = false;
var isOnSessionVideoCall = false;

var CURRENT_CALL_ID = "";
typedef CallControlCallback = void Function(String methodName);


const colorOrange =  Color(0xfffb6d3a);


const colorOrangeLight =  Color(0xE6fb6d3a);

var colorOrangeTrans =  Color(0xD9fb6d3a);
var whiteTrans =  Color(0xD9ffffff);
const colorAccent =  Color(0xFF514C9E);
const colorAccentTrans =  Color(0xFF514C9E);
const colorAccentDark =  Color(0xFF514C9E);
const blackLight = Color(0xFF333333);


var mySystemTheme= SystemUiOverlayStyle.light.copyWith(systemNavigationBarColor: colorAccent);

enum CallType {
  INCOMING,
  OUTGOING,
  MISSED,
  REJECTED
}


getMq(BuildContext buildContext, pixel){
  return MediaQuery.of(buildContext).size.height * pixel;
}


const WSS  = "wss://divr.humonics.ai:8089/ws";
const DOMAIN_ = "@13.127.204.15";

const BASE_URL = "http://c2570ec91c38.ngrok.io";

const LOGIN_API = "https://divr.humonics.ai/webrtc/auth/login";
const FORGOT_PASSWORD_API = "https://divr.humonics.ai/webrtc/auth/forgetPassword";
const SIGN_UP_API = "https://divr.humonics.ai/webrtc/auth/signup";
const FETCH_ORG_USER = "https://divr.humonics.ai/webrtc/auth/fetchOrgUser";
const FILE_UPLOAD  = "https://divr.humonics.ai/webrtc/file/store";

const FETCH_MEETINGS = "https://divr.humonics.ai/calendar/auth/fetchAppointment";
const ADD_MEETING  = "https://divr.humonics.ai/calendar/auth/addAppointment";
const REPEAT_MEETING  = "https://divr.humonics.ai/calendar/auth/addAppointmentRepeat";

const DELETE_MEETING = "https://divr.humonics.ai/calendar/auth/deleteAppointment";
const UPDATE_MEETING  = "https://divr.humonics.ai/calendar/auth/updateAppointment";

const FETCH_CONTACTS = "$BASE_URL/contacts/fetchContact";
const ADD_CONTACT = "$BASE_URL/contacts/addContact";
const EDIT_CONTACT = "$BASE_URL/contacts/editContact";

const FETCH_ROOM_ID  = "$BASE_URL/chat/fetchRoomId";

const FETCH_CHAT = "$BASE_URL/chat/fetchChat";
const SAVE_CHAT = "$BASE_URL/chat/saveChat";

const  FETCH_ALL_CHAT = "$BASE_URL/chat/fetchLastChat";





var df = new DateFormat("E, dd MMM yyyy HH:mm:ss z");




const TextStyle kNonMissedCallNameTextStyle = TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.bold,
);

const TextStyle kMissedCallNameTextStyle = TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.bold,
  color: Colors.red,
);

const TextStyle kAppleActionButtonTextStyle = TextStyle(
  fontSize: 20,
  color: Colors.blue,
);

const TextStyle kAppleActionButtonTextStyleAccent = TextStyle(
  fontSize: 20,
  color: Colors.blueAccent,
//  fontWeight:  FontWeight.bold
);

const TextStyle kCallSourceTextStyle = TextStyle(
  color: Colors.grey,
);


const Map<String, String> numToTextMapping = {
  "1": "",
  "2": "A B C",
  "3": "D E F",
  "4": "G H I",
  "5": "J K L",
  "6": "M N O",
  "7": "P Q R S",
  "8": "T U V",
  "9": "W X Y Z",
  "0": "+",
  "*": "",
  "#": ""
};

const kKeyPadNumberTextStyle = TextStyle(
  fontSize: 55,
  fontWeight: FontWeight.w400,
);

final kColorGreyShade200 = Colors.grey.shade200;

final Color kBackGroundGreyColor = Colors.grey.shade200;

String greeting() {
  var hour = DateTime.now().hour;
  if (hour < 12) {
    return 'Good Morning';
  }
  if (hour < 17) {
    return 'Good Afternoon';
  }
  return 'Good Evening';
}


// import 'dart:ui';
//
// import 'package:basic_utils/basic_utils.dart';
// import 'package:dash_chat/dash_chat.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:huna/call/callscreen_ravi.dart';
// import 'package:huna/database/database_helper.dart';
// import 'package:sqflite/utils/utils.dart';
//
// var MSG_TARGET = "";
//
// BuildContext  incomingCallWindow;
// BuildContext  outgoingCallWindow;
// BuildContext audioSessionScreen;
// BuildContext videoSessionScreen;
//
// var isOnIncomingCallWindow = false;
// var isOnOutGoingCallWindow = false;
// var isOnSessionAudioCall = false;
// var isOnSessionVideoCall = false;
//
// var CURRENT_CALL_ID = "";
// typedef CallControlCallback = void Function(String methodName);
//
//
// const colorOrange =  Color(0xfffb6d3a);
//
//
// const colorOrangeLight =  Color(0xE6fb6d3a);
//
// var colorOrangeTrans =  Color(0xD9fb6d3a);
// var whiteTrans =  Color(0xD9ffffff);
// const colorAccent =  Color(0xFF514C9E);
// const colorAccentTrans =  Color(0xFF514C9E);
// const colorAccentDark =  Color(0xFF514C9E);
// const blackLight = Color(0xFF333333);
//
//
// var mySystemTheme= SystemUiOverlayStyle.light.copyWith(systemNavigationBarColor: colorAccent);
//
// enum CallType {
//   INCOMING,
//   OUTGOING,
//   MISSED,
//   REJECTED
// }
//
//
// getMq(BuildContext buildContext, pixel){
//   return MediaQuery.of(buildContext).size.height * pixel;
// }
//
//
// const WSS  = "wss://divr.humonics.ai:8089/ws";
// const DOMAIN_ = "@13.127.204.15";
//
// const BASE_URL = "http://c2570ec91c38.ngrok.io";
//
// const LOGIN_API = "https://divr.humonics.ai/webrtc/auth/login";
// const FORGOT_PASSWORD_API = "https://divr.humonics.ai/webrtc/auth/forgetPassword";
// const SIGN_UP_API = "https://divr.humonics.ai/webrtc/auth/signup";
// const FETCH_ORG_USER = "https://divr.humonics.ai/webrtc/auth/fetchOrgUser";
// const FILE_UPLOAD  = "https://divr.humonics.ai/webrtc/file/store";
//
// const FETCH_MEETINGS = "https://divr.humonics.ai/calendar/auth/fetchAppointment";
// const ADD_MEETING  = "https://divr.humonics.ai/calendar/auth/addAppointment";
// const REPEAT_MEETING  = "https://divr.humonics.ai/calendar/auth/addAppointmentRepeat";
//
// const DELETE_MEETING = "https://divr.humonics.ai/calendar/auth/deleteAppointment";
// const UPDATE_MEETING  = "https://divr.humonics.ai/calendar/auth/updateAppointment";
//
// const FETCH_CONTACTS = "https://divr.humonics.ai/dev/contacts/fetchContact";
// const ADD_CONTACT = "https://divr.humonics.ai/dev/contacts/addContact";
// const EDIT_CONTACT = "https://divr.humonics.ai/dev/contacts/editContact";
//
// const FETCH_ROOM_ID  = "https://divr.humonics.ai/dev/chat/fetchRoomId";
//
// const FETCH_CHAT = "https://divr.humonics.ai/dev/chat/fetchChat";
// const SAVE_CHAT = "https://divr.humonics.ai/dev/chat/saveChat";
//
// const  FETCH_ALL_CHAT = "https://divr.humonics.ai/dev/chat/fetchLastChat";
//
//
//
//
//
// var df = new DateFormat("E, dd MMM yyyy HH:mm:ss z");
//
//
//
//
// const TextStyle kNonMissedCallNameTextStyle = TextStyle(
//   fontSize: 18,
//   fontWeight: FontWeight.bold,
// );
//
// const TextStyle kMissedCallNameTextStyle = TextStyle(
//   fontSize: 18,
//   fontWeight: FontWeight.bold,
//   color: Colors.red,
// );
//
// const TextStyle kAppleActionButtonTextStyle = TextStyle(
//   fontSize: 20,
//   color: Colors.blue,
// );
//
// const TextStyle kAppleActionButtonTextStyleAccent = TextStyle(
//   fontSize: 20,
//   color: Colors.blueAccent,
// //  fontWeight:  FontWeight.bold
// );
//
// const TextStyle kCallSourceTextStyle = TextStyle(
//   color: Colors.grey,
// );
//
//
// const Map<String, String> numToTextMapping = {
//   "1": "",
//   "2": "A B C",
//   "3": "D E F",
//   "4": "G H I",
//   "5": "J K L",
//   "6": "M N O",
//   "7": "P Q R S",
//   "8": "T U V",
//   "9": "W X Y Z",
//   "0": "+",
//   "*": "",
//   "#": ""
// };
//
// const kKeyPadNumberTextStyle = TextStyle(
//   fontSize: 55,
//   fontWeight: FontWeight.w400,
// );
//
// final kColorGreyShade200 = Colors.grey.shade200;
//
// final Color kBackGroundGreyColor = Colors.grey.shade200;
//
// String greeting() {
//   var hour = DateTime.now().hour;
//   if (hour < 12) {
//     return 'Good Morning';
//   }
//   if (hour < 17) {
//     return 'Good Afternoon';
//   }
//   return 'Good Evening';
// }
//

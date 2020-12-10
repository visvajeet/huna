import 'package:flutter/material.dart';

Color myGreen = Color(0xff4bb17b);
enum MessageType {sent, received}
List<Map<String, dynamic>> friendsList = [
  {
    'imgUrl':
        'https://cdn.pixabay.com/photo/2019/11/06/17/26/gear-4606749_960_720.jpg',

  },
  {
    'imgUrl':
        'https://cdn.pixabay.com/photo/2019/11/11/04/33/africa-4617142_960_720.jpg',

  },
];

//List<Map<String, dynamic>> messages = [
//  {
//    'status' : MessageType.received,
//    'contactImgUrl' : 'https://cdn.pixabay.com/photo/2015/01/08/18/29/entrepreneur-593358_960_720.jpg',
//    'contactName' : 'Client',
//    'message' : 'Hi mate, I\d like to hire you to create a mobile app for my business' ,
//    'time' : '08:43 AM'
//  },
//  {
//    'status' : MessageType.sent,
//    'message' : 'Hi, I hope you are doing great!' ,
//    'time' : '08:45 AM'
//  },
//  {
//    'status' : MessageType.sent,
//    'message' : 'Please share with me the details of your project, as well as your time and budgets constraints.' ,
//    'time' : '08:45 AM'
//  },
//  {
//    'status' : MessageType.received,
//    'contactImgUrl' : 'https://cdn.pixabay.com/photo/2015/01/08/18/29/entrepreneur-593358_960_720.jpg',
//    'contactName' : 'Client',
//    'message' : 'Sure, let me send you a document that explains everything.' ,
//    'time' : '08:47 AM'
//  },
//  {
//    'status' : MessageType.sent,
//    'message' : 'Ok.' ,
//    'time' : '08:45 AM'
//  },
//];

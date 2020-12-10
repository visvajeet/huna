import 'dart:convert';

import 'package:dash_chat/dash_chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:huna/libraries/sip_ua/logger.dart';
import 'package:huna/manager/preference.dart';
import 'package:huna/utils/show.dart';
import 'package:huna/utils/utils.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:http/http.dart' as http;
import 'package:random_color/random_color.dart';
import 'package:uuid/uuid.dart';

import '../constant.dart';
import 'add_new_meeting.dart';
import 'meeting_model.dart';

class MeetingInfo extends StatefulWidget {

  final MeetingModel meetingModel;

  MeetingInfo({Key key, this.meetingModel}) : super(key: key);

  @override
  _MeetingInfo createState() => _MeetingInfo();
}

class _MeetingInfo extends State<MeetingInfo> {

  var you = false;
  RandomColor _randomColor = RandomColor();
  MeetingModel get meetingGet => widget.meetingModel;
  MeetingModel meeting;
  List<String> allAttendees;

  @override
  void initState() {
    super.initState();

    meeting = meetingGet;

    allAttendees = meeting.attendees.replaceAll(" ", "").split(",");
    var currentTime = new DateTime.now();
    checkIsYou(meeting);

  }

  @override
  deactivate() {
    super.deactivate();
  }

  updateMeetingInfo(MeetingModel meet){
    setState(() {
      meeting = meet;
      allAttendees = meeting.attendees.replaceAll(" ", "").split(",");
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return  Scaffold(
          appBar: AppBar(
            title: Text( meeting.title, overflow: TextOverflow.ellipsis,),
            actions: [
              Visibility(
                visible: you,
                child: PopupMenuButton<String>(
                  onSelected: handleClick,
                  itemBuilder: (BuildContext context) {
                    return {'Edit', 'Delete'}.map((String choice) {
                      return PopupMenuItem<String>(
                        value: choice,
                        child: Row(children: [
                          Icon(choice == "Edit" ? Icons.edit : Icons.delete, color: choice == "Edit" ? Colors.black87 : Colors.red[700],),
                          SizedBox(width: 10,),
                          Text(choice, style: TextStyle(color: choice == "Edit" ? Colors.black87 : Colors.red[700], fontSize: 16),),
                          SizedBox(width: 5,),

                        ],),
                      );
                    }).toList();
                  },
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Container(
              color: Colors.white,
              height: height,
              width: width,
              child: meetingDetails(context),
            ),
          ));

  }

  void handleClick(String value) {
    switch (value) {
      case 'Edit':
        editMeeting();
        break;
      case 'Delete':
        askDelete();
        break;
    }
  }



  meetingDetails(BuildContext context) {
    return Container(
      child: Padding(
        padding: EdgeInsets.only(left: 15, right: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          SizedBox(height: 15,)  ,
          Text(meeting.title ,   overflow: TextOverflow.ellipsis,style: TextStyle( fontSize: 30 ,color: Colors.black),),
          SizedBox(height: 10,),
          SizedBox(height: 10,),
          Text( '${DateFormat('h:mm a').format(df.parse(meeting.start))} - ${DateFormat('h:mm a').format(df.parse(meeting.end))}'  , style: TextStyle( fontSize: 18 ,color: Colors.black87),),
            SizedBox(height: 15,),
            Container(
              width: 60,
              decoration: BoxDecoration(
                border: Border.all(
                  color: colorAccent,
                ),
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Join',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colorAccent,fontSize: 18),
                ),
              ),
            ),
            SizedBox(height: 20,),
            Divider(height: 1, color: Colors.black38,),
            SizedBox(height: 20,),
            Text( meeting.description  , style: TextStyle( fontSize: 18 ,color: Colors.black87),),
            SizedBox(height: 20,),
            Text( 'Attendees (${meeting.attendees.split(",").length.toString()})'  , style: TextStyle( fontSize: 22 ,color: Colors.black),),
            SizedBox(height: 5,),
            Expanded(
              child: participant(),
            )

        ],),
      ),

    );
  }

  participant() {

    return ListView.separated(
      primary: false,
      separatorBuilder: (BuildContext context, int index) => Divider(height: 1),
      itemCount: allAttendees.length,
      itemBuilder: (BuildContext context, int position) {
        return  Container(
            key: PageStorageKey('myScrollable'),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              title: Row(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.fromLTRB(0.0, 10.0, 10.0, 10.0),
                    child: InkWell(
                      onTap: () {},
                      child: CircleAvatar(
                        radius: 22,
                        child: Text(
                            getFirstLetter(allAttendees[position]),
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.normal,
                                color: Colors.white)),
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text(this.allAttendees[position],
                          style: TextStyle(
                              fontSize: 17,
                              color: Colors.black87)),
                      SizedBox(height: 1),
                    ],
                  )
                ],
              ),
            ),
          );
      },
    );
  }

  askDelete() {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Are you sure yo want to delete this event?'),
            actions: <Widget>[
              new FlatButton(
                child: new Text('No'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              new FlatButton(
                child: new Text('Yes'),
                onPressed: () {
                  Navigator.of(context).pop();
                  deleteMeeting();
                },
              )
            ],
          );
        });
  }

  //Delete Meeting
  Future<void> deleteMeeting() async {

    var body = jsonEncode({
        "id" : meeting.id
    });

    print("Body");
    print(body);

    Show.showLoading(context);

    final response = await http.post(DELETE_MEETING,
        headers: {"Content-Type": "application/json"},
        body: body).timeout(Duration(seconds: 60), onTimeout: () {return null;});

    print("DELETE");
    print(response.body);


    if (response.statusCode == 200) {

      Map<String, dynamic> map = jsonDecode(response.body);

      if(map['response'] == "ERROR"){Show.showToast('${map['message']}', false); Show.hideLoading(); return;}

      if(map['response'] == "SUCCESS") {
        Show.showToast('Event deleted', false);
        Future.delayed(const Duration(milliseconds: 500), () {

          if(Show.progressDialog.isShowing()){
            Show.hideLoading();
            Navigator.pop(context,true);
          }else{
            Navigator.pop(context,true);
          }

        });
      }

    }else {
      Show.hideLoading();
      Show.showToast('Something went wrong, Please try again later', false);
    }
  }


  void editMeeting() {
    navigateToAddNewMeeting(context);
  }

  void navigateToAddNewMeeting(BuildContext context) async {
    bool result = await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return AddNewMeeting(meetingModel: meeting,);
    }));

    if (result == true) {
     // updateMeetings(context);
    }

  }

  Future<void> checkIsYou(MeetingModel meeting) async {
    var userName = await PreferencesManager().getName();
    setState(() {
      if(userName == meeting.from){
        you = true;
      }else{
        you = false;
      }
    });

  }
}

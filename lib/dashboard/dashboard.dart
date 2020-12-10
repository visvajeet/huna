import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:huna/calendar/calendar.dart';
import 'package:huna/conference/conference.dart';
import 'package:huna/manager/preference.dart';
import 'package:huna/utils/utils.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:permission_handler/permission_handler.dart';
import '../constant.dart';
import '../constant.dart';
import 'package:http/http.dart' as http;

class DashBoardPage extends StatefulWidget {
  DashBoardPage({Key key}) : super(key: key);

  @override
  _DashBoardPage createState() => _DashBoardPage();
}

class _DashBoardPage extends State<DashBoardPage> {
  String userName = " ";
  var pref = PreferencesManager();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[dashBg, content],
      ),
    );
  }

  get dashBg => Column(
        children: <Widget>[
          Expanded(
            child: Container(color: colorAccentDark),
            flex: 2,
          ),
          Expanded(
            child: Container(color: Colors.transparent),
            flex: 5,
          ),
        ],
      );

  get content => Container(
        child: Column(
          children: <Widget>[
            header,
            grid,
          ],
        ),
      );

  get header => ListTile(
        contentPadding: EdgeInsets.only(left: 20, right: 20, top: 40),
        title: Text(
          greeting(),
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          userName,
          style: TextStyle(color: Colors.white),
        ),
        trailing: CircleAvatar(
          radius: 40,
          backgroundColor: Colors.white,
          child: CircleAvatar(
            radius: 25,
            backgroundColor: Colors.deepPurple[800],
            child: Text(getFirstLetter(userName),
                style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.normal,
                    color: Colors.white)),
          ),
        ),
      );

  get grid => Expanded(
        child: Container(
          padding: EdgeInsets.only(left: 18, right: 18, bottom: 18),
          child: GridView.count(
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            crossAxisCount: 2,
            childAspectRatio: .90,
            children: List.generate(dashBoardItems.length, (index) {
              var dashBoardItem = dashBoardItems[index];
              return InkWell(
                onTap: (){
                  if(dashBoardItem.name == "New Meeting"){
                    openConference();
                  }

                  if(dashBoardItem.name == "Calender"){
                    openCalender();
                  }
                },
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  child: Center(
                    child: Column(

                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        dashBoardItem.icon,
                        Text(dashBoardItem.name)
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      );

  @override
  void initState() {
    super.initState();
    Future.wait([pref.getDisplayName(), pref.getEmail(), pref.getName()])
        .then((value) => {
              setState(() {
                if (value[0].isNotEmpty) {
                  userName = value[0].toUpperCase();
                }
              })
            });
  }

  List<DashBoardItems> dashBoardItems = [
    DashBoardItems(
      'Calender',
      'about food 3',
      Icon(
        Icons.date_range,
        color: colorAccentDark,
        size: 40,
      ),
    ),
    DashBoardItems('Schedule', 'about food 3', Icon(Icons.schedule,
        color: colorAccentDark,
        size: 40,
      ),
    ),
    DashBoardItems(
      'New Meeting',
      'about food 3',

      Icon(
        Icons.videocam,
        color: colorAccentDark,
        size: 40,
      )
    ),
    DashBoardItems(
      'Join Meeting',
      'about food 3',
      Icon(
        Icons.remove_red_eye,
        color: colorAccentDark,
        size: 40,
      ),
    ),
  ];

  Future<void> openConference() async {

    var cam = await Permission.camera.request();

    if (cam.isGranted) {

      var mic = await Permission.microphone.request();

      if (mic.isGranted) {
       // Navigator.push(context, MaterialPageRoute(builder: (context) => Conference()));

        var media = await Permission.mediaLibrary.request();

        if (media.isGranted) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => Conference()));
        }else{
          toast("Permission required");
        }

      }else{
        toast("Permission required");
      }

    }else{
      toast("Permission required");
    }

  }

  Future<void> openCalender() async {
    Navigator.push(context, MaterialPageRoute(builder: (context) => Calendar()));

  }
}

class DashBoardItems {

  final String name;
  final String detail;
  final Icon icon;

  bool isFav;
  DashBoardItems(this.name, this.detail, this.icon, {this.isFav = false});

}

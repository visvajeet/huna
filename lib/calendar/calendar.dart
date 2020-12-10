import 'dart:convert';

import 'package:basic_utils/basic_utils.dart';
import 'package:dash_chat/dash_chat.dart';
import 'package:flutter/material.dart';
import 'package:huna/calendar/add_new_meeting.dart';
import 'package:huna/calendar/meeting_info.dart';
import 'package:huna/calendar/meeting_model.dart';
import 'package:huna/manager/preference.dart';
import 'package:huna/utils/show.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sticky_grouped_list/sticky_grouped_list.dart';

import '../constant.dart';
import 'package:http/http.dart' as http;

class Calendar extends StatefulWidget {
  Calendar({Key key}) : super(key: key);

  @override
  _Calendar createState() => _Calendar();
}

class _Calendar extends State<Calendar> {
  List<MeetingModel> listOfMeetings;

  @override
  BuildContext get context => super.context;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) => {
          if (listOfMeetings == null)
            {
              listOfMeetings = List<MeetingModel>(),
              //  Show.showLoading(context),
              updateMeetings(context)
            }
        });
  }

  // Sat, 10 Oct 2020 03:30:00 GMT
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Calendar'),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.refresh,
                color: Colors.black87,
              ),
              onPressed: () {
                Show.showToast('Updating list', false);
                updateMeetings(context);
              },
            )
          ],
        ),
        floatingActionButton:
          FloatingActionButton(
          child: Icon(Icons.add),
          backgroundColor: colorAccent,
          mini: false,
          onPressed: () {
            newMeeting(context);
          },
        ),
        body: listOfMeetings != null
            ? StickyGroupedListView<MeetingModel, DateTime>(
                elements: listOfMeetings,
                padding: EdgeInsets.only(bottom: 70),
                order: StickyGroupedListOrder.ASC,
                groupBy: (MeetingModel meeting) => DateTime(df.parse(meeting.start).year, df.parse(meeting.start).month , df.parse(meeting.start).day),
                groupComparator: (DateTime value1, DateTime value2) => value2.compareTo(value1),
                itemComparator: (MeetingModel meeting1, MeetingModel meeting2) => df.parse(meeting1.start).compareTo(df.parse(meeting2.start)),
                floatingHeader: true,
                groupSeparatorBuilder: (MeetingModel meeting) => Container(
                  height: 65,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Container(
                        width: 150,
                        decoration: BoxDecoration(
                          color: colorOrange,
                          border: Border.all(
                            color: Colors.white,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('${DateFormat("E, dd MMM yyyy").format(df.parse(meeting.start))}',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontSize: 15),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                itemBuilder: (_, MeetingModel meeting) {
                  return InkWell(
                    onTap: (){navigateToMeetingInfo(meeting);},
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      elevation: 1.0,
                      margin: new EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 10.0),
                      child: Container(
                        height: 85,
                        child: Row(
                          children: [
                            SizedBox(
                              width: 15,
                            ),
                            Container(
                                decoration: BoxDecoration(
                                  color: meeting.color.startsWith("#")
                                      ? Color(ColorUtils.hexToInt(meeting.color))
                                      : colorAccent,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                width: 10,
                                height: 60),
                            SizedBox(
                              width: 20,
                            ),
                            Flexible(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    meeting.title,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 20,

                                        fontWeight: FontWeight.w400,
                                        color: Colors.black),
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.watch_later_outlined,
                                        size: 16,
                                        color: Colors.black87,
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        "${DateFormat("hh:mm aa").format(df.parse(meeting.start))} - ${DateFormat("hh:mm aa").format(df.parse(meeting.end))}",
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.black87),
                                      )
                                    ],
                                  )
                                ],
                              ),
                              flex: 3,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Flexible(
                              child: InkWell(
                                onTap: (){
                                  Show.showToast('Soon', false);
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(

                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: colorAccent, width: 1)),
                                  width: 65,
                                  height: 38,
                                  child: Text('Join', style: TextStyle(fontWeight: FontWeight.w400, fontSize: 18, color: Colors.black87),),
                                ),
                              ),
                              flex: 1,
                            ),
                            SizedBox(
                              width: 0,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              )
            : Container());
  }

  void newMeeting(BuildContext context) {
    navigateToAddNewMeeting(context);
  }

  void navigateToAddNewMeeting(BuildContext context) async {
    bool result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return AddNewMeeting();
    }));

    if (result == true) {
      updateMeetings(context);
    }
  }

  void updateMeetings(BuildContext context) async {

   var userEmailId = await  PreferencesManager().getEmail();
   var userName = await  PreferencesManager().getName();

    final response = await http
        .post(FETCH_MEETINGS)
        .timeout(Duration(seconds: 60), onTimeout: () {
      return null;
    });

    if (response.statusCode == 200) {
      Show.hideLoading();

      print("ALL MEETINGS");
      print(response.body);

      final decodedJson = json.decode(response.body);

      var listOfMeetingsTemp = List<MeetingModel>();

      (decodedJson["data"] as List<dynamic>).forEach((meeting) {
        listOfMeetingsTemp.add(MeetingModel.fromJson(meeting));
      });

      //Sort by date
      listOfMeetingsTemp.sort((a, b) {
        var aDate = DateTime(
            df.parse(a.start).year,
            df.parse(a.start).month,
            df.parse(a.start).day,
            df.parse(a.start).hour,
            df.parse(a.start).minute,
            df.parse(a.start).second);
        var bDate = DateTime(
            df.parse(b.start).year,
            df.parse(b.start).month,
            df.parse(b.start).day,
            df.parse(b.start).hour,
            df.parse(b.start).minute,
            df.parse(b.start).second);
        return aDate.compareTo(bDate);
      });

      print("ALL SORTED MEETINGS");
      listOfMeetingsTemp.forEach((meeting) {
        print(meeting.start);
      });

      setState(() {
        listOfMeetings = listOfMeetingsTemp.where((element) => element.attendees.contains(userEmailId) || element.from == userName ).toList();
      });
    } else {
      Show.showToast('Something went wrong, Please try again later', false);
      Show.hideLoading();
    }
  }

  void navigateToMeetingInfo(MeetingModel meeting) async {
    bool result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return MeetingInfo(meetingModel: meeting);
    }));

    if (result == true) {
      updateMeetings(context);
    }
  }
}

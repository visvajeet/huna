import 'dart:convert';

import 'package:basic_utils/basic_utils.dart';
import 'package:dash_chat/dash_chat.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:huna/calendar/DaysModel.dart';
import 'package:huna/manager/preference.dart';
import 'package:huna/utils/show.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import '../constant.dart';
import 'meeting_model.dart';

class AddNewMeeting extends StatefulWidget {

  final MeetingModel meetingModel;
  AddNewMeeting({Key key, this.meetingModel}) : super(key: key);

  @override
  _AddNewMeeting createState() => _AddNewMeeting();
}

class _AddNewMeeting extends State<AddNewMeeting> {

  MeetingModel get meetingGet => widget.meetingModel;

  List<String> repeatRuleList = ['Never', 'Daily', 'Weekly', 'Monthly', 'Yearly'];
  var selectedRule = "Never";
  int _groupValueEventEnd = 0;
  int occurrenceNumber = 1;
  int repeatNumber = 1;
  DateTime eventRepetitionEndDate;
  DaysModel selectedDays;

  var isUpdateMode = false;
  var title = "New Event";
  var recurrenceRule = "";
  final _title = TextEditingController();
  final _participant = TextEditingController();
  final _description = TextEditingController();

  var allDay = false;


  DateTime startTime;
  DateTime endTime;
  DateTime currentDay;

  var meetingColor = "#6232a8";


  @override
  void initState() {
    super.initState();

    var currentTime = new DateTime.now();

    selectedDays = DaysModel(sun: false, mon: false, tue: false , wed: false , thu: false, fri: false , sat: false);

    currentDay = new DateTime(
        currentTime.year,
        currentTime.month,
        currentTime.day,
        currentTime.hour,
        currentTime.minute,
        currentTime.second
    );

    eventRepetitionEndDate = new DateTime(
        currentTime.year,
        currentTime.month,
        currentTime.day,
        currentTime.hour,
        currentTime.minute,
        currentTime.second
    );

    //Update event
    if(meetingGet != null){

         title = meetingGet.title;
        _title.text = meetingGet.title;
        _participant.text = meetingGet.attendees;
        _description.text = meetingGet.description;
         recurrenceRule = meetingGet.recurrenceRule;
         isUpdateMode = true;
         if(meetingGet.color.startsWith("#")){
           meetingColor = meetingGet.color;
         }

         startTime = new DateTime(
             df.parse(meetingGet.start).year,
             df.parse(meetingGet.start).month,
             df.parse(meetingGet.start).day,
             df.parse(meetingGet.start).hour,
             df.parse(meetingGet.start).minute,
             df.parse(meetingGet.start).second,
             df.parse(meetingGet.start).microsecond
         );

         endTime = new DateTime(
             df.parse(meetingGet.end).year,
             df.parse(meetingGet.end).month,
             df.parse(meetingGet.end).day,
             df.parse(meetingGet.end).hour,
             df.parse(meetingGet.end).minute,
             df.parse(meetingGet.end).second,
             df.parse(meetingGet.end).microsecond
         );


    }else{

      isUpdateMode = false;


      startTime = new DateTime(
          currentTime.year,
          currentTime.month,
          currentTime.day,
          currentTime.hour,
          currentTime.minute,
          currentTime.second
      );
      endTime = new DateTime(
          currentTime.year,
          currentTime.month,
          currentTime.day,
          currentTime.hour,
          currentTime.minute+30,
          currentTime.second
      );

    }

  }

  @override
  deactivate() {
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: () async {
        askExit();
        return false;
      },
      child: Scaffold(
          resizeToAvoidBottomPadding: false,
          appBar: AppBar(
            title: Text(title),
            actions: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.check,
                  color: colorAccent,
                ),
                onPressed: () {
                  addNewEvent();
                },
              )
            ],
          ),
          body: SingleChildScrollView(
            child: Container(
              color: Colors.white,
              child: addNewMeetingForm(context),
            ),
          )),
    );
  }

  askExit() {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Are you sure yo want to go back?'),
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
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  addNewMeetingForm(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(left: 15, right: 15, top: 30, bottom: 15),
        child: Column(children: <Widget>[
          _addTextFiled(context, 'Title', Icons.edit, _title, 100),
          SizedBox(
            height: 10,
          ),
          _addTextFiled(
              context, 'Attendees', Icons.people, _participant, 1000, lines: 4),
          SizedBox(
            height: 10,
          ),
          _dateAndTime()
        ]));
  }

  _dateAndTime() {
    return Column(children: <Widget>[
      Row(
        children: <Widget>[
          Flexible(
            child: Container(
              height: 50,
              width: double.infinity,
              child: Icon(Icons.access_time),
            ),
            flex: 1,
          ),
          Flexible(
            child: Container(
              height: 50,
              width: double.infinity,
              alignment: Alignment.centerLeft,
              child: Padding(
                  padding: EdgeInsets.only(left: 3),
                  child: Text(
                    "All day",
                    style: TextStyle(fontSize: 16),
                  )),
            ),
            flex: 5,
          ),
          Flexible(
            child: Container(
                margin: const EdgeInsets.only(left: 30.0, right: 0.0),
                height: 50,
                width: double.infinity,
                child: Switch(
                  value: allDay,
                  onChanged: (value) {
                    setState(() {
                      allDay = !allDay;
                    });
                  },
                  activeTrackColor: Colors.deepPurple[200],
                  activeColor: colorAccent,
                )),
            flex: 2,
          ),
        ],
      ),
      SizedBox(
        height: 10,
      ),
      Row(
        children: <Widget>[
          Flexible(
            child: Container(
              alignment: Alignment.center,
              child: Text(
                "From",
                style: TextStyle(fontSize: 16),
              ),
              height: 50,
              width: double.infinity,
            ),
            flex: 1,
          ),
          SizedBox(width: 10,),
          Flexible(
            child: Container(
              height: 50,
              width: double.infinity,
              alignment: Alignment.centerLeft,
              child: Padding(
                  padding: EdgeInsets.only(left: 3),
                  child: InkWell(
                      onTap: () {
                        DatePicker.showDatePicker(context,
                            showTitleActions: true,
                            minTime: DateTime(currentDay.year, currentDay.month, currentDay.day),
                            maxTime: DateTime(2030, 12, 31),
                            theme: DatePickerTheme(
                                headerColor: Colors.white,
                                backgroundColor: Colors.white,
                                itemStyle: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18),
                                doneStyle: TextStyle(
                                    color: Colors.deepPurple,
                                    fontSize: 16)), onChanged: (date) {
                                     print('change $date in time zone ' +
                                    date.timeZoneOffset.inHours.toString());
                                     }, onConfirm: (date) {
                                      setState(() {
                                        startTime = DateTime(date.year,date.month,date.day, startTime.hour,startTime.minute);
                                      });
                                    }, currentTime: DateTime.now(), locale: LocaleType.en);
                      },
                      child: Text(
                        DateFormat('EEE, dd MMM yyyy').format(startTime),
                        style: TextStyle(fontSize: 16),
                      ))),
            ),
            flex: 3,
          ),
          Flexible(
            child: Container(
              margin: const EdgeInsets.only(left: 30.0, right: 0.0),
              height: 50,
              width: double.infinity,
              alignment: Alignment.centerLeft,
              child: Padding(
                  padding: EdgeInsets.only(left: 3),
                  child: Visibility(
                      visible: !allDay,
                      child: InkWell(
                        onTap: (){
                          DatePicker.showTime12hPicker(context,
                              showTitleActions: true,
                              onChanged: (date) {
                                print('change $date in time zone ' +
                                    date.timeZoneOffset.inHours.toString());
                              }, onConfirm: (date) {

                                setState(() {
                                  startTime = DateTime(startTime.year, startTime.month,startTime.day,date.hour,date.minute);
                                });

                              }, currentTime: DateTime.now());
                        },
                        child: Text(
                          DateFormat('hh:mm a').format(startTime),
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                      ))),
            ),
            flex: 2,
          ),
        ],
      ),
      SizedBox(
        height: 5,
      ),
      Row(
        children: <Widget>[
          Flexible(
            child: Container(
              alignment: Alignment.center,
              child: Text(
                "To  ",
                style: TextStyle(fontSize: 16),
              ),
              height: 50,
              width: double.infinity,
            ),
            flex: 1,
          ),
          SizedBox(width: 10,),
          Flexible(
            child: Container(
              height: 50,
              width: double.infinity,
              alignment: Alignment.centerLeft,
              child: Padding(
                  padding: EdgeInsets.only(left: 3),
                  child: InkWell(
                    onTap: (){
                      DatePicker.showDatePicker(context,
                          showTitleActions: true,
                          minTime: DateTime(currentDay.year, currentDay.month, currentDay.day),
                          maxTime: DateTime(2030, 12, 31),
                          theme: DatePickerTheme(
                              headerColor: Colors.white,
                              backgroundColor: Colors.white,
                              itemStyle: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18),
                              doneStyle: TextStyle(
                                  color: Colors.deepPurple,
                                  fontSize: 16)), onChanged: (date) {
                            print('change $date in time zone ' +
                                date.timeZoneOffset.inHours.toString());
                          }, onConfirm: (date) {
                            setState(() {
                              endTime = DateTime(date.year,date.month,date.day, endTime.hour,endTime.minute);
                            });
                          }, currentTime: DateTime.now(),  locale: LocaleType.en);
                    },
                    child: Text(
                      DateFormat('EEE, dd MMM yyyy').format(endTime),
                      style: TextStyle(fontSize: 16),
                    ),
                  )),
            ),
            flex: 3,
          ),
          Flexible(
            child: Container(
              margin: const EdgeInsets.only(left: 30.0, right: 0.0),
              height: 50,
              width: double.infinity,
              alignment: Alignment.centerLeft,
              child: Padding(
                  padding: EdgeInsets.only(left: 3),
                  child: Visibility(
                      visible: !allDay,
                      child: InkWell(
                        onTap: (){
                          DatePicker.showTime12hPicker(context,
                              showTitleActions: true,
                              onChanged: (date) {
                                print('change $date in time zone ' +
                                    date.timeZoneOffset.inHours.toString());
                              }, onConfirm: (date) {

                            setState(() {
                              endTime = DateTime(endTime.year, endTime.month,endTime.day,date.hour,date.minute);
                            });

                              }, currentTime: DateTime.now());
                        },
                        child: Text(
                          DateFormat('hh:mm a').format(endTime),
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                      ))),
            ),
            flex: 2,
          )
        ],
      ),
      SizedBox(
        height: 15,
      ),
      Row(
        children: <Widget>[
          Flexible(
            child: Container(
              height: 50,
              child: Icon(Icons.repeat),
              width: double.infinity,
            ),
            flex: 1,
          ),
          Flexible(
            child: Container(
              height: 50,
              width: double.infinity,
              alignment: Alignment.centerLeft,
              child: Padding(
                  padding: EdgeInsets.only(left: 3),
                  child: Text(
                    "Repeat",
                    style: TextStyle(fontSize: 16),
                  )),
            ),
            flex: 6,
          ),
          Flexible(
            child: Container(
              margin: const EdgeInsets.only(left: 0.0, right: 0.0),
              height: 50,
              width: double.infinity,
              alignment: Alignment.centerLeft,
              child: DropdownButton<String>(
                  items: repeatRuleList.map((String val) {
                    return new DropdownMenuItem<String>(
                      value: val,
                      child: new Text(val),
                    );
                  }).toList(),
                  hint: Text(selectedRule) ,
                  onChanged: (newVal) {
                    onRepeatRuleChange(newVal);
                  }),
            ),
            flex: 2,
          )
        ],
      ),

      Padding(
          child: getRules(),
          padding: EdgeInsets.all(10)),


      Row(
        children: <Widget>[
          Flexible(
            child: Container(
              height: 50,
              child: Icon(Icons.color_lens),
              width: double.infinity,
            ),
            flex: 1,
          ),
          Flexible(
            child: Container(

              height: 50,
              width: double.infinity,
              alignment: Alignment.centerLeft,
              child: Padding(
                  padding: EdgeInsets.only(left: 3),
                  child: Text(
                    "Color",
                    style: TextStyle(fontSize: 16),
                  )),
            ),
            flex: 5,
          ),
          Flexible(
            child: InkWell(
              onTap: (){
                colorPicker();
              },
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(ColorUtils.hexToInt(meetingColor)),
                ),
                margin: const EdgeInsets.only(left: 30.0, right: 10.0),
                height: 35,
                width: double.infinity,
                alignment: Alignment.centerLeft,
              ),
            ),
            flex: 2,
          )
        ],
      ),
      SizedBox(
        height: 20,
      ),
      _addTextFiled(context, 'Description', Icons.description, _description, 2000, lines: 4),
    ]);
  }

  onRepeatRuleChange(str){
    this.setState(() {
      selectedRule = str;
      clearValues();

    });
  }

  _addTextFiled(BuildContext context, String title, IconData icon, TextEditingController tec, int maxLength, {bool typeNumber = false, int lines = 1}) {
    return Theme(
      data: Theme.of(context).copyWith(
        primaryColor: colorAccent,
      ),
      child: TextFormField(
        keyboardType: typeNumber ? TextInputType.number : TextInputType.text,
        inputFormatters: typeNumber
            ? [
                new BlacklistingTextInputFormatter(new RegExp('[\\.|\\,|\\-]')),
              ]
            : [
                new BlacklistingTextInputFormatter(new RegExp('')),
              ],
        controller: tec,
        maxLines: lines,
        cursorColor: Theme.of(context).cursorColor,
        decoration: InputDecoration(
          prefixIcon: Icon(
            icon,
            color: Colors.grey,
          ),
          border: OutlineInputBorder(),
          labelText: title,
          labelStyle: TextStyle(),
        ),
      ),
    );
  }

  // ValueChanged<Color> callback
  void changeColor(Color color) {
    setState(() => meetingColor = ColorUtils.intToHex(color.value));
  }

  colorPicker (){

    showDialog(
      context: context,
      child: AlertDialog(
        title: const Text('Pick a color'),
        content: SingleChildScrollView(
          child: BlockPicker(
            pickerColor: Color(ColorUtils.hexToInt(meetingColor)),
            onColorChanged: changeColor,

          ),
          // Use Material color picker:
          //
          // child: MaterialPicker(
          //   pickerColor: pickerColor,
          //   onColorChanged: changeColor,
          //   showLabel: true, // only on portrait mode
          // ),
          //
          // Use Block color picker:
          //
          // child: BlockPicker(
          //   pickerColor: currentColor,
          //   onColorChanged: changeColor,
          // ),
        ),
        actions: <Widget>[
          FlatButton(
            child: const Text('Done'),
            onPressed: () {
              setState(() => meetingColor = meetingColor);
              print("COLOR");
              print(meetingColor);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );


  }

  Future<void> addNewEvent() async {
    if (_title.text.isEmpty) {
      Show.showToast('Please enter title', false);

      return;
    }
    if (_participant.text.isEmpty) {
      Show.showToast('Please provide participant', false);
      return;
    }

    if (_description.text.isEmpty) {
      Show.showToast('Please provide description', false);
      return;
    }

    if(allDay){

      startTime = new DateTime(
          startTime.year,
          startTime.month,
          startTime.day,
          0,
          00
      );

      endTime = new DateTime(
          endTime.year,
          endTime.month,
          endTime.day,
          23,
          59
      );
    }

    var allAttendees = _participant.text.replaceAll(" ", "").split(",");
    var startTimeISO = startTime.toIso8601String();
    var endTimeISO = endTime.toIso8601String();


    if(selectedRule == "Never"){
      recurrenceRule = "";
    }else{
      
      var  freq = selectedRule.toUpperCase();

      var byDay = "";
      var byDayRule = "";

      selectedDays.toJson().forEach((key, value) {
        if(value == true){
          byDay = byDay+",${key.toUpperCase().substring(0,2)}";
        }
      });

      if(byDay.isEmpty){
        byDayRule = "BYDAY=;";
      }else{
        byDayRule = "BYDAY=" + byDay.replaceFirst(",", "") + ";";
      }

      var wKST= "";
      if(selectedRule == "Weekly"){
        wKST = "WKST=MO;";
      }


      var until = "";
      if(_groupValueEventEnd == 2){

        if(allDay){
          eventRepetitionEndDate = DateTime(
              eventRepetitionEndDate.year,
              eventRepetitionEndDate.month,
              eventRepetitionEndDate.day,
              00,
              00,
              00,
          );
        }else{

          eventRepetitionEndDate = DateTime(
            eventRepetitionEndDate.year,
            eventRepetitionEndDate.month,
            eventRepetitionEndDate.day,
            endTime.hour,
            endTime.minute,
            endTime.second,
          );

        }

        until = "UNTIL=${DateFormat("yyyyMMdd'T'HHmmss").format(eventRepetitionEndDate)}" +'Z;';
      }

      var dtSTART = "${DateFormat("yyyyMMdd'T'HHmmss").format(startTime)}" + "Z;" ;

      //20201009T213000Z
      print("AAA");
      print(DateTime.now().toUtc().toString() );
      print(DateFormat("yyyyMMdd'T'HHmmss").format(eventRepetitionEndDate));

     // DTSTART=20201009T213000Z;UNTIL=20201014T190000Z;COUNT=1000;FREQ=DAILY;BYDAY=SU,MO,TU,WE,TH,FR,SA;WKST=0;INTERVAL=1
      //recurrenceRule = "DTSTART=$dTSTART${until}COUNT=$occurrenceNumber;FREQ=$freq;${byDayRule}${wKST}INTERVAL=$repeatNumber";
      recurrenceRule = "DTSTART=${dtSTART}UNTIL=$until;COUNT=$occurrenceNumber;FREQ=$freq;${byDayRule}WKST=0;INTERVAL=$repeatNumber";

    }

    var username = await PreferencesManager().getName();
    //New Event
    if(!isUpdateMode){

      var id = Uuid().v1();

      var body = {

        "id" : id,
        'Title': '${_title.text}',
        'from': username,
        'Description': '${_description.text}',
        'Attendees': allAttendees.join(","),
        'start': startTimeISO,
        'end': endTimeISO,
        "color": meetingColor,
        "background": "null",
        "recurrenceRule": recurrenceRule.isEmpty ? "null" : recurrenceRule,
      };

      var bodyRepeat = jsonEncode({

        "id" : id,
        'Title': '${_title.text}',
        'Description': '${_description.text}',
        "Mail" : allAttendees,
        'start': startTimeISO,
        'end': endTimeISO,
        "recurrenceRule": recurrenceRule.isEmpty ? null : recurrenceRule,
        "url": "https://humonics.ai/"

      });
      print("ADD NEW EVENT");
      print("BODY");
      print(body);

      print("ADD NEW EVENT");
      print("REPEAT BODY");
      print(bodyRepeat);

      Show.showLoading(context);
      final response = await http.post(ADD_MEETING, body: body).timeout(Duration(seconds: 60), onTimeout: () {return null;});

      if (response.statusCode == 200) {

        Map<String, dynamic> map = jsonDecode(response.body);

        if(map['response'] == "ERROR"){Show.showToast('${map['message']}', false); Show.hideLoading(); return;}

        if(map['response'] == "SUCCESS"){

          final responseRepeat = await http.post(REPEAT_MEETING,
              headers: {"Content-Type": "application/json"},
              body: bodyRepeat).timeout(Duration(seconds: 60), onTimeout: () {return null;});

          Map<String, dynamic> mapRepeat = jsonDecode(responseRepeat.body);

          if (responseRepeat.statusCode == 200) {

            if(mapRepeat['response'] == "ERROR"){Show.showToast('${mapRepeat['message']}', false); Show.hideLoading(); return;}
            if(mapRepeat['response'] == "SUCCESS"){
              Show.showToast('Event added', false);
              Future.delayed(const Duration(milliseconds: 500), () {
                if(Show.progressDialog.isShowing()){
                  Show.hideLoading();
                  Navigator.pop(context,true);
                }else{
                  Navigator.pop(context,true);
                }
              });

            }

          }else{
            Show.hideLoading();
            Show.showToast('Something went wrong, Please try again later', false);
          }

        }

      }else{
        Show.hideLoading();
        Show.showToast('Something went wrong, Please try again later', false);
      }

    //Update already existing event
    }else{

      var id = meetingGet.id;

      var body = {

        "id" : id,
        'Title': '${_title.text}',
        'from': meetingGet.from,
        'description': '${_description.text}',
        'Attendees': allAttendees.join(","),
        'start': startTimeISO,
        'end': endTimeISO,
        "color": meetingColor,
        "background": "null",
        "recurrenceRule": recurrenceRule.isEmpty ? "null" : recurrenceRule,
      };

      var bodyRepeat = jsonEncode({

        "id" : id,
        'Title': '${_title.text}',
        'Description': '${_description.text}',
        "Mail" : allAttendees,
        'start': startTimeISO,
        'end': endTimeISO,
        "recurrenceRule": recurrenceRule.isEmpty ? null : recurrenceRule,
        "url": "https://humonics.ai/"

      });

      print("UPDATE EVENT");
      print("BODY");
      print(body);

      print("UPDATE EVENT");
      print("REPEAT BODY");
      print(bodyRepeat);

      Show.showLoading(context);
      final response = await http.post(UPDATE_MEETING, body: body).timeout(Duration(seconds: 60), onTimeout: () {return null;});

      if (response.statusCode == 200) {

        Map<String, dynamic> map = jsonDecode(response.body);

        if(map['response'] == "ERROR"){Show.showToast('${map['message']}', false); Show.hideLoading(); return;}

        if(map['response'] == "SUCCESS"){

          final responseRepeat = await http.post(REPEAT_MEETING,
              headers: {"Content-Type": "application/json"},
              body: bodyRepeat).timeout(Duration(seconds: 60), onTimeout: () {return null;});

          Map<String, dynamic> mapRepeat = jsonDecode(responseRepeat.body);

          if (responseRepeat.statusCode == 200) {

            if(mapRepeat['response'] == "ERROR"){Show.showToast('${mapRepeat['message']}', false); Show.hideLoading(); return;}
            if(mapRepeat['response'] == "SUCCESS"){
              Show.showToast('Event updated', false);

              Future.delayed(const Duration(milliseconds: 500), () {
                if(Show.progressDialog.isShowing()){
                  Show.hideLoading();
                  Navigator.pop(context,true);
                  Navigator.pop(context,true);
                }else{
                  Navigator.pop(context,true);
                  Navigator.pop(context,true);
                }
              });

            }

          }else{
            Show.hideLoading();
            Show.showToast('Something went wrong, Please try again later', false);
          }

        }

      }else{
        Show.hideLoading();
        Show.showToast('Something went wrong, Please try again later', false);
      }


    }

  }

  getRules(){

    if(selectedRule == "Never")
      return Container();

    if(selectedRule == "Daily")
      return dailyRule();

    if(selectedRule == "Weekly")
      return weeklyRule();

    if(selectedRule == "Monthly")
      return monthlyRule();

    if(selectedRule == "Yearly")
      return yearlyRule();
  }



  Future numberPicker(type) async {
    await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return new NumberPickerDialog.integer(
          title: Text("Pick a number"),
          minValue: 1,
          maxValue: 1000,
          initialIntegerValue: type == "repeat" ? repeatNumber : occurrenceNumber,
        );
      },
    ).then((num value) {
      if (value != null) {
        setState(() {
          if(type == "repeat"){ repeatNumber = value; }
          else {occurrenceNumber = value; }
        });
      //  integerNumberPicker.animateInt(value);
      }
    });
  }

  onRepeatEventEndDataTimePick(){

    DatePicker.showDatePicker(context,
        showTitleActions: true,
        onChanged: (date) {
          print('change $date in time zone ' +
              date.timeZoneOffset.inHours.toString());
        }, onConfirm: (date) {
          setState(() {
            eventRepetitionEndDate = DateTime(date.year, date.month,date.day,date.hour,date.minute);
          });
        }, currentTime: eventRepetitionEndDate);
  }

  clearValues(){
    _groupValueEventEnd  = 0;
    eventRepetitionEndDate = currentDay;
    occurrenceNumber = 1;
    repeatNumber = 1;
    selectedDays = DaysModel(sun: false, mon: false, tue: false , wed: false , thu: false, fri: false , sat: false);

  }
  repeatWidget(){

    return InkWell(
      onTap: (){
        numberPicker("repeat");
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.all(Radius.circular(5.0)),),
        child: Text(repeatNumber.toString(), style: TextStyle(fontSize: 16)),
        alignment: Alignment.center,
        width: 50,
        height: 35,),
    );
  }
  occurrenceWidget(){
    return InkWell(
      onTap: (){
        numberPicker("occurrence");
      },
      child: Container(
        decoration: BoxDecoration(

          color: Colors.black12,
          borderRadius: BorderRadius.all(Radius.circular(5.0)),),
        child: Text(occurrenceNumber.toString(), style: TextStyle(fontSize: 16)),
        alignment: Alignment.center,
        width: 50,
        height: 35,),
    );
  }
  endWidget(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      children: [
        Text("End", style: TextStyle(fontSize: 16),), SizedBox(width: 20,),

        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(children: [
              Radio(
                activeColor: colorOrange,
                value: 0,
                groupValue: _groupValueEventEnd,
                onChanged: (val){
                  setState(() {
                    _groupValueEventEnd = val;
                  });
                },
              ),
              Text("Never", style: TextStyle(fontSize: 16),),

            ],),

            Row(children: [
              Radio(
                activeColor: colorOrange,
                value: 1,
                groupValue: _groupValueEventEnd,
                onChanged: (val){
                  setState(() {
                    _groupValueEventEnd = val;
                  });
                },

              ),
              Text("After", style: TextStyle(fontSize: 16),),
              SizedBox(width: 10,),
              occurrenceWidget(),
              SizedBox(width: 10,),
              Text("occurrence(s)", style: TextStyle(fontSize: 14),)

            ],),

            Row(children: [
              Radio(
                value: 2,
                activeColor: colorOrange,
                groupValue: _groupValueEventEnd,
                onChanged: (val){
                  setState(() {
                    _groupValueEventEnd = val;
                  });
                },
              ),
              Text("On", style: TextStyle(fontSize: 16),),
              SizedBox(width: 25,),
              InkWell(
                onTap: (){
                  onRepeatEventEndDataTimePick();
                },
                child: Container(
                  decoration:
                  BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),),
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      DateFormat('EEE, dd MMM yyyy').format(eventRepetitionEndDate),
                      style: TextStyle(fontSize: 16),
                    ),
                  ),),
              ),
              SizedBox(width: 10,),
              InkWell(
                  onTap: (){onRepeatEventEndDataTimePick();},
                  child: Icon(Icons.date_range , color: Colors.grey,))

            ],)

          ],),

      ],);
  }
  checkBoxDaysWidget(){
    return Expanded(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: [
          Checkbox(activeColor: colorOrange , value: selectedDays.sun,
              onChanged: (val){
                  setState(() {
             selectedDays.sun = val;
             });
          }),
          Text("Sun", style: TextStyle(fontSize: 16),),
          Checkbox(activeColor: colorOrange , value: selectedDays.mon,onChanged: (val){
            setState(() {
              selectedDays.mon = val;
            });
          } ),
          Text("Mon", style: TextStyle(fontSize: 16),),
          Checkbox(activeColor: colorOrange , value: selectedDays.tue, onChanged: (val){
            setState(() {
              selectedDays.tue = val;
            });
          }),
          Text("Tue", style: TextStyle(fontSize: 16),),
          Checkbox(activeColor: colorOrange , value: selectedDays.wed, onChanged: (val){
            setState(() {
              selectedDays.wed = val;
            });
          }),
          Text("Wed", style: TextStyle(fontSize: 16),),
          Checkbox(activeColor: colorOrange , value: selectedDays.thu, onChanged: (val){
            setState(() {
              selectedDays.thu = val;
            });
          }),
          Text("Thu", style: TextStyle(fontSize: 16),),
          Checkbox(activeColor: colorOrange , value: selectedDays.fri, onChanged: (val){
            setState(() {
              selectedDays.fri = val;
            });
          }),
          Text("Fri", style: TextStyle(fontSize: 16),),
          Checkbox(activeColor: colorOrange , value: selectedDays.sat, onChanged: (val){
            setState(() {
              selectedDays.sat = val;
            });
          }),
          Text("Sat", style: TextStyle(fontSize: 16),),
        ],),
      ),
    );
  }

  dailyRule(){
    return Container(
     width: double.infinity,
      child: Column(
        children: [
        Row(children: [
          Text("Repeat every", style: TextStyle(fontSize: 16),), SizedBox(width: 20,),
          repeatWidget(),
          SizedBox(width: 10,),
            Text("day(s)", style: TextStyle(fontSize: 14),)
        ],),
       SizedBox(height: 15,),
       endWidget()
      ],),

    );
  }

  weeklyRule(){
    return Container(
      child: Column(
        children: [
          Row(children: [
            Text("Repeat every", style: TextStyle(fontSize: 16),), SizedBox(width: 20,),
            repeatWidget(),
            SizedBox(width: 10,),
            Text("week(s)", style: TextStyle(fontSize: 14),)
          ],),
          SizedBox(height: 15,),

            Row(children: [
              Text("On", style: TextStyle(fontSize: 16),), SizedBox(width: 20,),
              checkBoxDaysWidget()
            ],),

          endWidget()
        ],),

    );
  }

  monthlyRule(){
    return Container(
      child: Column(
        children: [
          Row(children: [
            Text("Repeat every", style: TextStyle(fontSize: 16),), SizedBox(width: 20,),
            repeatWidget(),
            SizedBox(width: 10,),
            Text("month(s)", style: TextStyle(fontSize: 14),)
          ],),
          SizedBox(height: 15,),

          Row(children: [
            Text("On every", style: TextStyle(fontSize: 16),), SizedBox(width: 20,),
            checkBoxDaysWidget()
          ],),

          endWidget()
        ],),

    );
  }



  yearlyRule(){
    return Container(
      width: double.infinity,
      child: Column(
        children: [
          Row(children: [
            Text("Repeat every", style: TextStyle(fontSize: 16),), SizedBox(width: 20,),
            repeatWidget(),
            SizedBox(width: 10,),
            Text("year(s)", style: TextStyle(fontSize: 14),)
          ],),
          SizedBox(height: 15,),
          endWidget()
        ],),

    );
  }



}

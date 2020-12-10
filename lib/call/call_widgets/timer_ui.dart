import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

var startingSecondsTimer = 0;


class TimerText extends StatefulWidget {

  TimerTextState createState() =>   TimerTextState();
  const TimerText();

}

class TimerTextState extends State<TimerText> {

  Timer timer;
  var _timeLabel = "";
  var tempTimer = 0;


  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    timer?.cancel();
    timer = null;
    super.dispose();
  }


  void startTimer() {

    timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {

      tempTimer =  startingSecondsTimer + 1;

      startingSecondsTimer = tempTimer;

      Duration duration = Duration(seconds: tempTimer);
      if (mounted) {
        this.setState(() {
          _timeLabel = [duration.inMinutes, duration.inSeconds]
              .map((seg) => seg.remainder(60).toString().padLeft(2, '0'))
              .join(':');
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    return   Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
         RepaintBoundary(
          child:  SizedBox(
            height: 72.0,
            child:  Text(_timeLabel, style: TextStyle(color: Colors.white.withOpacity(1.0))),
          ),
        ),
      ],
    );

  }
}
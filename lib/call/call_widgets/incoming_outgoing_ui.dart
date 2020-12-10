import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:huna/manager/sound_player.dart';
import 'package:huna/utils/utils.dart';
import 'package:huna/widgets/action_button_call.dart';

import '../../constant.dart';

class IncomingOutGoingUI extends StatefulWidget {

  final CallControlCallback onButtonPress;
  final String name;
  final bool isOutGoing;

  const IncomingOutGoingUI({this.onButtonPress,this.name,this.isOutGoing});

  @override
  _ControlsUI createState() => _ControlsUI() ;

}

class _ControlsUI extends State<IncomingOutGoingUI> {

  bool audioMuted = false;
  bool speakerOn = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(children: <Widget>[

        // This expands the row element vertically because it's inside a column

        Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                  padding: EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
                  margin: EdgeInsets.fromLTRB(0.0,60.0, 0.0, 0.0),
                  alignment: Alignment.centerLeft,
                  child: Text(widget.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17.0,
                      ))),
            ]),

        Expanded(
          child: Container(
            margin: EdgeInsets.fromLTRB(0.0, 00.0, 0.0, 0.0),
            child: Center(
                child: Padding(
                    padding:
                    const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                    child: CircleAvatar(
                      radius: 100,
                      backgroundColor: Colors.transparent,
                      child: ClipOval(
                        child: AvatarGlow(
                          glowColor: Colors.white,
                          endRadius: 100.0,
                          duration: Duration(milliseconds: 2000),
                          repeat: true,
                          animate: true,
                          showTwoGlows: true,
                          repeatPauseDuration:
                          Duration(milliseconds: 100),
                          child: Material(
                            elevation: 8.0,
                            shape: CircleBorder(
                              side: BorderSide(
                                  width: 2, color: Colors.white),
                            ),
                            child: CircleAvatar(
                              radius: 60,
                              backgroundColor: colorAccent,
                              child: Text(getFirstLetter(widget.name),
                                  style: TextStyle(
                                      fontSize: 40,
                                      fontWeight: FontWeight.normal,
                                      color: Colors.white)),
                            ),
                          ),
                        ),
                      ),
                    ))),
          ),
        ),

        widget.isOutGoing ? Container(
            height: 60,
            width: 220,
            margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
            padding: const EdgeInsets.all(15.0),

            decoration: new BoxDecoration(
              //you can get rid of below line also
              borderRadius: new BorderRadius.circular(10.0),
              //below line is for rectangular shape
              shape: BoxShape.rectangle,
              //you can change opacity with color here(I used black) for rect
              color: Colors.black.withOpacity(0.5),
              //I added some shadow, but you can remove boxShadow also.
              boxShadow: <BoxShadow>[
                new BoxShadow(
                  color: Colors.black26,
                  blurRadius: 5.0,
                  offset: new Offset(5.0, 5.0),
                ),
              ],
            ),
            child: _outgoingCallUi()) : _incomingCallUi(),
        SizedBox(height: 50,)
      ],
      ),


    );
  }

  //Incoming call UI
  _incomingCallUi() {

    return Container(
      padding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
      child:
      Row(
        children: <Widget>[

          Expanded( //makes the red row full width
              child: ActionButtonCall(
                title: "Hangup",
                onPressed: () => widget.onButtonPress("Hangup"),
                icon: Icons.call_end,
                fillColor: Colors.red,
              )
          ),


          Expanded( //makes the red row full width
              child:  ActionButtonCall(
                title: "Accept",
                fillColor: Colors.green,
                icon: Icons.phone,
                onPressed: () => widget.onButtonPress("Accept"),
              )
          )
        ],
      ),
    );

  }

  //Outgoing call UI
  _outgoingCallUi() {

    double marginLeft = 12, marginRight = 12, iconSize = 30;
    return Padding(
        padding: const EdgeInsets.all(1),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[

            Container(
              margin: EdgeInsets.fromLTRB(marginLeft, 0, marginRight, 0),
              child: InkWell(
                child: audioMuted
                    ? Icon(Icons.mic_off, color: Colors.white, size: iconSize)
                    : Icon(Icons.mic, color: Colors.white, size: iconSize),
                onTap: () {

                  setState(() {
                    audioMuted = !audioMuted;
                  });
                  widget.onButtonPress("MuteAudio");
                },
              ),
            ),

            Container(
              margin: EdgeInsets.fromLTRB(marginLeft, 0, marginRight, 0),
              child: InkWell(
                child: speakerOn
                    ? Icon(Icons.volume_up, color: Colors.white, size: iconSize)
                    : Icon(Icons.volume_down,
                    color: Colors.white, size: iconSize),
                onTap: () {

                  setState(() {
                    speakerOn = !speakerOn;
                  });

                  SoundPlayer.earpieceOnOff(false);

                  widget.onButtonPress("Speaker");
                },
              ),
            ),

            Container(
              margin: EdgeInsets.fromLTRB(marginLeft, 0, marginRight, 0),
              child: InkWell(
                child: Icon(Icons.call_end, color: Colors.red, size: iconSize),
                onTap: () {
                  widget.onButtonPress("Hangup");

                },
              ),
            )
          ],
        ));
  }

}



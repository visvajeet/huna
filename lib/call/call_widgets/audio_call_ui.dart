import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:huna/utils/utils.dart';

import '../../constant.dart';

class AudioCallUI extends StatelessWidget {

  const AudioCallUI({ this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          // This expands the row element vertically because it's inside a column
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
            Container(
                padding: EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
                margin: EdgeInsets.fromLTRB(0.0, 64.0, 0.0, 0.0),
                alignment: Alignment.centerLeft,
                child: Text(name,
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
                      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
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
                            repeatPauseDuration: Duration(milliseconds: 100),
                            child: Material(
                              elevation: 8.0,
                              shape: CircleBorder(
                                side: BorderSide(width: 2, color: Colors.white),
                              ),
                              child: CircleAvatar(
                                radius: 60,
                                backgroundColor: colorAccent,
                                child: Text(getFirstLetter(name),
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

          // audioVideoControlUi(voiceOnly)
        ],
      ),
    );
  }

}

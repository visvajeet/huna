import 'package:flutter/material.dart';
import 'package:huna/call/call_widgets/timer_ui.dart';
import '../../constant.dart';

class TopUI extends StatefulWidget {

  final CallControlCallback onButtonPress;

  final isOnOverlay;

   TopUI(
      {this.onButtonPress,this.isOnOverlay});

  var topUIState  = new TopUIState();

  @override
  TopUIState createState() => topUIState ;

}

class TopUIState extends State<TopUI> {

  double width = double.infinity;

  @override
  Widget build(BuildContext context) {
    return addTopWindow();
  }

  // Call Control UI
  addTopWindow() {

    return Visibility(

      child: Container(
        width: width,
        height: widget.isOnOverlay ? 20 : 65,
        margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
        decoration: new BoxDecoration(
          //you can get rid of below line also
          //below line is for rectangular shape
          shape: BoxShape.rectangle,
          //you can change opacity with color here(I used black) for rect
           color: widget.isOnOverlay ? Colors.transparent :  Colors.black12,
          //I added some shadow, but you can remove boxShadow also.

        ),
        child: Stack(
          children: <Widget>[

            widget.isOnOverlay ? Container() : Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                    margin: EdgeInsets.fromLTRB(0, 35, 0, 0),
                    child: InkWell(
                      onTap: () {
                        widget.onButtonPress("onBackPip");
                      },
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                          child: Icon(Icons.arrow_back, size: 22.0, color: Colors.white)),
                    ),)

              ],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    margin: EdgeInsets.fromLTRB(0, widget.isOnOverlay ? 2 : 38, 0, 0),
                    child: TimerText()),
              ],
            ),

          ],
        ),
      ),
    );
  }


  void hideUnHideView() {
    setState(() {
      if(width == 0 ) {
        width = double.infinity;
      }else {
        width = 0;
      }
    });
  }
}

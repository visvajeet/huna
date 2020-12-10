import 'package:flutter/material.dart';

class ActionButtonRound extends StatefulWidget {
  final String title;
  final Color tint;
  final double iconSize;
  final String subTitle;
  final IconData icon;
  final bool checked;
  final bool number;
  final Color fillColor;
  final Function() onPressed;
  final Function() onLongPress;

  const ActionButtonRound(
      {Key key,
      this.title,
      this.subTitle = '',
      this.icon,
      this.onPressed,
      this.onLongPress,
      this.checked = false,
      this.number = false,
      this.fillColor,
      this.iconSize = 20.0,
        this.tint = Colors.blue
      })
      : super(key: key);

  @override
  _ActionButtonState createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButtonRound> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        GestureDetector(
            onLongPress: widget.onLongPress,
            onTap: widget.onPressed,
            child: RawMaterialButton(
              onPressed: widget.onPressed,
              splashColor: widget.fillColor != null
                  ? widget.fillColor
                  : (widget.checked ? Colors.grey[850] : Colors.blue),
              fillColor: widget.fillColor != null
                  ? widget.fillColor
                  : (widget.checked ? Colors.blue : Colors.grey[850]),
              elevation: 10.0,
              shape: CircleBorder(),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: widget.number
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                            Text('${widget.title}',
                                style: TextStyle(
                                  fontSize: 26,
                                  color: widget.fillColor != null
                                      ? widget.fillColor
                                      : Colors.white,
                                )),
                            Text('${widget.subTitle}'.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: widget.fillColor != null
                                      ? widget.fillColor
                                      : Colors.white,
                                ))
                          ])
                    : Icon(
                        widget.icon,
                        size: widget.iconSize,
                        color: widget.tint,
                      ),
              ),
            )),
        widget.number
            ? Container(
                margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0))
            : Container(
                margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 2.0),
                child: (widget.number || widget.title == null)
                    ? null
                    : Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: 15.0,
                          color: widget.fillColor != null
                              ? widget.fillColor
                              : Colors.grey[500],
                        ),
                      ),
              )
      ],
    );
  }
}

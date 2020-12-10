import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'overlay_handler.dart';
import 'overlay_widget.dart';

class OverlayService {

  addVideosOverlay(BuildContext context, Widget widget) {
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => VideoOverlayWidget(
        onClear: () {
          Provider.of<OverlayHandlerProvider>(context, listen: false).removeOverlay(context);
        },
        widget: widget,
      ),
    );

    Provider.of<OverlayHandlerProvider>(context, listen: false).insertOverlay(context, overlayEntry);
  }



}
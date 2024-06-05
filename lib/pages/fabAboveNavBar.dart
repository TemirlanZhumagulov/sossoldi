import 'package:flutter/material.dart';

class CustomFabLocation extends FloatingActionButtonLocation {
  const CustomFabLocation();

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    // FAB width is typically 56.0. Adjust the xOffset for right alignment.
    final double xOffset = scaffoldGeometry.scaffoldSize.width - 56.0 - 16.0; // 16.0 pixels from the right edge
    // Adjust yOffset to raise the FAB above the BottomNavigationBar.
    final double yOffset = scaffoldGeometry.scaffoldSize.height - 56.0 - 56.0 - 20.0; // BottomNavigationBar height + FAB height + extra padding
    return Offset(xOffset, yOffset);
  }
}

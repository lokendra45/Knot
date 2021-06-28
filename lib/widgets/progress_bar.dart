import 'package:flutter/material.dart';

Container circularProgressBar() {
  return Container(
    alignment: Alignment.center,
    padding: EdgeInsets.only(top: 10.0),
    child: CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation(Colors.indigo.shade600),
    ),
  );
}

Container linearProgressBar() {
  return Container(
    padding: EdgeInsets.only(bottom: 9.0),
    child: LinearProgressIndicator(
      valueColor: AlwaysStoppedAnimation(Colors.indigo.shade600),
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class NoPostScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SafeArea(
        child: Center(
          child: Container(
            margin: EdgeInsets.only(top: 90.0),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SvgPicture.asset(
                    'assets/images/noPost.svg',
                    height: 180.0,
                    color: Colors.red.shade100,
                    fit: BoxFit.fitHeight,
                    alignment: Alignment.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

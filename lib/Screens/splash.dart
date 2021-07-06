import 'dart:async';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:knot/Screens/home.dart';


class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return initScreen(context);
  }

  void initState() {
    super.initState();
    startTimer();
  }

  startTimer() {
    var duration = Duration(seconds: 3);
    return new Timer(duration, route);
  }

  route() async {
    await Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => HomePage(),
      ),
      (r) => false,
    );
    
  }

  initScreen(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Colors.red.shade200,
              Colors.deepPurple.shade400,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Center(
                child: Container(
                  margin: EdgeInsets.all(30.0),
                  height: 105.0,
                  width: 240.0,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/knot.png'),
                    ),
                  ),
                  alignment: Alignment.center,
                ),
              ),
              Center(
                child: SizedBox(
                  height: 300.0,
                  width: 300,
                  child: Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(top: 250.0),
                    child: AnimatedTextKit(
                      animatedTexts: [
                        RotateAnimatedText(
                          'Memories',
                          textStyle: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 45.0,
                            color: Colors.white,
                          ),
                        ),
                        RotateAnimatedText(
                          'In a',
                          textStyle: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 50.0,
                            color: Colors.white,
                          ),
                        ),
                        RotateAnimatedText(
                          'Snap',
                          textStyle: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 40.0,
                            color: Colors.white,
                          ),
                        ),
                      ],
                      isRepeatingAnimation: true,
                      pause: const Duration(milliseconds: 50),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

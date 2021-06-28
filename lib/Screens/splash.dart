import 'dart:async';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:knot/Screens/home.dart';

import 'package:page_transition/page_transition.dart';

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

  startTimer() async {
    var duration = Duration(seconds: 2);
    return new Timer(duration, route);
  }

  route() async {
    Navigator.push(
        context,
        PageTransition(
            child: HomePage(),
            type: PageTransitionType.leftToRightWithFade,
            reverseDuration: Duration(milliseconds: 400),
            curve: Curves.easeInOut));
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

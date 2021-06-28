import 'package:animator/animator.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

AppBar header(context,
    {bool isApplicationTitle = false, required String titleText}) {
  return AppBar(
    automaticallyImplyLeading: false,
    shadowColor: Colors.grey.shade900,
    title: Text(
      isApplicationTitle ? "Knot" : titleText,
      style: GoogleFonts.pacifico(
        color: Colors.white,
        fontSize: isApplicationTitle ? 40.0 : 25,
        fontWeight: FontWeight.w100,
      ),
      overflow: TextOverflow.ellipsis,
    ),
    centerTitle: true,
    backgroundColor: Colors.indigo,
    elevation: 2,
  );
}

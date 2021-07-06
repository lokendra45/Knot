import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:knot/Screens/home.dart';

class SignUp extends StatefulWidget {
  SignUp({Key? key}) : super(key: key);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final GlobalKey<FormState> _registerFormKey = GlobalKey<FormState>();
  TextEditingController nameInputController = new TextEditingController();
  TextEditingController usernameInputController = new TextEditingController();
  TextEditingController emailInputController = new TextEditingController();
  TextEditingController passwordInputController = new TextEditingController();

  emailValidator(String value) {
    RegExp regex = new RegExp(
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');
    if (!regex.hasMatch(value)) {
      return "Email format is invalid";
    } else {
      return null;
    }
  }

  pwdValidator(String value) {
    if (value.length < 8) {
      return 'Password must be longer than 8 characters';
    } else {
      return null;
    }
  }

  Widget _buildEmailRow() {
    return Padding(
      padding: EdgeInsets.all(8),
      child: TextFormField(
        controller: emailInputController,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        keyboardType: TextInputType.emailAddress,
        validator: (value) {
          RegExp regex = new RegExp(
              r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');
          if (!regex.hasMatch(value!)) {
            return "Email format is invalid";
          } else {
            return null;
          }
        },
        onChanged: (value) {},
        decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.email_outlined,
              color: Colors.indigo,
            ),
            labelText: 'E-mail'),
      ),
    );
  }

  Widget _buildUsernameRow() {
    return Padding(
      padding: EdgeInsets.all(8),
      child: TextFormField(
        controller: usernameInputController,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        keyboardType: TextInputType.text,
        validator: (value) {
          if (value!.length < 3) {
            return "Please enter a valid first name.";
          }
        },
        onChanged: (value) {},
        decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.email_outlined,
              color: Colors.indigo,
            ),
            labelText: 'username'),
      ),
    );
  }

  Widget _buildNameRow() {
    return Padding(
      padding: EdgeInsets.all(8),
      child: TextFormField(
        controller: nameInputController,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        keyboardType: TextInputType.name,
        validator: (value) {
          if (value!.length < 3) {
            return "Please enter a valid first name.";
          }
        },
        onChanged: (value) {},
        decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.person,
              color: Colors.indigo,
            ),
            labelText: 'Name'),
      ),
    );
  }

  Widget _buildPasswordRow() {
    return Padding(
      padding: EdgeInsets.all(8),
      child: TextFormField(
        controller: passwordInputController,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        keyboardType: TextInputType.text,
        validator: (value) {
          pwdValidator(value!);
        },
        obscureText: true,
        onChanged: (value) {},
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.password_rounded,
            color: Colors.indigo,
          ),
          labelText: 'Password',
        ),
      ),
    );
  }

  Widget _buildSiginUpButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          height: 50,
          width: 100,
          margin: EdgeInsets.only(bottom: 20, top: 10),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                primary: Colors.indigo,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40.0))),
            onPressed: () {
              if (_registerFormKey.currentState!.validate()) {
                final _user = firebaseAuth;

                _user!
                    .createUserWithEmailAndPassword(
                        email: emailInputController.text,
                        password: passwordInputController.text)
                    .then((value) => {
                          usersRef.doc(value.user!.uid).set({
                            "id": value.user!.uid,
                            "username": usernameInputController.text,
                            "photoUrl": value.user!.photoURL,
                            "email": emailInputController.text,
                            "displayName": nameInputController.text,
                            "bio": "",
                            "timestanmp": timeStamp,
                          }).then((value) => {
                          
                                Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => HomePage()),
                                    (_) => false),
                                emailInputController.clear(),
                                usernameInputController.clear(),
                                passwordInputController.clear(),
                                nameInputController.clear(),
                              })
                        });
              }
            },
            child: Text(
              "SignUp",
              style: TextStyle(
                color: Colors.white,
                letterSpacing: 1,
                fontSize: 15,
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildLoginBtn() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 40),
          child: TextButton(
            onPressed: () async {
              await Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => HomePage(),
                ),
                (r) => false,
              );
            },
            child: RichText(
              text: TextSpan(children: [
                TextSpan(
                  text: 'Already Have Account  ',
                  style: TextStyle(
                    color: Colors.indigo,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ]),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildSignUpContainer() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.6,
            width: MediaQuery.of(context).size.width * 0.8,
            decoration: BoxDecoration(color: Colors.white),
            child: SingleChildScrollView(
              child: Form(
                key: _registerFormKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "SignUp",
                          style: GoogleFonts.acme(
                            fontSize: MediaQuery.of(context).size.height / 30,
                            color: Colors.indigo,
                          ),
                        ),
                      ],
                    ),
                    _buildUsernameRow(),
                    _buildNameRow(),
                    _buildEmailRow(),
                    _buildPasswordRow(),
                    _buildSiginUpButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildSignUpScreen() {
    return SafeArea(
      child: Scaffold(
        //  resizeToAvoidBottomPadding: false,
        backgroundColor: Color(0xfff2f3f7),
        body: Stack(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height * 0.7,
              width: MediaQuery.of(context).size.width,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.only(
                    bottomLeft: const Radius.circular(70),
                    bottomRight: const Radius.circular(70),
                  ),
                ),
              ),
            ),
            SingleChildScrollView(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Divider(
                      height: 50,
                    ),
                    buildSignUpContainer(),
                    _buildLoginBtn(),
                  ]),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildSignUpScreen();
  }
}

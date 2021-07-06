import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:knot/widgets/header.dart';

class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final _formKey = GlobalKey<FormState>();
  String? username;

  void submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Navigator.pop(this.context, username);
    }
  }

// button for creating account
  Widget _buildSubmitButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          alignment: Alignment.center,
          height: 40,
          width: 90,
          margin: EdgeInsets.only(top: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    primary: Colors.indigo.shade400,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0))),
                onPressed: submit,
                child: Center(
                  child: Text(
                    "Create",
                    style: TextStyle(
                      color: Colors.white,
                      letterSpacing: 1,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

// Profile creating view
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: header(context, titleText: "Create Your Profile"),
        backgroundColor: Colors.indigo.shade100,
        body: Stack(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height * 0.7,
              width: MediaQuery.of(context).size.width,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: const Radius.circular(70),
                    bottomRight: const Radius.circular(70),
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 20),
              child: ListView(
                children: <Widget>[
                  Container(
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 25.0),
                          child: Center(
                            child: Text(
                              "Create Your UserName",
                              style: TextStyle(
                                  fontSize: 24.0, color: Colors.black54),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Container(
                            child: Form(
                                key: _formKey,
                                child: TextFormField(
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  autofocus: true,
                                  maxLength: 10,
                                  maxLengthEnforcement:
                                      MaxLengthEnforcement.enforced,
                                  validator: (value) {
                                    final regexUsername =
                                        RegExp(r"^[a-zA-Z0-9_]{3,20}$");
                                    if (value!.trim().length < 3) {
                                      return "Username too short";
                                    }

                                    if (value.trim().isEmpty) {
                                      return "Username must Entered";
                                    }
                                    if (!regexUsername.hasMatch(value)) {
                                      return "Usernames should be a maximum of 20 characters with letters, numbers or underscores only.";
                                    } else {
                                      return null;
                                    }
                                  },
                                  onSaved: (newValue) => username = newValue!,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: "Username",
                                    labelStyle: TextStyle(fontSize: 16.0),
                                    hintText: "Must Have at Least 3 Chracters",
                                  ),
                                )),
                          ),
                        ),
                        _buildSubmitButton()
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

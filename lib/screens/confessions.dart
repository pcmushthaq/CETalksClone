import 'dart:convert';
import 'package:cettalks1/widgets/myalertdialog.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class Confession {
  final String message;
  Confession(this.message);
}

class Confessions extends StatefulWidget {
  static const routeName = '/confessions';

  @override
  _ConfessionsState createState() => _ConfessionsState();
}

class _ConfessionsState extends State<Confessions> {
  final _form = GlobalKey<FormState>();

  var current;
  var _isLoading = false;

  void _saveform(BuildContext context) async {
    final isValid = _form.currentState.validate();

    if (!isValid) {
      return;
    }

    _form.currentState.save();
    Navigator.of(context).pop();

    setState(() {
      _isLoading = true;
    });

    try {
      await _addToDB(current.message);
    } catch (error) {
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: Theme.of(context).accentColor,
          title: Text('An error occurred!'),
          content: Text('Something went wrong.'),
          actions: <Widget>[
            FlatButton(
              child: Text('Okay'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            )
          ],
        ),
      );
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _addToDB(String message) async {
    final url = 'https://cetalksdummy.firebaseio.com/confessions.json';
    try {
      await http.post(url, body: json.encode({'message': message}));
    } catch (error) {
      print(error);
      throw (error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        title: Text(
          'Confessions',
          style: TextStyle(fontSize: 25),
        ),
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Submitting',
                    style: GoogleFonts.lato(
                        color: Theme.of(context).accentColor, fontSize: 18),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  CircularProgressIndicator(),
                ],
              ),
            )
          : Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Form(
                      key: _form,
                      child: TextFormField(
                        maxLines: 5,
                        cursorColor: Colors.pink,
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter something.';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          current = Confession(value);
                        },
                        style: TextStyle(color: Theme.of(context).accentColor),
                        decoration: InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey, width: 1),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.pink),
                          ),
                          hintText: 'Confess Here',
                          hintStyle: TextStyle(color: Colors.white54),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    RaisedButton(
                      child: Text(
                        "Submit",
                        style: TextStyle(fontSize: 16),
                      ),
                      onPressed: () {
                        final validity = _form.currentState.validate();
                        if (!validity) return;
                        showAlertDialog(
                            context,
                            "Are you sure you want to submit your feedback?",
                            () => _saveform(context));
                      },
                    )
                  ],
                ),
              ),
            ),
    );
  }
}

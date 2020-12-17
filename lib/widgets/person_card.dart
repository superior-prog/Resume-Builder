import 'dart:io';

import 'package:cv_builder/helper/db_helper.dart';
import 'package:cv_builder/models/person.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';

class PersonCard extends StatefulWidget {
  final Person person;

  PersonCard({this.person});

  @override
  _PersonCardState createState() => _PersonCardState();
}

class _PersonCardState extends State<PersonCard> {
  TextEditingController titleController = TextEditingController();

  DBHelper dbHelper = DBHelper();

  final pdf = pw.Document();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10.0),
      child: Container(
        margin: EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Image.asset(
                      "assets/avatars/rdj.png",
                      height: 50,
                      width: 50,
                    ),
                    SizedBox(width: 10.0),
                    Text(
                      widget.person.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.0),
                Text(
                  "Created on:",
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Icon(
                          Icons.calendar_today,
                          size: 20.0,
                        ),
                        Text(
                          widget.person.creationDateTime.toString(),
                          // "10:15",
                          style: TextStyle(
                            fontSize: 12.0,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 5.0),
                    // Row(
                    //   children: <Widget>[
                    //     Icon(
                    //       Icons.watch_later,
                    //       size: 20.0,
                    //     ),
                    //     Text(
                    //       "10:11 am",
                    //       style: TextStyle(
                    //         fontSize: 12.0,
                    //       ),
                    //     ),
                    //   ],
                    // ),
                  ],
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: InkWell(
                    onTap: () => convertToPdf(),
                    child: Text(
                      "Convert to PDF",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10.0),
                Row(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        showAlertDialog(context);
                      },
                      child: Icon(
                        Icons.edit,
                        size: 30.0,
                      ),
                    ),
                    SizedBox(width: 10.0),
                    GestureDetector(
                      onTap: () {
                        showDeleteDialog(context);
                      },
                      child: Icon(
                        Icons.delete,
                        size: 30.0,
                      ),
                    ),
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  convertToPdf() async {
    if (await Permission.storage.request().isGranted) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              children: [
                pw.Text(
                  widget.person.firstName + " " + widget.person.surname,
                  style: pw.TextStyle(
                    fontSize: 20.0,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Divider(indent: 10, endIndent: 10),
              ],
            ); // Center
          },
        ),
      );

      showGiveNameDialog(context);

      // Directory tempDir = await getTemporaryDirectory();
      // String tempPath = tempDir.path;
      // final File file =
      //     File("/storage/emulated/0/Download/${widget.person.title}.pdf");
      // await file.writeAsBytes(pdf.save());
    }
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
    ].request();
  }

  showGiveNameDialog(BuildContext context) {
    String name;
    final nameController = TextEditingController();
    // set up the button
    Widget okButton = FlatButton(
      child: Text("Save"),
      onPressed: () async {
        final File file = File("/storage/emulated/0/Download/$name.pdf");
        await file.writeAsBytes(pdf.save());
        Navigator.pop(context);
      },
    );

    Widget cancelButton = FlatButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Resume title"),
      content: TextFormField(
        autofocus: true,
        onChanged: (value) {
          setState(() {
            name = value;
          });
        },
        decoration: InputDecoration(
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.blue),
          ),
          hintText: widget.person.title,
        ),
      ),
      actions: [okButton, cancelButton],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showAlertDialog(BuildContext context) {
    // set up the button
    Widget okButton = FlatButton(
      child: Text("Update"),
      onPressed: () async {
        await dbHelper.updateTitle(widget.person.id, titleController.text);
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Profile title"),
      content: TextFormField(
        autofocus: true,
        controller: titleController,
        decoration: InputDecoration(
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.blue),
          ),
          hintText: "Change title",
        ),
        keyboardType: TextInputType.text,
      ),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showDeleteDialog(BuildContext context) {
    // set up the button
    Widget cancelButton = FlatButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    Widget okButton = FlatButton(
      child: Text("Delete"),
      onPressed: () async {
        await dbHelper.deletePerson(widget.person.id);
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Deleting " + widget.person.title + "'s Profile"),
      content: Text("Are you sure about deleting this profile?"),
      actions: [
        cancelButton,
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}

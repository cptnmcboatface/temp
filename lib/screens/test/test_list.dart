import 'package:flutter/material.dart';
import 'package:poolish/screens/test/color_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:poolish/shared/constants.dart';
import 'package:google_fonts/google_fonts.dart';

class TestsList extends StatefulWidget {
  final Stream testListsStream;
  final Function updateDoc;
  final Function addNewTest;
  final Function setTestList;
  TestsList(
      {this.testListsStream,
      this.updateDoc,
      this.addNewTest,
      this.setTestList});
  @override
  _TestsListState createState() => _TestsListState();
}

class _TestsListState extends State<TestsList> {
  String myKey;
  @override
  Widget build(BuildContext context) {
    return Container(
        child: StreamBuilder<DocumentSnapshot>(
      stream: widget.testListsStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return Center(
            child: Text("Error Connecting to the Internet", style: errorStyle),
          );
        DocumentSnapshot docs = snapshot.data;
        var userTests = docs.data;
        List<String> keys = userTests.keys.toList();
        keys.map(DateTime.parse);
        keys.sort();
        var latestKey = keys.last.toString();
        var testResults;
        
        if (userTests[latestKey]["completed"] == false) {
          myKey = latestKey;
          testResults = userTests[latestKey]["testVal"];
        } else {
          myKey = returnTime();
          widget.addNewTest(myKey);
        }
        widget.setTestList(userTests[latestKey]["testVal"], latestKey);
        return new ListView.builder(
          physics: BouncingScrollPhysics(),
          itemCount: testResults.length,
          itemBuilder: (BuildContext context, int index) {
            String key = testResults.keys.elementAt(index);
            return new Column(
              children: <Widget>[
                listTile(key, testResults[key]),
                Container(
                  height: 5.0,
                  color: Color.fromRGBO(217, 217, 217, 1.0),
                ),
              ],
            );
          },
        );
        // return listsWidget(testResults);
      },
    ));
  }

  Widget listTile(String testName, String value) {
    return new ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ColorTestScreen(
                    testName: testName,
                    val: value,
                    updateVal: updateVal,
                  )),
        );
      },
      trailing: new Container(
          margin: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
          child: (value == "" || value == null)
              ? (Icon(
                  Icons.cancel,
                  color: Colors.black,
                ))
              : (Icon(
                  Icons.check_circle_outline,
                  color: mainThemeColor,
                ))),
      title: new Text(testName,
          style: GoogleFonts.poppins(
              textStyle: TextStyle(color: Colors.black, fontSize: 20))),
      subtitle: (value == "" || value == null)
          ? Text("")
          : safeOrNot(testName, value)
              ? Text("Safe",
                  style: GoogleFonts.poppins(
                      textStyle: TextStyle(color: mainThemeColor)))
              : Text("Unsafe",
                  style: GoogleFonts.poppins(
                      textStyle: TextStyle(color: Colors.red))),
    );
  }

  void updateVal(String test, String selected) async {
    await widget.updateDoc(test, selected, myKey);
  }
}

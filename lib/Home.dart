import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:seventy5/subject.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:seventy5/username.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  Home({required this.name,required this.token});
  late String idLink;

  String name;
  String token;
  late String section;


  late List<dynamic> ids = [];
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    dataFuture = fetchClass();
    onPass();
  }

  late List<dynamic> data = [];
  late Future<List<dynamic>?> dataFuture;
  var subjectId = <String>[];
  var subjectName = <String>[];
  var subjectDetails = <Subject>[];
  late Future<Subject> dataFuture2;
  late String class_name;
  bool darkMode = false;

  var tempData;
  int check = 0;

  @override
  Widget build(BuildContext context) {
    if (check == 0) {
      return  WillPopScope( onWillPop: () async => false,
        child: Scaffold(
            body: Center(
          child: RiveAnimation.asset(
            "animation/4.riv",
          ),
        )),
      );
    } else {
      return WillPopScope( onWillPop: () async {SystemNavigator.pop();
      return false;
      },
        child: Scaffold(
          backgroundColor: darkMode ? Colors.grey[850] : Colors.grey[300],
          body: SingleChildScrollView(
            physics: const ScrollPhysics(),
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
               Container( margin: const EdgeInsets.fromLTRB(20, 70, 20, 0),
                 child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween

                 ,children: [
                   Column(crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Text(widget.name,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 24),),
                       Text( class_name,style: TextStyle(fontWeight: FontWeight.w400),)
                     ],
                   ),
                   NeumorphicButton(
                       margin: EdgeInsets.only(top: 12),

                       onPressed: () {
                       showAlertDialog(context);




                         NeumorphicTheme.of(context)?.themeMode =
                         darkMode
                             ? ThemeMode.light
                             : ThemeMode.dark;
                       },
                       style: NeumorphicStyle(
                         color: darkMode ? Colors.grey[850] : Colors.grey[300],
                         shape: NeumorphicShape.concave,
                         boxShape:
                         NeumorphicBoxShape.circle(),
                       ),
                       padding:  const EdgeInsets.fromLTRB(12, 12, 12, 12),
                       child: Icon(FontAwesomeIcons.person,size: 27,),)
                 ],),
               ),

                ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: subjectDetails.length,
                    itemBuilder: (context, index) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                            padding: const EdgeInsets.all(18),
                            width: MediaQuery.of(context).size.height / 1.5,
                            height: MediaQuery.of(context).size.height / 6.5,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(child: Text(subjectDetails[index].name.toUpperCase(),style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500))),
                                      const SizedBox(height: 10),
                                      Text(subjectDetails[index].present+"/"+subjectDetails[index].total),
                                      const SizedBox(height: 5),
                                      Text(
                                          double.parse(subjectDetails[index].percentage)>=75 ?
                                          "Can cut " + ((int.parse(subjectDetails[index].present)/0.75).floor()-int.parse(subjectDetails[index].total)).toString() + " classes" :
                                          "Need to attend " + (3 * int.parse(subjectDetails[index].total) - 4 * int.parse(subjectDetails[index].present)).toString() + " classes"
                                      ),
                                    ],
                                  ),
                                ),
                                CircularPercentIndicator(
                                  radius: 45.0,
                                  lineWidth: 3.0,
                                  percent: double.parse(subjectDetails[index].percentage)/100,
                                  center: Text(
                                    double.parse(subjectDetails[index].percentage).toStringAsFixed(1) + "%",
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  progressColor: Colors.black,
                                )
                              ],
                            ),
                            decoration: BoxDecoration(
                                color: darkMode
                                    ? Colors.grey[850]
                                    : Colors.grey[300],
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(34)),
                                boxShadow: [
                                  BoxShadow(
                                      color: darkMode
                                          ? (Colors.black54)
                                          : (Colors.grey[500])!,
                                      offset: const Offset(4.0, 4.0),
                                      blurRadius: 15.0,
                                      spreadRadius: 1.0),
                                  BoxShadow(
                                      color: darkMode
                                          ? (Colors.grey[800])!
                                          : Colors.white,
                                      offset: const Offset(-4.0, -4.0),
                                      blurRadius: 15.0,
                                      spreadRadius: 1.0),
                                ]),
                          ),
                          const SizedBox(
                            height: 40,
                          )
                        ],
                      );
                    }),
              ],
            ),
          ),
        ),
      );
    }
  }

  Future<List<dynamic>?> fetchClass() async {
    final url =
        Uri.parse("https://production.api.ezygo.app/api/v1/usersubgroups");

    final response = await http.get(url, headers: {
      'Authorization': 'Bearer ${widget.token}',
      'Accept': 'application/json, text/plain, */*',
    });
    // print(response.body);

    setState(() {
      data = json.decode(response.body);

    });

    return data;
  }

  Future<List<dynamic>?> fetchLists() async {
    final url = Uri.parse(
        "https://production.api.ezygo.app/api/v1/institutionuser/courses/withusers");

    final response = await http.get(url, headers: {
      'Authorization': 'Bearer ${widget.token}',
      'Accept': 'application/json, text/plain, */*',
    });
    // print(response.body);

    setState(() {
      data = json.decode(response.body);
    });
// print(data);
    for (int i = 0; i < data.length; i++) {
      if (data[i]["usersubgroup"]["id"] == int.parse(widget.idLink)) {
        subjectId.add(data[i]["id"].toString());
        subjectName.add(data[i]["name"]);
      }
    }
    // print(subject_id);
    // print(subject_name);
    for (int i = 0; i < subjectId.length; i++) {
      var tempdata = await fetchAttendance(subjectId[i].toString());
      Subject temp = Subject(
          present: tempdata["present"].toString(),
          name: subjectName[i],
          percentage: tempdata["persantage"].toString(),
          total: tempdata["totel"].toString());
      setState(() {
        subjectDetails.add(temp);
      });
    }
    setState(() {
      check = 1;
    });
    print(subjectDetails[0].total);

    return data;
  }

  Future<Map<String, dynamic>> fetchAttendance(String id) async {
    final url = Uri.parse(
        "https://production.api.ezygo.app/api/v1/attendancereports/institutionuser/courses/+$id+/summery");

    final response = await http.get(url, headers: {
      'Authorization': 'Bearer ${widget.token}',
      'Accept': 'application/json, text/plain, */*',
    });
    // print(response.body);

    setState(() {
      tempData = json.decode(response.body);
    });
// // print(data);

//print(response.body);

    return tempData;
  }

  void onPass() async {
    if (data.isNotEmpty) {
      widget.idLink = (data[1]["id"].toString());
      class_name= (data[1]["name"].toString());
    } else {
      await fetchClass();
      widget.idLink = (data[data.length - 1]["id"].toString());
      class_name= (data[1]["name"].toString());
    }

    await fetchLists();
  }


  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text("Cancel"),
      onPressed:  () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = FlatButton(
      child: Text("Sign out"),
      onPressed:  ()async {
        // Try reading data from the 'counter' key. If it doesn't exist, returns null.
        // Obtain shared preferences.

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) =>  Username()),
        );
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(

      content: Text("Are you sure you want to sign out?"),
      actions: [
        cancelButton,
        continueButton,
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

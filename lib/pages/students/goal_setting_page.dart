import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:sign_in_up/model/error.dart';
import 'package:sign_in_up/util/userApi.dart';

class GoalSettingPage extends StatefulWidget {
  final int goal;
  const GoalSettingPage({super.key, required this.goal});

  @override
  State<GoalSettingPage> createState() => _GoalSettingPageState();
}

class _GoalSettingPageState extends State<GoalSettingPage> {
  final storage = FlutterSecureStorage();
  final MAIN_COLOR = Color.fromRGBO(224, 135, 255, 1.0);
  late int goalInMeter = widget.goal;
  var f = NumberFormat('###,###,###,###');
  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final deviceHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextButton(
              onPressed: (){Navigator.pop(context, 'cancel');},
              child: const Text('cancel',
                style: TextStyle(
                  fontSize: 20,
                ),
              )
          ),
          Center(
            child: Column(
              children: [
                Text('Your Daily',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold
                  ),
                ),
                Text('Move Goal',
                  style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold
                  ),
                ),

              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 28.0),
            child: Text('Set a distance goal based how will you be active to achieve',
              maxLines: 2,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 25
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 40, bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(onPressed: (){downPressed();}, icon: Icon(Icons.remove_circle)),
                Text('${f.format(goalInMeter)}',
                  style: TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.bold
                  ),
                ),
                IconButton(onPressed: (){upPressed();}, icon: Icon(Icons.add_circle)),
              ],
            ),
          ),
          Center(
            child: Text('METERS/DAY',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: deviceHeight/10),
            child: Center(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  backgroundColor: MAIN_COLOR,
                  fixedSize: Size(deviceWidth / 1.6, 50),
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))
                  ),
                ),
                  onPressed: () async{
                    String? session = await storage.read(key: "session");
                    List<String> split = session!.split(',,');
                    var response = await http.put(Uri.parse(baseUrl + "/change-goal"),
                        headers: {
                          'point_runner_token' : split[2],
                        },
                        body: {
                          'goal' : goalInMeter.toString(),
                        }
                    );
                    var statusCode = response.statusCode;
                    if(statusCode != 200){
                      var body = json.decode(utf8.decode(response.bodyBytes));
                      ErrorMessage error = ErrorMessage.fromJson(body);
                    }else{
                      setState(() {
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: Text('Change Move Goal',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  )
              ),
            ),
          )
        ],
      ),
    );
  }
  
  void upPressed(){
    setState(() {
      goalInMeter += 10;
    });
  }

  void downPressed(){
    setState(() {
      goalInMeter -= 10;
    });
  }

  Widget button({VoidCallback? pressed, required double width, required double height, required String textButton}){
    return OutlinedButton(
      onPressed: pressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: MAIN_COLOR,
        fixedSize: Size(width, height),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10))
        ),
      ),
      child: Text('$textButton',
        style: TextStyle(
            fontSize: 25,
            color: Colors.white
        ),
      ),
    );
  }
}

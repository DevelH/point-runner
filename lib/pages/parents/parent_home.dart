import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sign_in_up/model/Account.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:sign_in_up/model/connection.dart';
import 'package:sign_in_up/model/error.dart';
import 'package:sign_in_up/model/response.dart';
import 'package:sign_in_up/pages/parents/parent_performance_page.dart';
import 'package:sign_in_up/pages/parents/parent_profile_page.dart';
import 'package:sign_in_up/util/userApi.dart';

class ParentHome extends StatefulWidget {
  const ParentHome({super.key});

  @override
  State<ParentHome> createState() => _ParentHomeState();
}

class _ParentHomeState extends State<ParentHome> {
  late double dWidth = MediaQuery.of(context).size.width;
  late double dHeight = MediaQuery.of(context).size.height;
  FlutterSecureStorage storage = FlutterSecureStorage();
  bool _isLoading = true;
  String? pairCode = null;
  List<AccountModel> childen = [];
  late ProfileDto profile;


  @override
  void initState() {
    super.initState();
    getMyChildren();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading? Center(child: const CircularProgressIndicator(color: Colors.blue,)) :
      childen.length == 0 ? Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(child: Column(
            children: [
              Text('You have No Connected Children!'),
              Text('Your Pair Code is $pairCode')
            ],
          )),
        ],
      ) :
      Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 68.0, left: 20, right: 20, bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Select a Child',
                  style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold
                  ),
                ),
                GestureDetector(
                  child: ClipRRect(
                    child: Image.asset(
                      'images/no_profile_img.png',
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ParentProfilePage(profile: profile)));
                  },
                )
              ],
            ),
          ),
          ...childen.map((e) => cardItem(e)).toList()
        ],
      ),
    );



  }

  void getMyChildren() async{
    String? session = await storage.read(key: "session");
    List<String> split = session!.split(',,');
    var response = await http.get(Uri.parse(baseUrl + "/pair-connection-parents"), headers: {
      'point_runner_token' : split[2],
      "Content-Type" : "application/json",
      "Accept" : "application/json",
    });
    var statusCode = response.statusCode;
    if(statusCode != 200){
      var body = json.decode(utf8.decode(response.bodyBytes));
      ErrorMessage error = ErrorMessage.fromJson(body);
      _showErrorSnackBar(error);
    }else{
      var body = json.decode(utf8.decode(response.bodyBytes));
      var list = body.map((data) => Connections.fromJson(data)).toList();

      for(int i = 0; i< list.length; i++){
        childen.add(AccountModel.fromJson(list[i].child));
      }
      setState(() {
        _isLoading = false;
      });
    }
    if(pairCode == null) {
      var myResponse = await http.get(
          Uri.parse(baseUrl + "/profile"), headers: {
        'point_runner_token': split[2],
        "Content-Type": "application/json",
        "Accept": "application/json",
      });
      statusCode = myResponse.statusCode;
      if (statusCode != 200) {
        var body = json.decode(utf8.decode(myResponse.bodyBytes));
        ErrorMessage error = ErrorMessage.fromJson(body);
        _showErrorSnackBar(error);
      } else {
        var body = json.decode(utf8.decode(myResponse.bodyBytes));
        var profileDto = ProfileDto.fromJson(body);
        setState(() {
          pairCode = profileDto.pairedCode;
          profile = profileDto;
        });
        print('${profile.dob}');
      }
    }
  }

  Widget cardItem(AccountModel user){
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 15, 12, 0),
      child: GestureDetector(
        child: Container(
          width: dWidth / 1.1,
          height: 90,
          color: Color.fromRGBO(186, 152, 255, 1.0),
          child: Row(
            children:[
              Padding(
                padding: const EdgeInsets.only(right: 35.0),
                child: ClipRRect(
                  child: Image.asset(
                    'images/no_profile_img.png',
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Text('${user.name}',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold
                ),
              ),

            ]
          ),
        ),
        onTap: (){
          Navigator.push(context, MaterialPageRoute(builder: (context) => ParentPerformancePage(childNo: user.userNo, name: user.name,)));
        },
      ),
    );
  }

  void _showErrorSnackBar(ErrorMessage error){
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message),
          duration: const Duration(seconds: 3),
        )
    );
  }
}

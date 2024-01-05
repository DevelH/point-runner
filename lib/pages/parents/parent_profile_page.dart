import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sign_in_up/model/Account.dart';
import 'package:sign_in_up/model/connection.dart';
import 'package:sign_in_up/model/error.dart';
import 'package:sign_in_up/model/response.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:sign_in_up/pages/initialPage.dart';
import 'package:sign_in_up/util/userApi.dart';

class ParentProfilePage extends StatefulWidget {
  final ProfileDto profile;
  const ParentProfilePage({super.key, required this.profile});

  @override
  State<ParentProfilePage> createState() => _ParentProfilePageState();
}

class _ParentProfilePageState extends State<ParentProfilePage> {
  String? sessionKey = null;
  FlutterSecureStorage storage = FlutterSecureStorage();
  late final deviceWidth = MediaQuery.of(context).size.width;
  late final deviceHeight = MediaQuery.of(context).size.height;
  final MAIN_COLOR = Color.fromRGBO(224, 135, 255, 1.0);
  bool _isLoading = true;
  bool _isPaired = false;
  AccountModel? parent = null;
  late ProfileDto profile = widget.profile;
  late String pairCode;

  @override
  void initState() {
    // TODO: implement initState
    pairInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          header(),
          profileInfo()
        ],
      ),
    );
  }

  Widget header(){
    return Padding(
      padding: const EdgeInsets.only(top: 50.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(onPressed: (){Navigator.pop(context);}, icon: Icon(Icons.arrow_back_ios, size: 30,)),
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text('Parent Profile',
                            style: TextStyle(
                                fontSize: 36,
                                color: MAIN_COLOR,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                          TextButton(
                              onPressed: (){

                              },
                              child: Text('Edit',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20
                                ),
                              )
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 18.0),
                  child: ClipRRect(
                    child: Image.asset(
                      'images/no_profile_img.png',
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget profileInfo(){
    return Padding(
      padding: const EdgeInsets.only(left: 28.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 28.0),
            child: Text('Name',
              style: TextStyle(
                fontSize: 25,
                decoration: TextDecoration.underline
              )
            ),
          ),
          Text('${profile.name}',
              style: TextStyle(
                  fontSize: 25,
              )
          ),
          Padding(
            padding: const EdgeInsets.only(top: 28.0),
            child: Text('Date of Birth',
                style: TextStyle(
                    fontSize: 25,
                    decoration: TextDecoration.underline
                )
            ),
          ),
          Text('${profile.dob}',
              style: TextStyle(
                fontSize: 25,
              )
          ),
          Padding(
            padding: const EdgeInsets.only(top: 28.0),
            child: Text('Sex',
                style: TextStyle(
                    fontSize: 25,
                    decoration: TextDecoration.underline
                )
            ),
          ),
          Text('${profile.gender == true? 'MALE' : 'FEMALE'}',
              style: TextStyle(
                fontSize: 25,
              )
          ),
          Padding(
            padding: const EdgeInsets.only(top: 28.0),
            child: Text('email',
                style: TextStyle(
                    fontSize: 25,
                    decoration: TextDecoration.underline
                )
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 48.0),
            child: Text('${profile.email}',
                style: TextStyle(
                  fontSize: 25,
                )
            ),
          ),
          button(
              width: deviceWidth / 1.2,
              height: 40,
              textButton: 'Log out',
              pressed: () async{
                await storage.delete(key: "session");
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => InitialPage()), (route) => false);
              }
          )
        ],
      ),
    );
  }

  void pairInfo() async{
    String? session = await storage.read(key: "session");
    List<String> split = session!.split(',,');
    sessionKey = split[2];
    var response = await http.get(Uri.parse(baseUrl + "/pair-connection-student"), headers: {
      'point_runner_token' : sessionKey!,
      "Content-Type" : "application/json",
      "Accept" : "application/json",
    });
    var statusCode = response.statusCode;
    if(statusCode != 200){
      var body = json.decode(utf8.decode(response.bodyBytes));
      ErrorMessage error = ErrorMessage.fromJson(body);

    }else{
      var body = json.decode(utf8.decode(response.bodyBytes));
      print(body[0]);
      if(body.length > 0){
        // List<Connections> connects = body.map((e) => Connections.fromJson(e)).toList();
        // setState(() {
        //   parent = AccountModel.fromJson(connects[0].parent);
        // });
        setState(() {
          _isPaired = true;
          _isLoading = false;
        });
      }
      // Connections connections = Connections.fromJson(body);

      // profile = ProfileDto.fromJson(statusResponse.user);

    }
  }

  void pair(String code) async{
    var response = await http.post(Uri.parse(baseUrl + "/pair-connection"), headers: {
        'point_runner_token' : sessionKey!,
      },
      body: {
        'paired_code' : code
      }
    );
    var statusCode = response.statusCode;
    if(statusCode != 200){
      var body = json.decode(utf8.decode(response.bodyBytes));
      ErrorMessage error = ErrorMessage.fromJson(body);
      _showErrorSnackBar(error);
    }else{
      Navigator.pop(context);
    }
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
  void _showErrorSnackBar(ErrorMessage error){
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message),
          duration: const Duration(seconds: 3),
        )
    );
  }
}

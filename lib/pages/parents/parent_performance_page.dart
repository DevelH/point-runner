import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:sign_in_up/model/error.dart';
import 'package:sign_in_up/util/userApi.dart';

class ParentPerformancePage extends StatefulWidget {

  final int childNo;
  final String name;

  const ParentPerformancePage({super.key, required this.childNo, required this.name});

  @override
  State<ParentPerformancePage> createState() => _ParentPerformancePageState();
}

class _ParentPerformancePageState extends State<ParentPerformancePage> {
  late Map<String, dynamic> histories;
  FlutterSecureStorage storage = FlutterSecureStorage();
  bool _isLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    _loadHistories(widget.childNo);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading ? const Center(
        child: const CircularProgressIndicator(
          color: Colors.blue,
        ),
      ): historyToListView(histories),
    );
  }

  void _loadHistories(int childNo) async {
    String? session = await storage.read(key: "session");
    List<String> split = session!.split(',,');
    Map<String, String> queryParam = {
      'child_no' : childNo.toString()
    };
    var response = await http.get(Uri.parse(baseUrl + "/route-child-history").replace(queryParameters: queryParam),
        headers: {
          'point_runner_token' : split[2],
          "Content-Type" : "application/json",
          "Accept" : "application/json",
        }
    );
    var statusCode = response.statusCode;
    if(statusCode != 200){
      var body = json.decode(utf8.decode(response.bodyBytes));
      ErrorMessage error = ErrorMessage.fromJson(body);
      print('${error.message}');
    }else{
      setState(() {
        histories = json.decode(response.body);
        _isLoading = false;
      });
    }

    print(histories.keys);
  }

  Widget historyToListView(Map<String, dynamic> history){
    List<Widget> items = [];
    history = Map.fromEntries(history.entries.toList()..sort((e1, e2) => e2.key.compareTo(e1.key)));
    history.forEach((key, value) {
      items.add(Padding(
        padding: const EdgeInsets.only(left: 38.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(key,
              style: TextStyle(
                fontSize: 20,
                decoration: TextDecoration.underline
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 14.0, bottom: 25),
              child: Text('Total $value Km'.toString(),
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            )
          ],
        ),
      ));
    });
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 65, 0, 0),
          child: Row(
            children: [
              IconButton(
                onPressed: (){
                  Navigator.pop(context);
                },
                icon: Icon(Icons.arrow_back, size: 30,),
                color: Colors.black,

              ),
              Padding(
                padding: const EdgeInsets.only(right: 18.0),
                child: ClipRRect(
                  child: Image.asset(
                    'images/no_profile_img.png',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Text('${widget.name}',
                style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            children: items,
          ),
        ),
      ],
    );
  }

}

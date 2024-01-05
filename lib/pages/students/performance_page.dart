import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:sign_in_up/model/error.dart';
import 'package:sign_in_up/util/userApi.dart';

class PerformancePage extends StatefulWidget {
  const PerformancePage({super.key});

  @override
  State<PerformancePage> createState() => _PerformancePageState();
}

class _PerformancePageState extends State<PerformancePage> {
  late Map<String, dynamic> histories;
  FlutterSecureStorage storage = FlutterSecureStorage();
  bool _isLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    _loadHistories();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading ? const Center(
      child: const CircularProgressIndicator(
        color: Colors.blue,
      ),
    ): historyToListView(histories);
  }

  void _loadHistories() async {
    String? session = await storage.read(key: "session");
    List<String> split = session!.split(',,');
    var response = await http.get(Uri.parse(baseUrl + "/route-history"),
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
          padding: const EdgeInsets.only(top: 38.0),
          child: Text('Activity History',
            style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold
            ),
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

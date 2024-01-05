import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sign_in_up/model/achievements.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:sign_in_up/model/error.dart';
import 'package:sign_in_up/model/response.dart';
import 'package:sign_in_up/pages/profile_page.dart';
import 'package:sign_in_up/pages/students/goal_setting_page.dart';
import 'package:sign_in_up/util/userApi.dart';


class StudStatusPage extends StatefulWidget {
  const StudStatusPage({super.key});

  @override
  State<StudStatusPage> createState() => _StudStatusPageState();
}

class _StudStatusPageState extends State<StudStatusPage> with AutomaticKeepAliveClientMixin{
  final storage = FlutterSecureStorage();
  bool _isLoading = true;
  String name = 'Mr. kim';
  int goal = 1;
  double curWalking = 0;
  String? profileImg = null;
  List<Achievements> achievements = <Achievements>[];
  late ProfileDto profile;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getStatus();
  }


  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final deviceHeight = MediaQuery.of(context).size.height;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              child: Text('Welcome $name',
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                  overflow: TextOverflow.ellipsis,

                ),
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              child: Container(
                child: profileImg == null ?
                ClipRRect(
                  child: Image.asset(
                    'images/no_profile_img.png',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ) :
                ClipRRect(
                  child: Image.network(
                    width: 20,
                    height: 20,
                    '$profileImg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => StudentProfilePage(profile: profile)));
              },
            )
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 30, bottom: 50),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                child: Container(
                  child: CustomPaint(
                    size: Size(150, 150),
                    painter: PieChart(goal: goal.toDouble(), curWalking: curWalking),
                  ),
                ),
                onTap: (){
                  showDialog(
                      context: context,
                      barrierDismissible: true, // 바깥 영역 터치시 닫을지 여부
                      builder: (BuildContext context) {
                        return AlertDialog(
                          content: Container(
                            width: deviceWidth / 1.1,
                            child: GoalSettingPage(goal: goal)
                          ),
                          insetPadding: const  EdgeInsets.fromLTRB(0, 80, 0, 80),
                        );
                      }
                  ).then((value){
                    getStatus();
                  });
                },
              ),
              Container(
                width: 200,
                height: 150,
                color: Colors.grey,
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Daily Distance: ',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(curWalking < 1000 ? '$curWalking m' : '${(curWalking/10).round()/100} km',
                          style: TextStyle(
                              fontSize: 15,
                          ),
                        ),
                      ),
                      // Text('Daily Steps: '),
                      // Text('$curWalking steps')
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.amber)
          ),
          width: deviceWidth / 1.1,
          height: 180,
          child: Container(
            color: Color.fromRGBO(255, 254, 163, 1.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Achievements',
                        style: TextStyle(
                          fontSize: 25
                        ),
                      ),
                      GestureDetector(
                        child: Text('See more'),
                        // onTap: ,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 15, 20, 10),
                  child: trophies(achievements.length, deviceWidth / 1.21),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 30),
          child: Container(
            decoration: BoxDecoration(
                color: Color.fromRGBO(101, 86, 164, 1.0),
                borderRadius: BorderRadius.all(Radius.circular(20))
            ),
            width: deviceWidth / 1.3,
            height: 230,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text('Mission 2023',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 35
                  ),
                ),
                Image.asset('images/app_logo.png',
                  width: deviceWidth / 3.5,
                  color: Colors.white,
                ),
                Text('Run 3000 Km',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20
                  ),
                ),
              ],
            ),
          ),
        ),
      ],

    );
  }

  void getStatus() async{
    String? session = await storage.read(key: "session");
    List<String> split = session!.split(',,');
    var response = await http.get(Uri.parse(baseUrl + "/my-status"), headers: {
      'point_runner_token' : split[2],
      "Content-Type" : "application/json",
      "Accept" : "application/json",
    });
    var statusCode = response.statusCode;
    if(statusCode != 200){
      var body = json.decode(utf8.decode(response.bodyBytes));
      ErrorMessage error = ErrorMessage.fromJson(body);
    }else{
      var body = json.decode(utf8.decode(response.bodyBytes));
      StatusResponse statusResponse = StatusResponse.fromJson(body);
      print('${statusResponse.user}');
      profile = ProfileDto.fromJson(statusResponse.user);
      setState(() {
        // profileImg = profile.
        name = profile.name;
        goal = statusResponse.goal;
        curWalking = statusResponse.todayWalked;
        achievements = statusResponse.achievements.map((e) => Achievements.fromJson(e)).toList();

      });
    }
  }

  Widget trophies(int numTrophy, double width){
    return Row(
      children: [
        for(int i = 0; i < numTrophy; i++)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              'images/trophy.png',
              width: width / 5,
              fit: BoxFit.cover,
            ),
          ),
      ],
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

}

class PieChart extends CustomPainter {
  final double curWalking;
  final double goal;
  final double textScaleFactor;
  final MAIN_COLOR = Color.fromRGBO(224, 135, 255, 1.0);

  PieChart({required this.curWalking, required this.goal,this.textScaleFactor = 1.0});

  @override
  void paint(Canvas canvas, Size size) {
    // 화면에 그릴 paint 정의
    Paint paint = Paint()
      ..color = Colors.orange
      ..strokeWidth = 12.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // 원의 반지름을 구한다. 선의 굵이에 영향을 받지 않게 보정
    double radius = min(size.width / 2 - paint.strokeWidth / 2,
        size.height / 2 - paint.strokeWidth / 2);

    // 그래프가 가운데로 그려지도록 좌표를 정한다.
    Offset center = Offset(size.width / 2, size.height / 2);

    // 원 그래프를 그린다.
    canvas.drawCircle(center, radius, paint);

    // 호(arc)의 각도를 정한다. 정해진 각도만큼만 그린다.
    double arcAngle = 2 * pi * (curWalking / goal);

    // 호를 그릴때 색 변경
    paint..color = MAIN_COLOR;

    // 호(arc)를 그린다.
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -pi / 2,
        arcAngle, false, paint);

    // 텍스트를 화면에 표시한다.
    drawText(canvas, size, '${((curWalking/goal) * 10000).toInt() / 100}%');
  }

  // 원의 중앙에 텍스트를 적는다.
  void drawText(Canvas canvas, Size size, String text) {
    double fontSize = getFontSize(size, text);

    TextSpan sp = TextSpan(
        style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.black),
        text: text);

    TextPainter tp = TextPainter(text: sp, textDirection: TextDirection.ltr);

    // 필수로 호출해야 한다. 텍스트 페인터에 그려질 텍스트의 크기와 방향을 결정한다.
    tp.layout();

    double dx = size.width / 2 - tp.width / 2;
    double dy = size.height / 2 - tp.height / 2;

    Offset offset = Offset(dx, dy);
    tp.paint(canvas, offset);
  }

  // 화면 크기에 비례하도록 텍스트 폰트 크기를 정한다.
  double getFontSize(Size size, String text) {
    return size.width / text.length * textScaleFactor;
  }

  // 다르면 다시 그리도록
  @override
  bool shouldRepaint(PieChart old) {
    return old.curWalking != curWalking;
  }



}
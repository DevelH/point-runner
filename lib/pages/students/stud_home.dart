import 'package:flutter/material.dart';
import 'package:sign_in_up/pages/students/map_page.dart';
import 'package:sign_in_up/pages/students/performance_page.dart';
import 'package:sign_in_up/pages/students/stud_status_page.dart';

class StudentHomePage extends StatefulWidget {
  const StudentHomePage({super.key});

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  int _bottomIdx = 0;

  static const TextStyle optionStyle = TextStyle(
      fontSize: 30,
      fontWeight: FontWeight.bold
  );

  final List<Widget> _widgetOptions = <Widget>[
    StudStatusPage(),
    StatusPage(),
    StatusPage(),
  ];

  void _onItemTapped(int index) { // 탭을 클릭했을떄 지정한 페이지로 이동
    setState(() {
      _bottomIdx = index;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 60.0),
        child: IndexedStack(
          index: _bottomIdx,
          children: [
            StudStatusPage(),
            Navigator(
              onGenerateRoute: (routeSettings){
                return MaterialPageRoute(builder: (context) => StatusPage());
              },
            ),
            PerformancePage(),
          ],
        ),
      ),
      
      bottomNavigationBar: BottomNavigationBar(
        items: const<BottomNavigationBarItem>[
          BottomNavigationBarItem(label: 'Home', icon: Icon(Icons.home)),
          BottomNavigationBarItem(label: 'Start', icon: Icon(Icons.play_arrow)),
          BottomNavigationBarItem(label: 'Performance', icon: Icon(Icons.insert_chart)),
        ],
        currentIndex: _bottomIdx,
        selectedItemColor: Colors.black,
        onTap: _onItemTapped,
      ),
    );
  }
}



class StatusPage extends StatefulWidget {
  const StatusPage({super.key});

  @override
  State<StatusPage> createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> {
  @override
  Widget build(BuildContext context) {
    return MapPage();
  }
}

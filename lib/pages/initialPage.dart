import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class InitialPage extends StatefulWidget {
  const InitialPage({super.key});

  @override
  State<InitialPage> createState() => _InitialPageState();
}

class _InitialPageState extends State<InitialPage> {
  final storage = FlutterSecureStorage();


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // storage.delete(key: 'session');
    _asyncMethod();
  }

  @override
  Widget build(BuildContext context) {
    final MainColor = Colors.black;
    final dWidth = MediaQuery.of(context).size.width;
    final dHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: MainColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(0, dHeight * 12 / 100, 0, 0),
            child: Center(child: Image(image: AssetImage('images/app_logo.png'), width: dWidth/1.5, color: Colors.white,)),
          ),
          Padding(
            padding: EdgeInsets.all(dHeight * 12 / 100),
            child: Column(
              children: [
                OutlinedButton(
                  onPressed: (){
                    Navigator.pushNamed(context, '/login');
                  },
                  child: Text('Login',
                    style: TextStyle(
                      fontSize: 27 ,
                      color: MainColor
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    fixedSize: Size(dWidth * 0.6, dHeight / 16),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))
                    )
                  ),
                ),
                OutlinedButton(
                  onPressed: (){
                    Navigator.pushNamed(context, '/sign-up');
                  },
                  child: Text('SignUp',
                    style: TextStyle(
                        fontSize: 27 ,
                        color: MainColor
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      fixedSize: Size(dWidth * 0.6, dHeight / 16),
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10))
                      )
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _asyncMethod() async {
    //read 함수를 통하여 key값에 맞는 정보를 불러오게 됩니다. 이때 불러오는 결과의 타입은 String 타입임을 기억해야 합니다.
    //(데이터가 없을때는 null을 반환을 합니다.)
    String? session = await storage.read(key: "session");
    if(session != null){
      List<String> split = session!.split(',,');
      print(split);
      if(split[3] == 'STUDENT'){
        Navigator.pushNamed(context, '/student-home');
      }else{
        Navigator.pushNamed(context, '/parent-home');

      }
    }

    // //user의 정보가 있다면 바로 로그아웃 페이지로 넝어가게 합니다.
    // if (userInfo != null) {
    //   Navigator.pushReplacement(
    //       context,
    //       CupertinoPageRoute(
    //           builder: (context) => LogOutPage(
    //             id: userInfo.split(" ")[1],
    //             pass: userInfo.split(" ")[3],
    //           )));
    // }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:sign_in_up/pages/initialPage.dart';
import 'package:sign_in_up/pages/loginPage.dart';
import 'package:sign_in_up/pages/parents/parent_home.dart';
import 'package:sign_in_up/pages/signUpPage.dart';
import 'package:sign_in_up/pages/students/map_page.dart';
import 'package:sign_in_up/pages/students/stud_home.dart';

void main() {
  runApp(
    MaterialApp(
      //home: const SignUpPage()
      initialRoute: '/init',
      routes: {
        '/init': (context) => InitialPage(),
        '/login': (context) => LoginPage(),
        '/sign-up': (context) => SignUpPage(),
        '/student-home': (context) => StudentHomePage(),
        '/parent-home': (context) => ParentHome(),
      },
    ),
  );
}




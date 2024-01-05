import 'package:flutter/material.dart';

class ChangeGoalPage extends StatefulWidget {
  const ChangeGoalPage({super.key});

  @override
  State<ChangeGoalPage> createState() => _ChangeGoalPageState();
}

class _ChangeGoalPageState extends State<ChangeGoalPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          GestureDetector(
            child: Text('Cancel',

            ),
            onTap: (){
              Navigator.pop(context);
            },
          ),

        ],
      ),
    );
  }
}

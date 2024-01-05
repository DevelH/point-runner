import 'dart:convert';

import 'package:custom_radio_grouped_button/custom_radio_grouped_button.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:sign_in_up/model/Account.dart';
import 'package:sign_in_up/model/error.dart';
import 'package:sign_in_up/util/userApi.dart';
import 'dart:async';

import 'package:sign_in_up/util/validate.dart';

class SignUpPage extends StatefulWidget {

  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  String _accountType = 'student';
  String _gender = 'male';


  FocusNode _emailFocus = new FocusNode();
  FocusNode _passwordFocus = new FocusNode();
  FocusNode _rePasswordFocus = new FocusNode();
  FocusNode _nameFocus = new FocusNode();
  FocusNode _codeFocus = new FocusNode();
  String _selectedDate= '';
  String _selectedDateForBE= '';

  //controller
  final _verificationCodeController = TextEditingController();


  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  final _rePasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();

  late final deviceWidth = MediaQuery.of(context).size.width;
  late final deviceHeight = MediaQuery.of(context).size.height;

  bool _visibility = false;
  bool _isVerified = false;
  bool _isDone = true;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  GlobalKey<FormState> formKey_email = GlobalKey<FormState>();

  final MAIN_COLOR = Colors.purple;
  late double dWidth = MediaQuery.of(context).size.width;
  late double dHeight = MediaQuery.of(context).size.height;


  int time = 180;
  late String _timer = secToTimer(time);
  Timer? timer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: (){
            Navigator.pop(context);
          }, icon: Icon(Icons.arrow_back, size: 30,),
          color: MAIN_COLOR,
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: (dHeight * 2) / 100, bottom: (dHeight) / 70),
            child: Center(child: Image(color: MAIN_COLOR, image: AssetImage('images/app_logo.png'), width: dWidth / 5,)),
          ),
          _selectAccountType(),
          Column(
            children: [
              Form(
                key: formKey_email,
                child: Column(
                  children: [
                    _showEmailInput(),
                  ],
                ),
              ),
              Form(
                key: formKey,
                child: Column(
                  children: [
                    _showFirstNameInput(),
                    _selectGender(),
                    _showBirthSelect(context),
                    _showPasswordInput(),
                    _showRePasswordInput(),
                  ],
                )
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 18.0),
            child: OutlinedButton(
                onPressed: ()async{
                  var bool1 = formKey_email.currentState!.validate();
                  var bool2 = formKey.currentState!.validate();
                  if(bool1 && bool2){
                    AccountModel user = AccountModel(user_type: _accountType, email: _emailController.text, admin_name: _nameController.text, password: _passwordController.text, birth_day: _selectedDateForBE + ' 00:00:00', gender: _gender);
                    print('$user');
                    var response = await http.post(Uri.parse(baseUrl + '/joinus'),
                      body: json.encode(user.toJson()),
                    );
                    var statusCode = response.statusCode;
                    var body = json.decode(utf8.decode(response.bodyBytes));
                    if(statusCode != 200){
                      ErrorMessage error = ErrorMessage.fromJson(body);
                      _showErrorSnackBar(error);
                      setState(() {
                        _isVerified = false;
                        _visibility = false;
                      });
                    }else{
                      //todo 회원가입버튼을 눌렀을때 가입성공시 로그인 페이지로 이동
                      Navigator.pushNamed(context, '/login');
                    }
                  }
                },
                child: Text("Sign Up",
                  style: TextStyle(
                    fontSize: 20,
                    color: MAIN_COLOR
                  ),
                )
            ),
          ),
        ],
      ),
    );
  }

  Widget _showPasswordInput(){
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: Column(
        children: [
          Padding(padding: EdgeInsets.fromLTRB(50, 0, 50, 0),
            child: TextFormField(
              focusNode: _passwordFocus,
              keyboardType: TextInputType.visiblePassword,
              obscureText: true,
              decoration: _textFormDecoration('패스워드', '특수문자, 대소문자, 숫자 포함 8자 이상 15자 이내로 입력하세요.'),
              validator: (value) => CheckValidate().validatePassword(_passwordFocus, value!),
              controller: _passwordController,
            ),
          )
        ],
      ),
    );
  }

  Widget _showRePasswordInput(){
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
      child: Column(
        children: [
          Padding(padding: EdgeInsets.fromLTRB(50, 0, 50, 0),
            child: TextFormField(
              focusNode: _rePasswordFocus,
              keyboardType: TextInputType.visiblePassword,
              obscureText: true,
              decoration: _textFormDecoration('패스워드 재입력', '위 패스워드와 일치하게 입력해주세요.'),
              validator: (value) => CheckValidate().validateRePassword(_passwordFocus, value!, _passwordController.text),
            ),
          )
        ],
      ),
    );
  }

  Widget _showFirstNameInput(){
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
      child: Column(
        children: [
          Padding(padding: EdgeInsets.fromLTRB(50, 0, 50, 0),
            child: TextFormField(
              focusNode: _nameFocus,
              keyboardType: TextInputType.text,
              decoration: _textFormDecoration('이름', '이름을 입력해주세요.'),
              validator: (value) => CheckValidate().validateFirstName(_nameFocus, value!),
              controller: _nameController,
            ),
          )
        ],
      ),
    );
  }


  Widget _showEmailInput(){
    return Column(
      children: [
        Padding(padding: EdgeInsets.fromLTRB(50, 20, 50, 0),
            child: Row(
              children: [
                SizedBox(
                  width: 240,
                  child: TextFormField(
                    enabled: !_isVerified,
                    keyboardType: TextInputType.emailAddress,
                    focusNode: _emailFocus,
                    decoration: _textFormDecoration('이메일', '이메일을 입력해주세요'),
                    controller: _emailController,
                    validator: (value) => CheckValidate().validateEmail(_emailFocus, value!),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                  child: !_isVerified ? OutlinedButton(
                    onPressed: _isDone ? () async {
                      var validate = formKey_email.currentState!.validate();
                      if(validate){
                        if(_visibility){
                          resetCountDown();
                        }
                        _sendEmailVerification();
                      }
                    } : null,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: _isDone ? Colors.white : Colors.grey,
                      fixedSize: Size(deviceWidth * 1.8 / 10, deviceHeight/26),
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10))
                      ),
                    ),
                    child: Text(_visibility ? "resend code" : "send code",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: MAIN_COLOR,
                      ),
                    ),
                  ) : Container(
                    child: Text("verified!",
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.white
                      ),
                    ),),),
              ],
            )),
        Visibility(
          visible: _visibility && !_isVerified,
          child: Padding(padding: EdgeInsets.fromLTRB(50, 20, 50, 0),
              child: Row(
                children: [
                  SizedBox(
                    width: 240,
                    child: TextFormField(
                      keyboardType: TextInputType.text,
                      focusNode: _codeFocus,
                      decoration: _textFormDecoration('인증 코드', '인증 코드를 입력해주세요'),
                      controller: _verificationCodeController,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                    child: OutlinedButton(
                      onPressed: _isVerified || time == 0 ? null : () async {
                        var response = await http.put(Uri.parse(baseUrl + "/confirm/email-validation"),
                          body: {
                            'email' : _emailController.text,
                            'code' : _verificationCodeController.text,
                          },
                        );
                        var statusCode = response.statusCode;
                        if(statusCode != 200){
                          var body = json.decode(utf8.decode(response.bodyBytes));
                          ErrorMessage error = ErrorMessage.fromJson(body);
                          _showErrorSnackBar(error);
                        }else{
                          show();
                          stopCountDown();
                          setState(() {
                            _isVerified = true;
                          });
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: _isVerified || time == 0 ? Colors.grey : Colors.white,
                        fixedSize: Size(deviceWidth * 1.8 / 10, deviceHeight/26),
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10))
                        ),
                      ),
                      child: Text(_timer,
                        style: TextStyle(
                            fontSize: 15,
                            color: MAIN_COLOR
                        ),
                      ),
                    ),
                  ),
                ],
              )),
        ),
      ],
    );
  }


  InputDecoration _textFormDecoration(hintText, helperText) {
    return InputDecoration(
      contentPadding: EdgeInsets.fromLTRB(0, 16, 0, 0),
      hintText: hintText,
      helperText: helperText
    );
  }


  void countDown(){
    timer?.cancel();
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if(time > 0){
        setState(() {
          time--;
          _timer = secToTimer(time);
        });
      }
    });
  }

  void stopCountDown(){
    timer?.cancel();
  }

  void resetTimer(){
    setState(() {
      time = 180;
      _timer = secToTimer(time);
    });
  }


  String secToTimer(int second){
    int min = (second / 60).toInt();
    second = second % 60;
    return '$min : ${second.toString().padLeft(2, "0")}';
  }


  Widget _selectAccountType(){
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(),
            child: CustomRadioButton(
                width: dWidth / 2.5,
                height: 45,
                defaultSelected: _accountType,
                buttonTextStyle: ButtonTextStyle(
                  textStyle: TextStyle(
                    fontSize: 17
                  )
                ),
                buttonLables: ['STUDENT', 'PARENTS'],
                buttonValues: ['student', 'parents'],
                radioButtonValue: (val){
                  setState(() {
                    _accountType = val;
                  });
                },
                unSelectedColor: Colors.white,
                selectedColor: MAIN_COLOR,
            ),
          )
        ],
      ),
    );
  }

  Widget _selectGender(){
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(),
            child: CustomRadioButton(
                width: dWidth / 2.5,
                height: 30,
                defaultSelected: _gender,
                buttonTextStyle: ButtonTextStyle(
                  textStyle: TextStyle(
                    fontSize: 17
                  )
                ),
                buttonLables: ['MALE', 'FEMALE'],
                buttonValues: ['male', 'female'],
                radioButtonValue: (val){
                  setState(() {
                    _gender = val;
                  });
                },
                unSelectedColor: Colors.white,
                selectedColor: MAIN_COLOR,
            ),
          )
        ],
      ),
    );
  }

  void hide(){
    setState(() {
      _visibility = false;
    });
  }
  void show(){
    setState(() {
      _visibility = true;
    });
  }

  void resetCountDown(){
    setState(() {
      time = 180;
      _timer = secToTimer(time);
    });
  }


  void _showErrorSnackBar(ErrorMessage error){
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message),
          duration: const Duration(seconds: 3),
        )
    );
  }

  void _sendEmailVerification() async {
    setState(() {
      _isDone = false;
    });
    print(_emailController.text);
    var response = await http.put(Uri.parse(baseUrl + "/request/email-validation"),
      body: {
        'email' : _emailController.text
      },
    );
    var statusCode = response.statusCode;
    if(statusCode != 200){
      var body = json.decode(utf8.decode(response.bodyBytes));
      ErrorMessage error = ErrorMessage.fromJson(body);
      _showErrorSnackBar(error);
    }else{
      show();
      countDown();
    }
    setState(() {
      _isDone = true;
    });
  }

  Future _selectDate(BuildContext context) async {
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (selected != null) {
      setState(() {
        _selectedDate = (DateFormat.yMMMd()).format(selected);
        _selectedDateForBE = DateFormat('yyyy-MM-dd').format(selected);
        print('$_selectedDateForBE');
      });
    }
  }

  Widget _showBirthSelect(BuildContext context){
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Date of Birth : ',
          style: TextStyle(
            fontSize: 21
          ),
        ),
        Text(
          _selectedDate,
          style: TextStyle(fontSize: 21),
        ),
        IconButton(
          icon: Icon(Icons.date_range),
          onPressed: () => _selectDate(context),
        )
      ],
    );
  }

}

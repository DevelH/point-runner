
import 'package:flutter/material.dart';

class CheckValidate{
  String? validateEmail(FocusNode fNode, String value){
    if(value.isEmpty){
      fNode.requestFocus();
      return '이메일을 입력하세요';
    }else{
      RegExp regExp = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
      if(!regExp.hasMatch(value)){
        fNode.requestFocus();
        return '잘못된 이메일 형태입니다.';
      }else{
        return null;
      }
    }
  }

  String? validatePassword(FocusNode fNode, String value){
    if(value.isEmpty){
      fNode.requestFocus();
      return '비밀번호를 입력하세요';
    }else{
      RegExp regExp = RegExp(r"^(?=.*[A-Za-z])(?=.*\d)(?=.*[$@$!%*#?~^<>,.&+=])[A-Za-z\d$@$!%*#?~^<>,.&+=]{8,15}$");
      if(!regExp.hasMatch(value)){
        fNode.requestFocus();
        return '특수문자, 대소문자, 숫자 포함 8자 이상 15자 이내로 입력하세요.';
      }else{
        return null;
      }
    }
  }

  String? validateRePassword(FocusNode fNode, String value, String password){
    if(value.isEmpty){
      fNode.requestFocus();
      return '비밀번호와 같이 입력해주세요.';
    }else if(password != value){
      fNode.requestFocus();
      return '패스워드와 일치하지 않습니다.';
    }
    return null;
  }

  String? validateFirstName(FocusNode fNode, String value){
    if(value.isEmpty){
      fNode.requestFocus();
      return '이름을 입력해주세요.';
    }
    return null;
  }

  String? validateLastName(FocusNode fNode, String value){
    if(value.isEmpty){
      fNode.requestFocus();
      return '성을 입력해주세요.';
    }
    return null;
  }

  String? validateVeriCode(FocusNode focusNode, String value){
    if(value.isEmpty){
      focusNode.requestFocus();
      return '인증번호를 입력해주세요.';
    }else{
      if(value != '1234'){
        return '인증번호가 일치하지 않습니다.';
      }
    }
    return null;
  }


}
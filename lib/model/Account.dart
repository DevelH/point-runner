import 'dart:convert';

import 'package:crypto/crypto.dart';

class AccountModel {
  var email;
  var admin_name;
  var name;
  var password;
  var gender;
  var birth_day;
  var user_type;
  var pairCode;
  var userNo;


  AccountModel({
    required this.email,
    required this.admin_name,
    required this.password,
    required this.user_type,
    required this.birth_day,
    required this.gender,
    this.pairCode,
    this.name,
    this.userNo
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      user_type: json["user_type"],
      email: json["email"],
      admin_name: json["admin_name"],
      name: json["name"],
      password: json["password"],
      birth_day: json["birth"],
      gender: json["gender"],
      pairCode: json["pairing_code"],
      userNo: json['user_no']
    );
  }

  Map<String, dynamic> toJson(){
    return {
      'user_type' : user_type,
      'email' : email,
      'name' : admin_name,
      'password' : sha256.convert(utf8.encode(password)).toString(),
      'birth' : birth_day,
      'gender' : gender,
    };
  }

}


class PostResponse {
  dynamic user_name;
  dynamic email;
  dynamic session_key;
  dynamic user_type;


  PostResponse({required this.user_name, required this.email, required this.session_key, required this.user_type});

  factory PostResponse.fromJson(Map<String, dynamic> json) {
    return PostResponse(
      user_name: json["user_name"],
      email: json["email"],
      session_key: json["session_key"],
      user_type: json["user_type"]
    );
  }

  @override
  String toString() {
    // TODO: implement toString
    return '$email,,$user_name,,$session_key,,$user_type';
  }
}

class Account {
  dynamic userNo;
  dynamic email;
  dynamic name;
  dynamic profile;
  dynamic session_key;


  Account({
    required this.userNo,
    required this.email,
    required this.name,
    required this.profile,
    required this.session_key,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      userNo: json["user_no"],
      email: json["email"],
      name: json["name"],
      profile: json["profile"],
      session_key: json["session_key"],
    );
  }

  Map<String, dynamic> toJson(){
    return {
      'email' : email,
      'name' : name,
      'profile' : profile,
    };
  }

  @override
  String toString() {
    // TODO: implement toString
    return '$email,,$name,,$session_key,,$profile,,$userNo';
  }
}

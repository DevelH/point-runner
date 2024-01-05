class StatusResponse {
  dynamic goal;
  dynamic todayWalked;
  List<dynamic> achievements;
  dynamic user;


  StatusResponse({required this.goal, required this.todayWalked, required this.achievements, required this.user
  });

  factory StatusResponse.fromJson(Map<String, dynamic> json) {
    return StatusResponse(
        goal: json["goal"],
        todayWalked: json["today_walked"],
        achievements: json["achievements"],
        user: json["user"],
    );
  }


}



class ProfileDto {
  dynamic name;
  dynamic dob;
  dynamic gender;
  dynamic email;
  dynamic pairedCode;
  dynamic profile;
  // dynamic p


  ProfileDto({required this.name, required this.dob, required this.gender, required this.email, this.pairedCode, required this.profile
  });

  factory ProfileDto.fromJson(Map<String, dynamic> json) {
    return ProfileDto(
      name: json["name"],
      dob: json["birth"],
      gender: json["gender"],
      email: json["email"],
      profile: json["profile"],
      pairedCode: json['paired_code'],
    );
  }


}

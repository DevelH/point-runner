class Achievements {
  var name;
  var description;


  Achievements({
    required this.name,
    required this.description,
  });

  factory Achievements.fromJson(Map<String, dynamic> json) {
    return Achievements(
      name: json["name"],
      description: json["description"],
    );
  }

  Map<String, dynamic> toJson(){
    return {
      'name' : name,
      'description' : description,
    };
  }

}

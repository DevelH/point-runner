class Connections{
  dynamic parent;
  dynamic child;

  Connections({required this.child, required this.parent});

  factory Connections.fromJson(Map<String, dynamic> json){
    return Connections(
      parent: json['parent'],
      child: json['child']
    );
  }

}
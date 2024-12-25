
class Users {
  final int? usrId;
  final String usrName;
  final String usrPassword;

  Users({
    this.usrId,
    required this.usrName,
    required this.usrPassword,
  });

  // Factory constructor to create a Users instance from a map
  factory Users.fromMap(Map<String, dynamic> json) => Users(
    usrId: json["usrId"],
    usrName: json["usrName"],
    usrPassword: json["usrPassword"],
  );

  // Method to convert Users instance to a map
  Map<String, dynamic> toMap() => {
    "usrId": usrId,
    "usrName": usrName,
    "usrPassword": usrPassword,
  };
}

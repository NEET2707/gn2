class TblClient {
  int clientId = 0;
  String name = '';
  String code = '';
  String emailId = '';
  String contactNo = '';
  String address = '';
  double? tax;
  double? remainingAmount;

  TblClient();

  TblClient.withId(int clientId, String name, String code, String emailId, String contactNo, String address) {
    this.clientId = clientId;
    this.name = name;
    this.code = code;
    this.emailId = emailId;
    this.contactNo = contactNo;
    this.address = address;
  }

  TblClient.withoutId(String name, String code, String emailId, String contactNo, String address) {
    this.name = name;
    this.code = code;
    this.emailId = emailId;
    this.contactNo = contactNo;
    this.address = address;
  }

  TblClient.withRemainingAmount(int clientId, String name, String emailId, String contactNo, double remainingAmount) {
    this.clientId = clientId;
    this.name = name;
    this.emailId = emailId;
    this.contactNo = contactNo;
    this.remainingAmount = remainingAmount;
  }

  Map<String, dynamic> toMap() {
    return {
      'clientId': clientId,
      'name': name,
      'code': code,
      'emailId': emailId,
      'contactNo': contactNo,
      'address': address,
    };
  }

  factory TblClient.fromMap(Map<String, dynamic> map) {
    return TblClient.withId(
      map['clientId'],
      map['name'],
      map['code'],
      map['emailId'],
      map['contactNo'],
      map['address'],
    );
  }

  // Your getters and setters...

  String get getIsCreditText {
    if (remainingAmount != null) {
      if (remainingAmount! > 0)
        return 'Cr';
      else if (remainingAmount! < 0)
        return 'Dr';
    }
    return '';
  }
}

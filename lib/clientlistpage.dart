import 'package:flutter/material.dart';
import 'package:gn_account_manager/dashboard.dart';

import 'database_helper.dart';

class ClientListPage extends StatefulWidget {
  @override
  State<ClientListPage> createState() => _ClientListPageState();
}

class _ClientListPageState extends State<ClientListPage> {
  late Future<List<Map<String, dynamic>>> _clientData;

  final TextEditingController _clientNameController = TextEditingController();
  final TextEditingController _clientCodeController = TextEditingController();
  final TextEditingController _clientEmailController = TextEditingController();
  final TextEditingController _contactNoController = TextEditingController();
  final TextEditingController _clientAddressController = TextEditingController();
  final TextEditingController _dueBalanceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _clientData = AppDatabaseHelper().displayDataClient();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(
          'Client List',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFF5C9EAD),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Form Section
              Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'Fill The All Details',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5C9EAD),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildInputField('First Name', _clientNameController),
                    _buildInputField('Client code', _clientCodeController),
                    _buildInputField('Email Address', _clientEmailController),
                    _buildInputField('Contact Number', _contactNoController),
                    _buildInputField('Address', _clientAddressController),
                    _buildInputField('Due Balance', _dueBalanceController, keyboardType: TextInputType.number),
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          // Get values from text controllers
                          String clientName = _clientNameController.text;
                          String clientCode = _clientCodeController.text;
                          String clientEmail = _clientEmailController.text;
                          String contactNo = _contactNoController.text;
                          String clientAddress = _clientAddressController.text;
                          double dueBalance = double.tryParse(_dueBalanceController.text) ?? 0.0;

                          // Insert data into the database
                          int result = await AppDatabaseHelper.instance.insertClient(
                            clientName: clientName,
                            clientCode: clientCode,
                            clientEmail: clientEmail,
                            contactNo: contactNo,
                            clientAddress: clientAddress,
                            dueBalance: dueBalance,
                          );

                          // Check if the insert was successful
                          if (result > 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Client Added Successfully!')),
                            );
                            _clientNameController.text= "";
                           _clientCodeController.text= "";
                           _clientEmailController.text= "";
                            _contactNoController.text= "";
                            _clientAddressController.text= "";
                            _dueBalanceController.text = "";
                            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => Dashboard(),), (Route<dynamic> route) => false,);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed to Add Client')),
                            );
                          }

                          setState(() {
                            _clientData = AppDatabaseHelper().displayDataClient();
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFF4C430),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: Text('Submit'),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Client List Section
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _clientData,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No clients found.'));
                  } else {
                    var clientData = snapshot.data!;
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: clientData.length,
                      itemBuilder: (context, index) {
                        var client = clientData[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          elevation: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Account ID: ${client['AccountId']}',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.edit, color: Colors.blue),
                                          onPressed: () {
                                            _clientNameController.text = client['ClientName'];
                                            _clientCodeController.text = client['ClientCode'];
                                            _clientEmailController.text = client['EmailId'];
                                            _contactNoController.text = client['ContactNo'];
                                            _clientAddressController.text = client['Address'];
                                            _dueBalanceController.text = client['DueBalance'].toString();

                                            showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: Text('Edit Client'),
                                                content: SingleChildScrollView(
                                                  child: Column(
                                                    children: [
                                                      _buildInputField('First Name', _clientNameController),
                                                      _buildInputField('Client Code', _clientCodeController),
                                                      _buildInputField('Email Address', _clientEmailController),
                                                      _buildInputField('Contact Number', _contactNoController),
                                                      _buildInputField('Address', _clientAddressController),
                                                      _buildInputField('Due Balance', _dueBalanceController, keyboardType: TextInputType.number),
                                                    ],
                                                  ),
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () => Navigator.pop(context),
                                                    child: Text('Cancel'),
                                                  ),
                                                  ElevatedButton(
                                                    onPressed: () async {
                                                      String clientName = _clientNameController.text;
                                                      String clientCode = _clientCodeController.text;
                                                      String clientEmail = _clientEmailController.text;
                                                      String contactNo = _contactNoController.text;
                                                      String clientAddress = _clientAddressController.text;
                                                      double dueBalance = double.tryParse(_dueBalanceController.text) ?? 0.0;

                                                      int result = await AppDatabaseHelper.instance.updateClient(
                                                        accountId: client['AccountId'],
                                                        clientName: clientName,
                                                        clientCode: clientCode,
                                                        clientEmail: clientEmail,
                                                        contactNo: contactNo,
                                                        clientAddress: clientAddress,
                                                        dueBalance: dueBalance,
                                                      );

                                                      if (result > 0) {
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          SnackBar(content: Text('Client Updated Successfully!')),
                                                        );
                                                        setState(() {
                                                          _clientData = AppDatabaseHelper().displayDataClient();
                                                        });
                                                        Navigator.pop(context);
                                                      } else {
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          SnackBar(content: Text('Failed to Update Client')),
                                                        );
                                                      }
                                                    },
                                                    child: Text('Save'),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.delete, color: Colors.red),
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: Text('Confirm Deletion'),
                                                content: Text('Are you sure you want to delete this client?'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () => Navigator.pop(context),
                                                    child: Text('Cancel'),
                                                  ),
                                                  ElevatedButton(
                                                    onPressed: () async {
                                                      int result = await AppDatabaseHelper.instance.deleteClient(client['AccountId']);

                                                      if (result > 0) {
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          SnackBar(content: Text('Client Deleted Successfully!')),
                                                        );
                                                        setState(() {
                                                          _clientData = AppDatabaseHelper().displayDataClient();
                                                        });
                                                        Navigator.pop(context);
                                                      } else {
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          SnackBar(content: Text('Failed to Delete Client')),
                                                        );
                                                      }
                                                    },
                                                    child: Text('Delete'),
                                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Text('Name: ${client['ClientName']}'),
                                Text('Code: ${client['ClientCode']}'),
                                Text('Email: ${client['EmailId']}'),
                                Text('Contact No: ${client['ContactNo']}'),
                                Text('Address: ${client['Address']}'),
                                Text('Due Balance: ${client['DueBalance']}'),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

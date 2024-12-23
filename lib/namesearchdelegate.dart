import 'package:flutter/material.dart';
import 'creditpage.dart';
import 'database_helper.dart'; // Import your database helper

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> filteredNamesList = []; // List to store filtered names
  final dbHelper = AppDatabaseHelper(); // Database helper instance

  @override
  void initState() {
    super.initState();
    _loadNames(); // Load names initially
  }

  // Load names from the database
  _loadNames() async {
    filteredNamesList = await dbHelper.loadNamesWithBalances();
    setState(() {});
  }

  // Filter names based on the search query
  _filterNames() {
    String searchQuery = _searchController.text.toLowerCase();
    setState(() {
      filteredNamesList = filteredNamesList
          .where((nameData) =>
          nameData['name'].toLowerCase().contains(searchQuery))
          .toList();
    });
  }

  // Clear the search field
  _clearSearch() {
    _searchController.clear();
    _loadNames(); // Reload the original data
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA), // Light background color
      appBar: AppBar(
        iconTheme: IconThemeData(color: Color(0xFFECECEC)),
        backgroundColor: Color(0xFF4E8B88), // Soft green color for app bar
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: TextField(
            controller: _searchController,
            onChanged: (value) => _filterNames(), // Update search results
            decoration: InputDecoration(
              hintText: 'Search for a name',
              border: InputBorder.none, // Remove the border
              hintStyle: TextStyle(color: Colors.white),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                icon: Icon(Icons.clear, color: Colors.white),
                onPressed: _clearSearch, // Clear search input
              )
                  : null, // Only show the clear button if there's text
            ),
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          children: [
            SizedBox(height: 20), // Space between search and list
            // Display filtered names in a simple list
            Expanded(
              child: filteredNamesList.isEmpty
                  ? Center(child: Text('No records found'))
                  : ListView.builder(
                itemCount: filteredNamesList.length,
                itemBuilder: (context, index) {
                  final nameData = filteredNamesList[index];
                  return ListTile(
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                    title: Text(nameData['name']),
                    trailing: IconButton(
                      icon: Icon(Icons.arrow_forward),
                      onPressed: () {
                        // Navigate to credit page or desired action
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CreditPage(name: nameData['name']),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

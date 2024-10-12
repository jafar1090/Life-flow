import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:provider/provider.dart';
import '../providers/searchdonors_provider.dart';

class SearchDonor extends StatefulWidget {
  const SearchDonor({super.key});

  @override
  _SearchDonorState createState() => _SearchDonorState();
}

class _SearchDonorState extends State<SearchDonor> {
  late DonorProvider _donorProvider;
  String _selectedBloodGroup = '';

  @override
  void initState() {
    super.initState();
    _donorProvider = Provider.of<DonorProvider>(context, listen: false);
    _donorProvider.updateSearch('', _selectedBloodGroup);
  }

  void _updateSearchByBloodGroup(String? bloodGroup) {
    setState(() {
      _selectedBloodGroup = bloodGroup ?? '';
      _donorProvider.updateSearch(_searchController.text, _selectedBloodGroup);
    });
  }

  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    bool isSmallScreen = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Search Donors',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w500,
            fontSize: isSmallScreen ? 18 : 22,
          ),
        ),
        backgroundColor: Colors.white10,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.black),
            onPressed: () {

            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filter by Blood Type',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 16 : 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 12 : 16),
                DropdownButton<String>(
                  value: _selectedBloodGroup.isEmpty ? null : _selectedBloodGroup,
                  hint: const Text('Select Blood Type'),
                  icon: const Icon(Icons.arrow_downward),
                  iconSize: 24,
                  elevation: 16,
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: isSmallScreen ? 14 : 16,
                  ),
                  underline: Container(
                    height: 2,
                    color: Colors.green,
                  ),
                  onChanged: _updateSearchByBloodGroup,
                  items: <String>[
                    "", // Add an empty string option
                    "A+", "A-", "B+", "B-", "O+", "O-", "AB+", "AB-"
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value.isEmpty
                          ? 'Blood Type: Any'
                          : 'Blood Type: $value'),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<DonorProvider>(
              builder: (context, donorProvider, child) {
                final donors = donorProvider.donors;

                if (donors.isEmpty) {
                  return const Center(
                    child: Text(
                      'No donors found',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: donors.length,
                  itemBuilder: (context, index) {
                    final donor = donors[index];
                    return Card(
                      margin: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 12 : 16,
                        vertical: isSmallScreen ? 6 : 8,
                      ),
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                        title: Text(
                          donor.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: isSmallScreen ? 16 : 18,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Blood Type: ${donor.bloodType}'),
                            Text('District: ${donor.district}'),
                            Text('Email: ${donor.email}'),
                          ],
                        ),
                        trailing: ElevatedButton(
                          onPressed: () {
                            _makePhoneCall(donor.phoneNumber, context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Icon(Icons.phone, size: 24),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _makePhoneCall(String? phoneNumber, BuildContext context) async {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone number is not available')),
      );
      return;
    }

    await FlutterPhoneDirectCaller.callNumber(phoneNumber);
  }
}

import 'package:delivery/firebase_options.dart';
import 'package:delivery/printer.dart';
import 'package:delivery/snack.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
// import 'package:pinput/pinput.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('OTP List'),
        ),
        body: OtpList(),
      ),
    );
  }
}

class OtpList extends StatefulWidget {
  @override
  _OtpListState createState() => _OtpListState();
}

class _OtpListState extends State<OtpList> {
  late TextEditingController _searchController;
  late List<QueryDocumentSnapshot> _otpList;
  late List<QueryDocumentSnapshot> _filteredOtpList;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _otpList = [];
    _filteredOtpList = [];
    _fetchOtpList();
  }

  void _fetchOtpList() async {
    final otpSnapshot =
        await FirebaseFirestore.instance.collection('otp').get();
    setState(() {
      _otpList = otpSnapshot.docs;
      _filteredOtpList = _otpList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by Order ID',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: _filterOtpList,
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _filteredOtpList.length,
            itemBuilder: (context, index) {
              final doc = _filteredOtpList[index];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(
                      color: doc['isDelivered'] ? Colors.blue : Colors.red,
                    ),
                  ),
                  child: ListTile(
                    title: Text('Order ID : ${doc['orderID']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Name : ${doc['customerName']}'),
                        Text('College : ${doc['College']}'),
                        Text('Hostel : ${doc['Hostel']}'),
                        Text('Room : ${doc['Room']}'),
                        Text('Date Time : ${doc['DateTime']}'),
                        Text('Picked Time : ${doc['PickedTime']}'),
                        Text('Order: ${doc['productNames'].join(', ')}'),
                      ],
                    ),
                    leading: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(doc['isDelivered'] ? Icons.check : Icons.pending),
                        GestureDetector(
                          onTap: () {
                            List<Map<String, dynamic>> data = [
                              doc.data() as Map<String, dynamic>
                            ];
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => PrintPage(data)),
                            );
                          },
                          child: const Icon(Icons.print),
                        ),
                      ],
                    ),
                    onTap: () {
                      if (doc['isDelivered'] != true) {
                        showPinInput(context, doc);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('It\'s Already Delivered...'),
                          ),
                        );
                      }
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _filterOtpList(String searchText) {
    setState(() {
      _filteredOtpList = _otpList.where((doc) {
        final orderId = doc['orderID'].toString().toLowerCase();
        return orderId.contains(searchText.toLowerCase());
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

void showPinInput(BuildContext context, DocumentSnapshot doc) {
  String pinCode = '';
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Enter Pin Code'),
        content: TextField(
          onChanged: (value) {
            pinCode = value;
          },
          keyboardType: TextInputType.number,
          maxLength: 4, // Restrict to 4 digits
          decoration: const InputDecoration(
            hintText: 'Enter Pin Code',
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // Check pin code here
              if (pinCode == doc['pinCode'].toString()) {
                await FirebaseFirestore.instance
                    .collection('otp')
                    .doc(doc.id)
                    .update({'isDelivered': true});
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pin code matched!'),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Incorrect pin code!'),
                  ),
                );
              }
              Navigator.of(context).pop();
            },
            child: const Text('Submit'),
          ),
        ],
      );
    },
  );
}

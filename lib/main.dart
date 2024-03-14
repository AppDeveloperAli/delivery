import 'package:delivery/firebase_options.dart';
import 'package:delivery/snack.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
          title: Text('OTP List'),
        ),
        body: OtpList(),
      ),
    );
  }
}

class OtpList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('otp').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }
        return ListView(
          children: snapshot.data!.docs.map((doc) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(
                      color: doc['isDelivered'] ? Colors.blue : Colors.red),
                ),
                child: ListTile(
                  title: Text(doc['customerName']),
                  subtitle: Text('Order: ${doc['productNames'].join(', ')}'),
                  leading:
                      Icon(doc['isDelivered'] ? Icons.check : Icons.pending),
                  onTap: () {
                    showPinInput(context, doc);
                  },
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  void showPinInput(BuildContext context, DocumentSnapshot doc) {
    String pinCode = '';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Pin Code'),
          content: TextField(
            onChanged: (value) {
              pinCode = value;
            },
            keyboardType: TextInputType.number,
            maxLength: 4, // Restrict to 4 digits
            decoration: InputDecoration(
              hintText: 'Enter Pin Code',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
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
                    SnackBar(
                      content: Text('Pin code matched!'),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Incorrect pin code!'),
                    ),
                  );
                }
                Navigator.of(context).pop();
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }
}

import 'package:app1/driver_order_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DriverHomePage extends StatefulWidget {
  @override
  _DriverHomePageState createState() => _DriverHomePageState();
}

class _DriverHomePageState extends State<DriverHomePage> {
  User? driver = FirebaseAuth.instance.currentUser;

  Future<void> _acceptOrder(String orderId, String userId) async {
    if (driver == null) return;

    var driverDoc = await FirebaseFirestore.instance.collection('users').doc(driver!.uid).get();
    String driverName = driverDoc.data()?['name'] ?? 'Driver';

    // Update order 
    await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
      'driverId': driver!.uid,
      'driverName': driverName,
    });
        var notifSnapshot = await FirebaseFirestore.instance
        .collection('notifications')
        .where('orderId', isEqualTo: orderId) // Corrected Query
        .get();

    for (var doc in notifSnapshot.docs) {
      await doc.reference.update({'accepted': false});
    }

    for (var doc in notifSnapshot.docs) {
      await doc.reference.update({'accepted': true});
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Order $orderId accepted!")),
    );
    Navigator.push(context,MaterialPageRoute(builder: (context)=>DriverOrderPage(orderId: orderId),),);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Driver Dashboard")),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('driverId', isEqualTo: driver?.uid)
            .where('accepted', isEqualTo: false)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No new orders available"));
          }

          var orders = snapshot.data!.docs;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              var order = orders[index];

              return Card(
                margin: EdgeInsets.all(10),
                child: ListTile(
                  title: Text(order['message']),
                  subtitle: Text("Order ID: ${order['orderId']}"),
                  trailing: ElevatedButton(
                    onPressed: () => _acceptOrder(order['orderId'], order['driverId']),
                    child: Text("Accept"),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

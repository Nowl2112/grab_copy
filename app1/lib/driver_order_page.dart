import 'package:app1/driver_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'driver_order_tracking.dart';

class DriverOrderPage extends StatelessWidget {    
  final String orderId;
  DriverOrderPage({required this.orderId});

  Future<void> _cancelOrder(BuildContext context, String orderId) async {
    try {
      await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
        'driverId': null,
        'driverName': null,
      });
        var notifSnapshot = await FirebaseFirestore.instance
        .collection('notifications')
        .where('orderId', isEqualTo: orderId) // Corrected Query
        .get();

    for (var doc in notifSnapshot.docs) {
      await doc.reference.update({'accepted': false});
    }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Order $orderId cancelled!")),
      );

      Navigator.push(context,MaterialPageRoute(builder: (context) => DriverHomePage()),);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error cancelling order: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('orders').doc(orderId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('No order found'));
          }

          var order = snapshot.data!;
          String restaurantName = order['restaurant'] ?? 'Unknown Restaurant';

          return Scaffold(
            appBar: AppBar(title: Text(restaurantName)),
            body: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Expanded(
                    child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('orders')
                          .doc(orderId)
                          .collection('items')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Center(child: Text('No items found'));
                        }

                        var items = snapshot.data!.docs;
                        return ListView.builder(
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            var item = items[index];
                            var itemName = item['name'];
                            var itemImage = item['imageLink'];
                            var itemPrice = item['price'];
                            var itemquan = item['quantity'];
                            return Card(
                              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              child: ListTile(
                                leading: itemImage != null
                                    ? Image.network(itemImage, width: 50, height: 50, fit: BoxFit.cover)
                                    : Icon(Icons.fastfood),
                                title: Text(itemName),
                                subtitle: Text('Price: \$ $itemPrice | Quantity: $itemquan'),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DriverOrderTracking(orderId: orderId)),
                      );
                    },
                    child: Container(
                      height: 50,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Color(0xFF006f85),
                      ),
                      child: Center(
                        child: Text("Picked up", style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  GestureDetector(
                    onTap: () => _cancelOrder(context, orderId),
                    child: Container(
                      height: 50,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Color(0xff9c4941),
                      ),
                      child: Center(
                        child: Text("Cancel", style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CartPage extends StatefulWidget {
  final String restaurantName;
    CartPage({required this.restaurantName});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  double totalPrice = 0.0;

  Future<List<Map<String, dynamic>>> _fetchCartItems() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    var cartSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('cart')
        .get();

    List<Map<String, dynamic>> cartItems = [];
    double calculatedTotalPrice = 0.0;

    for (var doc in cartSnapshot.docs) {
      var item = doc.data();
      item['id'] = doc.id;
      cartItems.add(item);
      calculatedTotalPrice += (item['price'] * item['quantity']);
    }

    setState(() {
      totalPrice = calculatedTotalPrice;
    });

    return cartItems;
  }

Future<void> _checkout() async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user == null) return;
  
  var userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
  String username = userDoc.data()?['name'] ?? 'Unknown';

  var cartSnapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('cart')
      .get();

  if (cartSnapshot.docs.isEmpty) return;

  List<Map<String, dynamic>> items = cartSnapshot.docs.map((doc) {
    var data = doc.data();
    data['id'] = doc.id;
    return data;
  }).toList();

  Map<String, dynamic> orderData = {
    'userId': user.uid,
    'username': username,
    'driverId': null,
    'driverName': null,
    'restaurant':widget.restaurantName,
    'totalPrice': totalPrice,
    'createdAt': FieldValue.serverTimestamp(),
  };

  DocumentReference orderRef =
      await FirebaseFirestore.instance.collection('orders').add(orderData);

  for (var item in items) {
    await orderRef.collection('items').add(item);
  }

  for (var doc in cartSnapshot.docs) {
    await doc.reference.delete();
  }

  setState(() {
    totalPrice = 0.0;
  });

  // Send notification to drivers
  _sendDriverNotification(orderRef.id, username);

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("Checkout successful")),
  );
}


Future<void> _sendDriverNotification(String orderId, String username) async {
  var driversSnapshot = await FirebaseFirestore.instance
      .collection('users')
      .where('role', isEqualTo: 'driver')
      .get();

  for (var driver in driversSnapshot.docs) {
    await FirebaseFirestore.instance.collection('notifications').add({
      'driverId': driver.id,
      'message': "New order placed by $username!",
      'orderId': orderId,
      'timestamp': FieldValue.serverTimestamp(),
      'accepted':false,
      'seen': false,
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("My Cart")),
      body: FutureBuilder(
        future: _fetchCartItems(),
        builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("Your cart is empty"));
          }

          var cartItems = snapshot.data!;

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    var item = cartItems[index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ListTile(
                        leading: item['imageLink'] != null
                            ? Image.network(item['imageLink'], width: 50, height: 50, fit: BoxFit.cover)
                            : Icon(Icons.fastfood),
                        title: Text(item['name']),
                        subtitle: Text("Quantity: ${item['quantity']}  |  \$${item['price'] * item['quantity']}"),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: EdgeInsets.all(10),
                child: Column(
                  children: [
                    Text("Total Price: \$${totalPrice.toStringAsFixed(2)}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    ElevatedButton(
                      style: ButtonStyle(backgroundColor:WidgetStatePropertyAll(Color(0xFF006f85))),
                      
                      onPressed: _checkout,
                      child: Text("Checkout",style: TextStyle(color: Color(0xffffffff)),),
                    ),
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }
}

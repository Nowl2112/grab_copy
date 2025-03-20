import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
class DriverOrderPage extends StatelessWidget {    
  final String orderId;
  DriverOrderPage({required this.orderId});

  @override
  Widget build(BuildContext context) {
  return Scaffold(
        body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('orders').doc(orderId).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(
                appBar: AppBar(title: Text("Loading Order...")),
                body: Center(child: CircularProgressIndicator()),
              );
            }
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Scaffold(
                appBar: AppBar(title: Text("Order Not Found")),
                body: Center(child: Text('No order found')),
              );
            }

            var order = snapshot.data!;
            String restaurantName = order['restaurant'] ?? 'Unknown Restaurant';

          return Scaffold(
            appBar: AppBar(title: Text(restaurantName)),
            body: Padding(padding: EdgeInsets.all(16),
              child:Column(
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
                          var itemquan =item['quantity'];
                          return Card(
                            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            child: ListTile(
                              leading: itemImage != null
                                  ? Image.network(itemImage, width: 50, height: 50, fit: BoxFit.cover)
                                  : Icon(Icons.fastfood),
                              title: Text(itemName),
                              subtitle: Text('price:\$ $itemPrice quantity:$itemquan'),
                            ),
                          );
                        },
                      );
                  
                  }),
                  ),
                  Container(
                    height:50,
                    width: double.infinity,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(20),
                    color:Color(0xFF006f85)),
                  )
        ],
      ),
    ),);
  }
  )
  
  );
  }
}
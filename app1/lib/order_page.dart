import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OrderPage extends StatefulWidget {
  final String orderId;
  OrderPage({required this.orderId});

  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('orders').doc(widget.orderId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Scaffold(
              appBar: AppBar(title: Text("Order Not Found")),
              body: Center(child: Text('No order found')),
            );
          }

          var order = snapshot.data!;
          var orderId=order.id;
          return Scaffold(
            appBar: AppBar(title: Text(orderId)),
            body: Column(
              children: [
                Expanded(
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('orders')
                        .doc(widget.orderId)
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
                    },
                  ),
                ),
                
              ],
            ),
          );
        },
      ),
    );
  }
}

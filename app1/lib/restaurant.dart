import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'cart.dart';


class RestaurantPage extends StatefulWidget {
  final String restaurantId;
  RestaurantPage({required this.restaurantId});

  @override
  _RestaurantPageState createState() => _RestaurantPageState();
}

class _RestaurantPageState extends State<RestaurantPage> {
  int itemsAdded = 0;

  Future<void> _addToCart(String itemId, String itemName, String itemImage, double itemPrice) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("No user logged in");
      return;
    }

    var userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    var cartRef = userDocRef.collection('cart');

    var itemDoc = await cartRef.doc(itemId).get();

    if (itemDoc.exists) {
      // If item exists, increase quantity
      await cartRef.doc(itemId).update({
        'quantity': FieldValue.increment(1),
      });
    } else {
      // If item does not exist, create it with quantity 1
      await cartRef.doc(itemId).set({
        'name': itemName,
        'imageLink': itemImage,
        'price': itemPrice,
        'quantity': 1,
      });
    }

    print("Item added to cart");

    setState(() {
      itemsAdded++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('restaurants').doc(widget.restaurantId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Scaffold(
              appBar: AppBar(title: Text("Restaurant Not Found")),
              body: Center(child: Text('No restaurant found')),
            );
          }

          var restaurant = snapshot.data!;
          var name = restaurant['name'];

          return Scaffold(
            appBar: AppBar(title: Text(name)),
            body: Column(
              children: [
                Expanded(
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('restaurants')
                        .doc(widget.restaurantId)
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
                          var itemId = item.id;
                          var itemImage = item['imageLink'];
                          var itemPrice = item['price'];

                          return Card(
                            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            child: ListTile(
                              leading: itemImage != null
                                  ? Image.network(itemImage, width: 50, height: 50, fit: BoxFit.cover)
                                  : Icon(Icons.fastfood),
                              title: Text(itemName),
                              subtitle: Text('\$ $itemPrice'),
                              trailing: IconButton(
                                onPressed: () => _addToCart(itemId, itemName, itemImage, itemPrice),
                                icon: Icon(Icons.add),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => CartPage(restaurantName: name)));
                  },
                  child: Container(
                    height: 50,
                    width: double.infinity,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(20),color: Color(0xFF006f85),
),
                    child: Center(
                      child: Text(
                        'Cart items: $itemsAdded',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
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

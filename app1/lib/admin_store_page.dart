import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_item_page.dart';
class AdminStorePage extends StatelessWidget {
  final String restaurantId;

  AdminStorePage({required this.restaurantId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manage Store Items')),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('restaurants')
            .doc(restaurantId)
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

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: itemImage != null
                      ? Image.network(itemImage, width: 50, height: 50, fit: BoxFit.cover)
                      : Icon(Icons.fastfood),
                  title: Text(itemName),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteItem(item.id),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,MaterialPageRoute(builder: (context)=>AdminItemPage(restaurantId:restaurantId)));//gives restaurant id to next page
                },
        child: Icon(Icons.add),
      ),
    );
  }

  Future<void> _deleteItem(String itemId) async {
    await FirebaseFirestore.instance.collection('items').doc(itemId).delete();
  }
}


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'order_page.dart';
class OrdersPage extends StatelessWidget {    
const OrdersPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  automaticallyImplyLeading: false, 
  backgroundColor: Color(0xFF006f85),
  title: Center(
    child: Text(
      "Orders",
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color: Color(0xffffffff)),
    ),
  ),
),
            
      
            body: StreamBuilder(stream: FirebaseFirestore.instance.collection('orders').snapshots(), builder: (context,snapshot){
              if(snapshot.connectionState==ConnectionState.waiting){
                return Center(child: CircularProgressIndicator());
              }
              if(!snapshot.hasData || snapshot.data!.docs.isEmpty){
                return Center(child:Text('No orders found'));
              
              }
              var orders=snapshot.data!.docs;
              return ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context,index){
                  var order=orders[index];
                  var name=order['username'];
                  var driver=order['driverName'];
                  var price=order['totalPrice'];
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 10,vertical:5),
                    child: ListTile(
                      title:Text(name),
                      subtitle: Text('driver:$driver Total price:\$$price'),
                      onTap:(){ Navigator.push(context,MaterialPageRoute(builder: (context)=>OrderPage(orderId: order.id),),);}
                      
                    ),
                    
                    
                  );
                }
              );
            }
            ),
          
    
    
    );
  }
}

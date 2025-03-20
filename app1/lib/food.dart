import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'restaurant.dart';
class FoodPage extends StatelessWidget {    
const FoodPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  automaticallyImplyLeading: false, 
  backgroundColor: Color(0xFF006f85),
  title: Center(
    child: Text(
      "Food",
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color: Color(0xffffffff)),
    ),
  ),
),
            
      
            body: StreamBuilder(stream: FirebaseFirestore.instance.collection('restaurants').snapshots(), builder: (context,snapshot){
              if(snapshot.connectionState==ConnectionState.waiting){
                return Center(child: CircularProgressIndicator());
              }
              if(!snapshot.hasData || snapshot.data!.docs.isEmpty){
                return Center(child:Text('No restaurants found'));
              
              }
              var restaurants=snapshot.data!.docs;
              return ListView.builder(
                itemCount: restaurants.length,
                itemBuilder: (context,index){
                  var restaurant=restaurants[index];
                  var name=restaurant['name'];
                  var imageLink=restaurant['imageLink'];

                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 10,vertical:5),
                    child: ListTile(
                      leading:imageLink!=null
                      ?Image.network(imageLink,width:50,height: 50, fit:BoxFit.cover)
                      :Icon(Icons.restaurant), 
                      title:Text(name),
                      onTap:(){ Navigator.push(context,MaterialPageRoute(builder: (context)=>RestaurantPage(restaurantId: restaurant.id),),);}
                      
                    ),
                    
                    
                  );
                }
              );
            }
            ),
          
    
    
    );
  }
}

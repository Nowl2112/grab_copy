import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'restaurant_form.dart';
import 'admin_store_page.dart';

class AdminPage extends StatefulWidget {
      const AdminPage({super.key});

    @override
    _AdminPageState createState()=>_AdminPageState();}

class _AdminPageState extends State<AdminPage> {
  bool isAdmin = false;
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    checkAdminStatus();
  }

  Future<void> checkAdminStatus() async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    //use email to get the user
    QuerySnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: user.email) // Match the email field
        .get();

    if (userSnapshot.docs.isNotEmpty) {
      DocumentSnapshot userDoc = userSnapshot.docs.first;

      setState(() {
        isAdmin = userDoc['role'] == "admin";
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  } else {
    setState(() {
      isLoading = false;
    });
  }
}
  
  @override
  Widget build(BuildContext context){
    if (isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!isAdmin) {
      return Scaffold(
        body: Center(
          child: Text("Access Denied: Admins Only"),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title:Center(
          child: Text(
            'Admin Page'),
            
            )
            ),
            body: StreamBuilder(stream: FirebaseFirestore.instance.collection('restaurants').snapshots(), builder: (context,snapshot){  //fetching restaurants
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
                      ?Image.network(imageLink,width:50,height: 50, fit:BoxFit.cover)//displays image in image link
                      :Icon(Icons.restaurant),
                      title:Text(name),
                      trailing: IconButton( icon:Icon(Icons.delete,color:Color(0xffff0000),),
                      onPressed: ()=> _deleteRestaurant(restaurant.id),),
                      onTap:(){ Navigator.push(context,MaterialPageRoute(builder: (context)=>AdminStorePage(restaurantId: restaurant.id),),);}
                    ),
                  );
                }
              );
            }
            ),
            floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => RestaurantForm()));
        },
        child: Icon(Icons.add),
          
    ),
    
    );
  }
  
  Future<void> _deleteRestaurant(String restaurantId) async {
    await FirebaseFirestore.instance.collection('restaurants').doc(restaurantId).delete();
  }
}
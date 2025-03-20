import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class RestaurantForm extends StatefulWidget {
  const RestaurantForm({super.key});

  @override
  _RestaurantFormState createState() => _RestaurantFormState();
}

class _RestaurantFormState extends State<RestaurantForm> {
  bool isAdmin = false;
  bool isLoading = true;
  final TextEditingController _nameController = TextEditingController();
  File? _image;
  bool _isUploading= false;
  @override
  void initState() {
    super.initState();
    checkAdminStatus();
  }

  Future<void> checkAdminStatus() async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    // Query Firestore using the email to get user document
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

Future<void> _pickImage() async{
  FilePickerResult? result= await FilePicker.platform.pickFiles(
    type:FileType.image,//make sure only images 
  );
  if (result!=null){
    setState(() {
      _image = File(result.files.single.path!);
    });
  }

}
Future _uploadRestaurant() async{
  if (_nameController.text.isEmpty || _image==null){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Name and Image required")),
);
return;
    }
    setState(()=>_isUploading=true);
    try{  
      //upload image to firebase
      String fileName=DateTime.now().millisecondsSinceEpoch.toString();
      Reference storagreRef=FirebaseStorage.instance.ref().child('restaurant_images/$fileName');
      UploadTask uploadTask=storagreRef.putFile(_image!);
      TaskSnapshot taskSnapshot=await uploadTask;
      String downloadURL= await taskSnapshot.ref.getDownloadURL();
      //store restaurant data
      await FirebaseFirestore.instance.collection('restaurants').add({
        'name':_nameController.text,
        'imageLink': downloadURL,
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Restaurant added successfully!')),);
      _nameController.clear();
      setState(() {
        _image=null;
        _isUploading=false;
      });
    }catch(e){
      setState(()=>_isUploading=false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error, ${e.toString()}')),);
        
      
    }
}
  @override
  Widget build(BuildContext context) {
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
      appBar: AppBar(title: Text("Add Restaurant")),
      body:Padding(padding: EdgeInsets.all(16),child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //name input
          TextField( 
            controller: _nameController,
            decoration: InputDecoration(labelText: "Restaurant Name"),
          ),
          //image input
          SizedBox(height: 16),
          GestureDetector(
            onTap:_pickImage,
            child:Container(
              width: double.infinity,
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(color:Color(0xffbbbbbb)),
                borderRadius: BorderRadius.circular(20),
              ),
              child: _image != null
              ? Image.file(_image!,fit:BoxFit.cover)
              : Center(child: Text("Tap to select an image")),
            ) ,
          ),SizedBox(height: 16),
          _isUploading
          ?Center(child: CircularProgressIndicator())
            : ElevatedButton(onPressed: _uploadRestaurant, child: Text('Add Restaurant')),        ],
      ),
      )
    );
  }
}

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class AdminItemPage extends StatefulWidget{
  final String restaurantId;
  const AdminItemPage({super.key,required this.restaurantId});//gets restaurant id from previous page
  @override
  _AdminItemState createState() =>_AdminItemState();
}
class _AdminItemState extends State<AdminItemPage>{
  bool isAdmin = false;
  bool isLoading = true;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  File? _image;
  bool _isUploading = false;
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
  
  Future<void> _pickImage() async{    //image picker
    FilePickerResult? result=await FilePicker.platform.pickFiles(
      type:FileType.image,//only images
    
    );
    if(result!=null){
      setState(() {
        _image=File(result.files.single.path!);
      });
    }
  }
  
  Future<void> _uploadImage() async{ //actually its upload item but abit lazy convert rn
  if(_nameController.text.isEmpty||_priceController.text.isEmpty||_image==null){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please fill in all the information of your item")),);
    return;
  }
  setState(() =>_isUploading=true);
  try{
    //upload image to firebase storage
    String filename=DateTime.now().millisecondsSinceEpoch.toString();//stores image name as time uploaded 
    Reference storageRef=FirebaseStorage.instance.ref().child('item_images/$filename');
    UploadTask uploadTask=storageRef.putFile(_image!);
    TaskSnapshot taskSnapshot=await uploadTask;
    String downloadURL=await taskSnapshot.ref.getDownloadURL();
    await FirebaseFirestore.instance.collection('restaurants').doc(widget.restaurantId).collection('items').add({'name':_nameController.text,'price':double.parse(_priceController.text),'imageLink':downloadURL,});
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Item added successfulyy")));
    _nameController.clear();
    _priceController.clear();
    setState((){_image=null; _isUploading=false;} );
  }catch(e){
    setState(()=>_isUploading=false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Errror ${e.toString()}')));
  }
  }
  
  @override
  Widget build(BuildContext context) {
    if (isLoading){
      return Scaffold(body:Center(child: CircularProgressIndicator(),));
    }
    
    if (!isAdmin) {
      return Scaffold(
        body: Center(
          child: Text("Access Denied: Admins Only"),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text("Add Item")),
      body:Padding(padding: EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(label: Text("Item Name")),
          ),
          SizedBox(height: 16,),
          TextField(
            controller: _priceController,
            decoration: InputDecoration(label: Text("Price")),
            keyboardType: TextInputType.number,

          ),
          SizedBox(height: 16,),
          //image picker
          GestureDetector(
            onTap: _pickImage,
            child: Container(width: double.infinity,
            height: 150,
            decoration: BoxDecoration(border: Border.all(color: Color(0xffbbbbbb)),
            borderRadius: BorderRadius.circular(20),
            ),
            child: _image != null
            ?Image.file(_image!,fit: BoxFit.cover):Center(child: Text("Tap to add image"))
            ,
            ),
          ),
          SizedBox(height: 16),
            _isUploading
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _uploadImage, child: Text('Add Item')),
        ],
      ),)
    );

  }

  }
  
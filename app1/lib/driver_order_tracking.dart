
import 'package:flutter/material.dart';

class DriverOrderTracking extends StatelessWidget { 
    final String orderId;
  DriverOrderTracking({required this.orderId});   
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("DriverOrderTracking")),
      body: Center(child: Text("DriverOrderTracking Page")),
    );
  }
}
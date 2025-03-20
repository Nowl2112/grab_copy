import 'package:app1/orders_page.dart';
import 'package:flutter/material.dart';
import 'package:app1/food.dart';


class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 50),
        child: Align(
          alignment: Alignment.topCenter,
          child: Column(
            children: [
              Container(
                height: 100,
                width: 400,
                decoration: BoxDecoration(
                  color: Color(0xFF006f85),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Welcome ",
                        style: TextStyle(
                            color: Color(0xFFffffff),
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Look at all the deals available today!",
                        style: TextStyle(
                          color: Color(0xFFffffff),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                height: 250,
                width: 400,
                decoration: BoxDecoration(
                    color: Color(0xFFffffff),
                    borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        categoryContainer(context, "Food", FoodPage()),
                        categoryContainer(context, "Orders", OrdersPage()),

                      ],
                    ),
                    const SizedBox(height: 5),

                    
                  ],
                ),
              ),
              Column(
                children: [
                  Text(
                    "Recommended Food",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget categoryContainer(BuildContext context, String text, Widget page) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => page));
      },
      child: Container(
        height: 100,
        width: 100,
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 188, 214, 219),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: EdgeInsets.all(5),
        child: Center(
          child: Text(
            text,
            style: TextStyle(fontSize: 12),
          ),
        ),
      ),
    );
  }
}





import 'package:flutter/material.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    var haut = TextEditingController();
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            height: 90,
          ),
          Text(
            haut.text,
            style: TextStyle(
                color: Colors.white, fontSize: 35, fontStyle: FontStyle.italic),
          ),
          SizedBox(
            height: 30,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 200.0),
            child: Text(
              'Question 3/4',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontStyle: FontStyle.italic),
            ),
          ),
          SizedBox(
            height: 60,
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: double.infinity,
                height: 90,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20)),
              ),
              Positioned(
                top: -30,
                left: 0,
                right: 0,
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.check,
                    color: Colors.green,
                    size: 60,
                  ),
                ),
              ),
              Positioned(
                top: 0,
                bottom: 0,
                //left: -10,
                right: -25,
                child: CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.black,
                ),
              ),
              Positioned(
                top: 0,
                bottom: 0,
                left: -25,
                child: CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.black,
                ),
              ),
            ],
          ),
          TextFormField(
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Type Here',
              hintStyle: TextStyle(color: Colors.white),
            ),
            controller: haut,
          ),
          FloatingActionButton(onPressed: () {
            print(haut.text);
          }),
        ],
      ),
    );
  }
}

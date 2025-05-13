import 'package:flutter/material.dart';

class DialogAnswer extends StatelessWidget {
  final controller;

  VoidCallback onSave;
  VoidCallback onCancel;

  DialogAnswer({
    super.key,
    required this.controller,
    required this.onSave,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      content: Container(
        height: 100,
        child: Column(
          spacing: 8,
            children: [
          TextField(
            controller: controller,
            decoration: InputDecoration(hintText: "Write a task"),
          ),
          Row(
            spacing: 8,
            children: [
              ElevatedButton(
                onPressed: onSave,
                child: Text("Save"),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                  foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                )
              ),
              ElevatedButton(
                onPressed: onCancel,
                child: Text("Cancel"),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                  foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                )
              ),
            ],
          )
        ]),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../main.dart';

class EmojiFace extends StatelessWidget {
  final InfoCubit myCubit;
  final String emojiface;
  final String label;

  const EmojiFace({Key? key, required this.emojiface, required this.label, required this.myCubit}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
          ElevatedButton(
            onPressed: () => myCubit.addMood(label),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(16),
              minimumSize: const Size(15, 15),
            ),
            child: Center(child: Text(
              emojiface,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Lato',
            ),
          ),
        ]);
  }
}

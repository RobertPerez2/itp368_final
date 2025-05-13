import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'main.dart';

// The StatsPage displays all the saved stats of the user's mood entries!
class StatsPage extends StatelessWidget {
  const StatsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InfoCubit, InfoState>(
      builder: (context, state) {
        final myCubit = BlocProvider.of<InfoCubit>(context);

        return Scaffold(
          backgroundColor: Colors.blue[900],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: 1,
            onTap: (index) {
              if (index == 0) Navigator.pop(context);
            },
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: ' '),
              BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: ' '),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: state.moodList
                      .map((m) => Text("${myCubit.convertDateToString(m[0])}: ${m[1]}", style: const TextStyle(color: Colors.white, fontSize: 18)))
                      .toList(),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => myCubit.clearMoods(),
            backgroundColor: Colors.white,
            child: const Icon(
              Icons.delete,
              color: Color(0xFF81D4FA),
              size: 30.0,
            ),
          ),
        );
      },
    );
  }
}
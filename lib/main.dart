// Robert Perez
// Spring 2025
// Mental health and task manager app! Store your tasks and
// your mood for the day so you can also keep track of your mental health as of late.
// API used: lottie

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import "package:path_provider/path_provider.dart";
import 'util/individual.dart';
import 'util/dialog.dart';
import 'package:lottie/lottie.dart';
import 'util/emoji_face.dart';
import 'stats.dart';
import 'dart:io';

class InfoState {
  final List<List<dynamic>> taskList; // String, bool
  final List<List<dynamic>> moodList; // DateTime, String

  InfoState(this.taskList, this.moodList);
}

class InfoCubit extends Cubit<InfoState> {
  InfoCubit() : super(InfoState([], []));

  // Check if the app is opened for the first time
  Future<bool> isFirstOpen() async {
    String myStuff = await whereAmI();
    String filePath = "$myStuff/data.txt";
    print("filePath is $filePath");

    File fodder = File(filePath);
    if (!fodder.existsSync()) {
      fodder.createSync();
      return true;
    } else {
      return false;
    }
  }

  // if the app is opened for the first time, add example task
  Future<void> init() async {
    bool isFirst = await isFirstOpen();

    if (isFirst) {
      makeDataFirstOpen();
      await updateFileData();
    } else {
      await uploadFileData();
    }
  }

  // Update the task completion status (strike out or not)
  void updateTaskCompletion(bool? value, int index) {
    List<List<dynamic>> taskList = state.taskList;

    taskList[index][1] = !taskList[index][1];
    emit(InfoState(List.from(taskList), state.moodList));
    updateFileData();
  }

  // Add a task to the task list
  void addTask(String taskName) {
    if (taskName.trim().isEmpty) return;
    List<List<dynamic>> taskList = state.taskList;

    taskList.add([taskName, false]);
    emit(InfoState(List.from(taskList), state.moodList));
    updateFileData();
  }

  // Delete a task from the task list
  void deleteTask(int index) {
    List<List<dynamic>> taskList = state.taskList;

    taskList.removeAt(index);
    emit(InfoState(List.from(taskList), state.moodList));
    updateFileData();
  }

  // Convert datetime to string
  String convertDateToString(DateTime date) {
    List<String> months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December"
    ];

    List<String> weekdays = [
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday",
      "Sunday"
    ];

    return "${weekdays[date.weekday-1]}, ${months[date.month-1]} ${date.day}, ${date.year}";
  }

  String getCurrentDate() {
    DateTime now = DateTime.now();
    return convertDateToString(now);
  }

  // Add a mood to the mood list
  void addMood(String mood) {
    List<List<dynamic>> moodList = state.moodList;
    DateTime now = DateTime.now();

    moodList.add([now, mood]);
    emit(InfoState(state.taskList, List.from(moodList)));
    updateFileData();
  }

  // Empty out the mood list
  void clearMoods() {
    emit(InfoState(state.taskList, []));
    updateFileData();
  }

  // For file saving
  Future<String> whereAmI() async
  {
    // getApplicationDocumentsDirectory isn't supported by chrome(web)
    Directory mainDir = await getApplicationDocumentsDirectory();
    String mainDirPath = mainDir.path;

    return mainDirPath;
  }

  // For first time open
  void makeDataFirstOpen() {
    List<List<dynamic>> taskList = [
      ["Reply Email", false],
    ];

    emit(InfoState(taskList, []));
    updateFileData();
  }

  /*
    Saving to file...
    Example file:
    homework!0
    take out trash!1
    turn in work hour!0;DATETIME!mood
    DATETIME!mood
   */
  Future<void> updateFileData() async {
    String myStuff = await whereAmI();
    String taskFilePath = "$myStuff/data.txt";

    File fodder = File(taskFilePath);
    if (!fodder.existsSync()) {
      fodder.createSync();
    }

    // Save tasks
    List<String> tasks = [];
    for (int i = 0; i < state.taskList.length; i++) {
      String item = state.taskList[i][0];
      bool isChecked = state.taskList[i][1];
      // Save as 1 or 0, 1 = checked, 0 = unchecked
      tasks.add("$item!${isChecked ? '1' : '0'}");
    }

    String taskString = tasks.join("\n");

    // Save moods
    List<String> moods = [];
    for (int i = 0; i < state.moodList.length; i++) {
      String dateStr = (state.moodList[i][0] as DateTime).toIso8601String();
      String mood = state.moodList[i][1];
      moods.add("$dateStr!$mood");
    }

    String moodString = moods.join("\n");
    String savedData = "$taskString;$moodString";

    fodder.writeAsStringSync(savedData);
  }

  // Get stored tasks and moods from file
  Future<void> uploadFileData() async {
    String myStuff = await whereAmI();
    String filePath = "$myStuff/data.txt";

    File fodder = File(filePath);
    if (!fodder.existsSync()) {
      fodder.createSync();
    }

    // Split up the file into tasks and moods strings
    String contents = fodder.readAsStringSync();
    List<String> sections = contents.split(";");
    List<String> tasksString = sections[0].split("\n");
    List<String> moodString;
    if(sections.length > 1) {
      moodString = sections[1].split("\n");
    } else {
      moodString = [];
    }

    // Parse tasks
    List<List<dynamic>> tasks = [];
    for (String line in tasksString) {
      if (line.trim().isEmpty) continue;  // skip blank lines

      List<String> parts = line.split("!");
      if (parts.length == 2) {
        String item = parts[0];
        bool isChecked = parts[1] == '1';
        tasks.add([item, isChecked]);
      }
    }

    // Parse moods
    List<List<dynamic>> moods = [];
    for (String line in moodString) {
      if (line.trim().isEmpty) continue;
      List<String> parts = line.split("!");
      if (parts.length != 2) continue;
      String rawDate = parts[0];
      String moodText = parts[1];

      DateTime date = DateTime.parse(rawDate);
      moods.add([date, moodText]);
    }

    emit(InfoState(tasks, moods));
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<InfoCubit>(
      create: (context) => InfoCubit()..init(),
      child: MaterialApp(
        title: 'Mental Health and Task Manager',
        home: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({Key? key}) : super(key: key);

  final controller = TextEditingController();

  // Logic to add a task into the list
  void createTask(BuildContext context, InfoCubit cubit) {
    showDialog(
      context: context,
      builder: (context) {
        return DialogAnswer(
          controller: controller,
          onSave: () {
            cubit.addTask(controller.text);
            controller.clear();
            Navigator.of(context).pop();
          },
          onCancel: () => Navigator.of(context).pop(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InfoCubit, InfoState>(
      builder: (context, state) {
        final myCubit = BlocProvider.of<InfoCubit>(context);

        // Navigation bar at the bottom of the screen
        return Scaffold(
          backgroundColor: Colors.blue[900],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: 0, // Set the default selected index
            onTap: (index) {
              if (index == 1) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => StatsPage()),
                );
              }
            },
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: ' '),
              BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: ' '),
            ],
          ),

          // Padding for the organization of the rest of the homepage
          body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    spacing: 8,
                    children: [
                      const SizedBox(height: 15),
                      // Title of my app
                      Text(
                        'Mental Health + Task Manager',
                        style: TextStyle(
                          fontFamily: 'Lato',
                          color: Color(0xFFFFFFFF),
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                        softWrap: true,
                        overflow: TextOverflow.visible,
                      ),

                      // My edited version of the cloud animation
                      // https://app.lottiefiles.com/share/44898b1d-6c39-4104-99ec-fd8937a85997
                      Lottie.asset('lib/assets/Clouds.json',
                        fit: BoxFit.cover,
                        height: 150,
                        repeat: true,
                      ),

                      // Preface before the emoji faces for the moods
                      // Shows current date as well
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 8,
                            children: [
                              const Text(
                                'How do you feel today?',
                                style: TextStyle(
                                  fontFamily: 'Lato',
                                  color: Color(0xFFFFFFFF),
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                myCubit.getCurrentDate(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Lato',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),

                      // Actual emoji and mood selectors
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          EmojiFace(emojiface: 'ʕ^ᴥ^ʔ', label: 'Great', myCubit: myCubit),
                          EmojiFace(emojiface: 'ʕ•ᴥ•ʔ', label: 'Okay', myCubit: myCubit),
                          EmojiFace(emojiface: 'ʕ•́ᴥ•̀ʔ', label: 'Sad', myCubit: myCubit),
                          EmojiFace(emojiface: 'ʕ≖ᴥ≖ʔ', label: 'Mad', myCubit: myCubit),

                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Task list section!
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(25.0),
                    color: Colors.grey[100],
                    child: Column(
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Task List',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.lightBlue,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: state.taskList.length,
                            itemBuilder: (context, index) {
                              return TaskWidget(
                                taskName: state.taskList[index][0],
                                completedTask: state.taskList[index][1],
                                onChanged: (value) => myCubit.updateTaskCompletion(value, index),
                                deleteTask: (context) => myCubit.deleteTask(index),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => createTask(context, myCubit),
            backgroundColor: Colors.white,
            child: const Icon(
              Icons.add,
              color: Color(0xFF81D4FA),
              size: 30.0,
            ),
          ),
        );
      },
    );
  }
}
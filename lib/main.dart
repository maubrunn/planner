import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dayview.dart';
import 'constants.dart';
import 'data.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => AppState(),
            child: MaterialApp(
                title: 'Agenda',
                theme: ThemeData(
                useMaterial3: true,
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
                ),
                home: HomePage(),
            ),
        );
    } 
}

class AppState extends ChangeNotifier {
  var currentDate = DateTime.now();
  final Cache cache = Cache();

  void changeDate(DateTime newDate) {
    currentDate = newDate;
    notifyListeners(); // Notify listeners to rebuild widgets that depend on this state
  }

  
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();
    final screenHeight = MediaQuery.of(context).size.height;
    final barHeight = screenHeight * 0.05;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [gradientStart, gradientEnd],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [barHeight / screenHeight, 1 - barHeight / screenHeight],
          ),
        ),
        child: Column(
          children: [
            // Top Bar
            SizedBox(
              height: barHeight,
              width: double.infinity,
              child: Container(
                color: gradientStart,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Daily Planner',
                      style: TextStyle(color: textColor, fontSize: 24, fontStyle: FontStyle.italic, fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
              ),
            ),

            // Main content with resizable space
            Expanded(
              child: DayView(), // No need to pass currentDay
            ),

            // Navbar with dynamic height and button
            SizedBox(
              height: barHeight,
              child: Container(
                color: gradientEnd,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Button to change the date
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: textColor),
                      onPressed: () {
                        // Change the date in AppState
                        appState.changeDate(appState.currentDate.subtract(const Duration(days: 1)));
                      },
                    ),
                    
                    IconButton(
                        icon: const Icon(Icons.swipe_down_alt, color: textColor),
                        onPressed: () {
                        appState.changeDate(DateTime.now());
                        },
                    ),
                    IconButton(
                        icon: const Icon(Icons.calendar_today, color: textColor),
                        onPressed: () async {
                        DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: appState.currentDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
                            appState.changeDate(pickedDate);
                        }
                        },
                    ),
                    
                    // Button to change the date
                    IconButton(
                      icon: const Icon(Icons.arrow_forward, color: textColor),
                      onPressed: () {
                        // Change the date in AppState
                        appState.changeDate(appState.currentDate.add(const Duration(days: 1)));
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
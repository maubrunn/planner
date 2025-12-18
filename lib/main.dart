import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'dayview.dart';
import 'constants.dart';
import 'data.dart';
import 'settings.dart';



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
  var settings = <String, String>{};


  void changeDate(DateTime newDate) {
    currentDate = newDate;
    notifyListeners(); // Notify listeners to rebuild widgets that depend on this state
  } 

  void changeSettings(BuildContext context) async {
    settings = await openSettings(context, cache);
  }    
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();
    final screenHeight = MediaQuery.of(context).size.height;
    final topBarHeight = screenHeight * 0.05;
    final bottomBarHeight = screenHeight * 0.075;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [gradientStart, gradientEnd],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [topBarHeight / screenHeight, 1 - bottomBarHeight / screenHeight],
          ),
        ),
        child: Column(
          children: [
            // Top Bar
           SizedBox(
            height: topBarHeight,
            width: double.infinity,
            child: Container(
                color: gradientStart,
                child: Stack(
                alignment: Alignment.center,
                children: [],
                    ),
                ),
                ),
            
            // Main content with resizable space
            Expanded(
              child: DayView(), // No need to pass currentDay
            ),

            // Navbar with dynamic height and button
            SizedBox(
              height: bottomBarHeight,
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
                            icon: Icon(Icons.settings, color: textColor),
                            onPressed: () => openSettings(context, appState.cache), 
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
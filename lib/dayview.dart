import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:planner/main.dart';
import 'package:provider/provider.dart';
import 'constants.dart';

class DayView extends StatefulWidget {
  const DayView({super.key});

  @override
  _DayViewState createState() => _DayViewState();
}

class _DayViewState extends State<DayView> {
  List<String> plans = [];
  bool loaded = false;

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadPlans(); // Reload plans when dependencies change (e.g., AppState changes)
  }

  Future<void> _loadPlans() async {
    final appState = context.read<AppState>(); // Access AppState

    setState(() {
      loaded = false; // Show loading indicator
    });

    final plansFromCache = await appState.cache.getPlans(appState.currentDate);

    setState(() {
      plans = plansFromCache;
      loaded = true;
    });
  }

  void __deletePlan(String plan) async {
    print("Deleting plan: $plan");
    final appState = context.read<AppState>();
    appState.cache.deletePlan(appState.currentDate, plan);
    final updatedPlans = await appState.cache.getPlans(appState.currentDate);
    setState(() {
      plans = updatedPlans;
    });
  }

  void _addPlan(String plan, int index) async {
    print("Adding plan: $plan at index: $index");
    final appState = context.read<AppState>();
    appState.cache.addPlan(appState.currentDate, plan, cacheIndex: index);
    final updatedPlans = await appState.cache.getPlans(appState.currentDate);
    setState(() {
      plans = updatedPlans;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>(); // Watch AppState for changes
    var monthName = DateFormat.MMMM().format(appState.currentDate);
    var dayName = DateFormat.EEEE().format(appState.currentDate);

    return Container(
      color: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Date Display
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Day
                SizedBox(
                  width: 120,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "${appState.currentDate.day}",
                        style: const TextStyle(
                          fontSize: 60,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                          height: 0.9, // Adjust line height to reduce space
                        ),
                      ),
                      Text(
                        dayName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ),
                // Month and Year
                SizedBox(
                  width: 150,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        monthName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      Text(
                        "${appState.currentDate.year}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(
            color: textColor,
            thickness: 2,
            indent: 20,
            endIndent: 20,
          ),
          // Empty Plan Item with Fixed Size
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: SizedBox(
              height: 80, // Fixed height for the empty PlanItem
              child: PlanItem(
                title: "",
                onSaved: (String newPlan) {
                  _addPlan(newPlan, -1); // Add new plan
                },
                onDelete: (String plan) {},
              ),
            ),
          ),
          // Scrollable List of Plans
          Expanded(
            child: loaded
                ? ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    itemCount: plans.length,
                    itemBuilder: (context, index) {
                      return PlanItem(
                        title: plans[index],
                        onSaved: (String newPlan) {
                          _addPlan(newPlan, index); // Update existing plan
                        },
                        onDelete: (String plan) {
                          __deletePlan(plan); // Delete plan
                        },
                      );
                    },
                  )
                : const Center(
                    child:
                        CircularProgressIndicator(), // Show loading indicator
                  ),
          ),
        ],
      ),
    );
  }
}

class PlanItem extends StatefulWidget {
  final String title;
  final ValueChanged<String> onSaved;
  final ValueChanged<String> onDelete;

  const PlanItem(
      {required this.title,
      required this.onSaved,
      required this.onDelete,
      super.key});

  @override
  _PlanItemState createState() => _PlanItemState();
}

class _PlanItemState extends State<PlanItem> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.title);
  }

  @override
  void didUpdateWidget(covariant PlanItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.title != widget.title) {
      _controller.text = widget.title;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSubmit(String value) {
    if (value.isNotEmpty) {
      widget.onSaved(value);
      if (widget.title == "") {
        _controller.clear();
      }
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Add a new plan",
                hintStyle: TextStyle(
                  color: textColor,
                  fontSize: 18,
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: textColor), // Line color when not focused
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors.purple,
                      width: 2.0), // Line color when focused
                ),
              ),
              onFieldSubmitted: _handleSubmit,
              validator: (String? value) {
                return null;
              },
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
              textAlign: TextAlign.start,
              textAlignVertical: TextAlignVertical.center,
            ),
          ),
          // Conditionally show the delete button only for non-empty plans
          if (widget.title.isNotEmpty)
            IconButton(
              icon: Icon(Icons.delete, color: textColor),
              onPressed: () =>
                  widget.onDelete(widget.title), // Call the delete function
            ),
        ],
      ),
    );
  }
}

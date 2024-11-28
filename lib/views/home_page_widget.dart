import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:task_champ/components/navbar_widget.dart';
import 'package:task_champ/controllers/task_creation_contorller.dart';

import '/components/task_tile_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import '../models/home_page_model.dart';
export '../models/home_page_model.dart';

class HomePageWidget extends StatefulWidget {
  const HomePageWidget({super.key});

  @override
  State<HomePageWidget> createState() => _HomePageWidgetState();
}

DateTime today = DateTime.now();
ValueNotifier<DateTime> selectedDate = ValueNotifier<DateTime>(today);

class _HomePageWidgetState extends State<HomePageWidget>
    with TickerProviderStateMixin {
  late HomePageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final TaskController _taskController = Get.put(TaskController());

  DateTime today = DateTime.now();
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = today; // Initialize with today
    _model = createModel(context, () => HomePageModel());

    _model.tabBarController = TabController(
      vsync: this,
      length: 3,
      initialIndex: 0,
    )..addListener(() => safeSetState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _taskController.listenToTasksForDate(selectedDate);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
          body: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              AnimatedContainer(
                duration: Duration(milliseconds: 100),
                curve: Curves.easeIn,
                width: double.infinity,
                height: 138,
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).primaryBackground,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(27),
                    bottomRight: Radius.circular(27),
                    topLeft: Radius.circular(0),
                    topRight: Radius.circular(0),
                  ),
                  border: Border.all(
                    color: FlutterFlowTheme.of(context).primary,
                  ),
                ),
                child: Align(
                  alignment: AlignmentDirectional(0, 1),
                  child: Container(
                    width: double.infinity,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                        topLeft: Radius.circular(0),
                        topRight: Radius.circular(0),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Container(
                                height: 47,
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          13, 0, 0, 0),
                                      child: Text(
                                        DateTime.now().month == 1
                                            ? 'January'
                                            : DateTime.now().month == 2
                                                ? 'February'
                                                : DateTime.now().month == 3
                                                    ? 'March'
                                                    : DateTime.now().month == 4
                                                        ? 'April'
                                                        : DateTime.now()
                                                                    .month ==
                                                                5
                                                            ? 'May'
                                                            : DateTime.now()
                                                                        .month ==
                                                                    6
                                                                ? 'June'
                                                                : DateTime.now()
                                                                            .month ==
                                                                        7
                                                                    ? 'July'
                                                                    : DateTime.now().month ==
                                                                            8
                                                                        ? 'August'
                                                                        : DateTime.now().month ==
                                                                                9
                                                                            ? 'September'
                                                                            : DateTime.now().month == 10
                                                                                ? 'October'
                                                                                : DateTime.now().month == 11
                                                                                    ? 'November'
                                                                                    : DateTime.now().month == 12
                                                                                        ? 'December'
                                                                                        : '', // Update dynamically if needed
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily: 'Plus Jakarta Sans',
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ),
                                    FlutterFlowIconButton(
                                      borderRadius: 0,
                                      buttonSize: 40,
                                      icon: Icon(
                                        Icons.keyboard_arrow_down,
                                        color: FlutterFlowTheme.of(context)
                                            .primaryText,
                                        size: 24,
                                      ),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: Text('Select Month'),
                                              content: SizedBox(
                                                width: 200,
                                                child: DropdownButtonFormField(
                                                  isExpanded: true,
                                                  decoration: InputDecoration(
                                                    border:
                                                        OutlineInputBorder(),
                                                  ),
                                                  items: [
                                                    'January',
                                                    'February',
                                                    'March',
                                                    'April',
                                                    'May',
                                                    'June',
                                                    'July',
                                                    'August',
                                                    'September',
                                                    'October',
                                                    'November',
                                                    'December',
                                                  ].map((month) {
                                                    return DropdownMenuItem(
                                                      child: Text(month),
                                                      value: month,
                                                    );
                                                  }).toList(),
                                                  onChanged: (value) {
                                                    Navigator.of(context).pop();
                                                    setState(() {
                                                      selectedDate = DateTime(
                                                        DateTime.now().year,
                                                        [
                                                              'January',
                                                              'February',
                                                              'March',
                                                              'April',
                                                              'May',
                                                              'June',
                                                              'July',
                                                              'August',
                                                              'September',
                                                              'October',
                                                              'November',
                                                              'December',
                                                            ].indexOf(value!) +
                                                            1,
                                                        selectedDate.day,
                                                      );
                                                    });
                                                  },
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(0, 0, 10, 0),
                              child: Container(
                                width: 40,
                                height: 40,
                                clipBehavior: Clip.antiAlias,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                ),
                                child: Image.network(
                                  'https://images.unsplash.com/photo-1633332755192-727a05c4013d?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHNlYXJjaHwyNHx8dXNlcnxlbnwwfHx8fDE3MzIwOTMzMTl8MA&ixlib=rb-4.0.3&q=80&w=1080',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Align(
                          alignment: AlignmentDirectional(0, 0),
                          child: Padding(
                            padding:
                                EdgeInsetsDirectional.fromSTEB(14, 4, 14, 9),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: List.generate(7, (index) {
                                DateTime day = today.add(Duration(
                                    days: index -
                                        today.weekday +
                                        1)); // Start from Sunday
                                bool isSelected = day.day == selectedDate.day &&
                                    day.month == selectedDate.month;

                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedDate = day;
                                      print(selectedDate);
                                    });
                                  },
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isSelected
                                          ? FlutterFlowTheme.of(context).primary
                                          : null,
                                    ),
                                    child: Align(
                                      alignment: AlignmentDirectional(0, 0),
                                      child: Text(
                                        isSelected
                                            ? day.day.toString()
                                            : DateFormat('EEE').format(day),
                                        textAlign: TextAlign.center,
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily: 'Plus Jakarta Sans',
                                              color: isSelected
                                                  ? FlutterFlowTheme.of(context)
                                                      .primaryBackground
                                                  : null,
                                              fontWeight: isSelected
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                            ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Align(
                      alignment: const Alignment(0.0, 0),
                      child: TabBar(
                        labelColor: FlutterFlowTheme.of(context).primaryText,
                        unselectedLabelColor:
                            FlutterFlowTheme.of(context).secondaryText,
                        labelStyle:
                            FlutterFlowTheme.of(context).titleMedium.override(
                                  fontFamily: 'Plus Jakarta Sans',
                                  letterSpacing: 0.0,
                                ),
                        unselectedLabelStyle:
                            FlutterFlowTheme.of(context).titleMedium.override(
                                  fontFamily: 'Plus Jakarta Sans',
                                  letterSpacing: 0.0,
                                ),
                        indicatorColor: FlutterFlowTheme.of(context).primary,
                        tabs: const [
                          Tab(
                            text: 'Tasks',
                          ),
                          Tab(
                            text: 'Priority ',
                          ),
                          Tab(
                            text: 'Stats',
                          ),
                        ],
                        controller: _model.tabBarController,
                        onTap: (i) async {
                          [() async {}, () async {}, () async {}][i]();
                        },
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _model.tabBarController,
                        children: [
                          Obx(() {
                            if (_taskController.isLoading.value) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            if (_taskController.errorMessage.value.isNotEmpty) {
                              return Center(
                                  child: Text(
                                      'Error: ${_taskController.errorMessage.value}'));
                            }

                            final tasksForSelectedDate =
                                _taskController.tasksForSelectedDate;

                            if (tasksForSelectedDate.isEmpty) {
                              return const Center(
                                child: Text(
                                    'No tasks available for the selected date'),
                              );
                            }

                            return ListView.builder(
                              itemCount: tasksForSelectedDate.length,
                              itemBuilder: (context, index) {
                                final task = tasksForSelectedDate[index];
                                return TaskTileWidget(
                                  title: task['title'] ?? 'Untitled Task',
                                  tags: (task['tags'] is List<dynamic>
                                          ? (task['tags'] as List<dynamic>)
                                          : (task['tags'] is String
                                              ? [task['tags']]
                                              : []))
                                      .cast<String>(),
                                  dueDate: (task['dueDate'] != null)
                                      ? (task['dueDate'] is String
                                          ? DateTime.parse(task['dueDate'])
                                          : (task['dueDate'] is Timestamp
                                              ? (task['dueDate'] as Timestamp)
                                                  .toDate()
                                              : DateTime.now()))
                                      : DateTime.now(),
                                  isCompleted: task['isCompleted'] ?? false,
                                );
                              },
                            );
                          }),
                          const Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [Text("hello")],
                          ),
                          const Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

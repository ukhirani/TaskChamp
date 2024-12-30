import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:task_champ/components/navbar_widget.dart';
import 'package:task_champ/controllers/task_creation_contorller.dart';

import '/components/task_tile_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../models/home_page_model.dart';
import 'package:task_champ/views/profile_page_widget.dart';
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
                  border: Border(
                    top: BorderSide.none,
                    bottom:
                        BorderSide(color: FlutterFlowTheme.of(context).primary),
                    left:
                        BorderSide(color: FlutterFlowTheme.of(context).primary),
                    right:
                        BorderSide(color: FlutterFlowTheme.of(context).primary),
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
                            GestureDetector(
                              onTap: () =>
                                  Get.to(() => const ProfilePageWidget()),
                              child: Container(
                                constraints: const BoxConstraints(
                                  maxWidth: 40,
                                  maxHeight: 40,
                                ),
                                margin: const EdgeInsets.only(right: 12),
                                child: CircleAvatar(
                                  radius: 20,
                                  backgroundColor: FlutterFlowTheme.of(context)
                                      .primary
                                      .withOpacity(0.2),
                                  child: Icon(
                                    Icons.account_circle_rounded,
                                    color: FlutterFlowTheme.of(context).primary,
                                    size: 30,
                                  ),
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
                            // Show loading animation while tasks are being fetched
                            if (_taskController.isLoading.value) {
                              return Center(
                                child: Lottie.asset(
                                  'assets/tick.json',
                                  width: 200,
                                  height: 200,
                                  fit: BoxFit.contain,
                                  repeat: true,
                                  errorBuilder: (context, error, stackTrace) {
                                    print('Lottie animation error: $error');
                                    print(
                                        'Lottie animation stackTrace: $stackTrace');
                                    return Text(
                                      'Loading...',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium,
                                    );
                                  },
                                  frameBuilder: (context, child, composition) {
                                    if (composition == null) {
                                      print('Lottie composition is null');
                                      return Text(
                                        'Loading animation...',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium,
                                      );
                                    }
                                    return child;
                                  },
                                ),
                              );
                            }

                            // Show error message if there's an error
                            if (_taskController.errorMessage.value.isNotEmpty) {
                              return Center(
                                child: Text(
                                  _taskController.errorMessage.value,
                                  style:
                                      FlutterFlowTheme.of(context).bodyMedium,
                                ),
                              );
                            }

                            // Show tasks if available
                            final tasks = _taskController.tasksForSelectedDate;
                            if (tasks.isEmpty) {
                              return Center(
                                child: Text(
                                  'No tasks for today',
                                  style:
                                      FlutterFlowTheme.of(context).bodyMedium,
                                ),
                              );
                            }

                            return ListView.builder(
                              itemCount: tasks.length,
                              itemBuilder: (context, index) {
                                final task = tasks[index];
                                return TaskTileWidget(
                                  title: task['title'],
                                  tags: task['tags'] is String
                                      ? (task['tags'] as String)
                                          .split(',')
                                          .map((e) => e.trim())
                                          .where((e) => e.isNotEmpty)
                                          .toList()
                                      : (task['tags'] as List<dynamic>?)
                                              ?.map((e) => e.toString())
                                              .toList() ??
                                          [],
                                  dueDate: task['dueDate'] ?? DateTime.now(),
                                  isCompleted: task['isCompleted'] ?? false,
                                  isRoutine: task['isRoutine'] ?? false,
                                  routineName: task['routineName'] ?? '',
                                  routineColor: Color(task['routineColor'] ??
                                      Colors.blue.value),
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

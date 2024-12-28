import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:task_champ/controllers/add_routine_controller.dart';
import 'package:task_champ/controllers/routine_import_controller.dart';

import '/flutter_flow/flutter_flow_button_tabbar.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_choice_chips.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/routine_list_model.dart';
import '../models/add_routine_model.dart';

export '../models/routine_list_model.dart';

class Hello {
  String title;
  String dueTime;
  List<String> selectedDays;
  String? routineId;

  Hello(
      {required this.title,
      required this.dueTime,
      required this.selectedDays,
      this.routineId});
}

class AddRoutineWidget extends StatefulWidget {
  const AddRoutineWidget({super.key});

  @override
  State<AddRoutineWidget> createState() => _AddRoutineWidgetState();
}

class _AddRoutineWidgetState extends State<AddRoutineWidget>
    with TickerProviderStateMixin {
  late AddRoutineModel _model;

  final List<Hello> tasks = []; // List to hold tasks

  final TextEditingController titleController = TextEditingController();
  final TextEditingController dateController = TextEditingController(
    text: DateTime.now().toString().split(' ')[0],
  );
  FormFieldController<List<String>> scheduleController =
      FormFieldController<List<String>>([]);

  List<String> selectedDays = []; // Holds selected days of the week

  final scaffoldKey = GlobalKey<ScaffoldState>();

  String? importedRoutineName;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AddRoutineModel());
    AddRoutineController _addRoutineController =
        Get.put(AddRoutineController());
    RoutineImportController _routineImportController =
        Get.put(RoutineImportController());

    _model.tabBarController = TabController(
      vsync: this,
      length: 2,
      initialIndex: 0,
    )..addListener(() => safeSetState(() {}));
    _model.textController1 ??= TextEditingController();
    _model.textFieldFocusNode1 ??= FocusNode();

    _model.textController2 ??= TextEditingController();
    _model.textFieldFocusNode2 ??= FocusNode();

    _model.textController3 ??= TextEditingController();
    _model.textFieldFocusNode3 ??= FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderColor: Colors.transparent,
            borderRadius: 30,
            borderWidth: 1,
            buttonSize: 60,
            icon: Icon(
              Icons.arrow_back_rounded,
              color: FlutterFlowTheme.of(context).primaryText,
              size: 30,
            ),
            onPressed: () {
              print('IconButton pressed ...');
            },
          ),
          actions: [],
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              'Routine Generator',
              style: FlutterFlowTheme.of(context).headlineMedium.override(
                    fontFamily: 'Urbanist',
                    letterSpacing: 0.0,
                  ),
            ),
            centerTitle: true,
            expandedTitleScale: 1.0,
          ),
          elevation: 0,
        ),
        body: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            children: [
              Align(
                alignment: Alignment(0, 0),
                child: FlutterFlowButtonTabBar(
                  useToggleButtonStyle: true,
                  labelStyle: FlutterFlowTheme.of(context).titleMedium.override(
                        fontFamily: 'Plus Jakarta Sans',
                        letterSpacing: 0.0,
                      ),
                  unselectedLabelStyle:
                      FlutterFlowTheme.of(context).titleMedium.override(
                            fontFamily: 'Plus Jakarta Sans',
                            letterSpacing: 0.0,
                          ),
                  labelColor: FlutterFlowTheme.of(context).primaryBackground,
                  unselectedLabelColor:
                      FlutterFlowTheme.of(context).secondaryText,
                  backgroundColor: FlutterFlowTheme.of(context).primary,
                  unselectedBackgroundColor:
                      FlutterFlowTheme.of(context).alternate,
                  borderColor: FlutterFlowTheme.of(context).primary,
                  unselectedBorderColor: FlutterFlowTheme.of(context).alternate,
                  borderWidth: 2,
                  borderRadius: 8,
                  elevation: 0,
                  buttonMargin: EdgeInsetsDirectional.fromSTEB(8, 0, 8, 0),
                  tabs: [
                    Tab(
                      text: 'Create',
                    ),
                    Tab(
                      text: 'Import',
                    ),
                  ],
                  controller: _model.tabBarController,
                  onTap: (i) async {
                    [() async {}, () async {}][i]();
                  },
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _model.tabBarController,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  width: MediaQuery.sizeOf(context).width,
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            12, 18, 12, 0),
                                        child: TextFormField(
                                          controller: titleController,
                                          focusNode: _model.textFieldFocusNode1,
                                          autofocus: false,
                                          obscureText: false,
                                          decoration: InputDecoration(
                                            labelText: 'Enter Task Title',
                                            labelStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .override(
                                                      fontFamily:
                                                          'Plus Jakarta Sans',
                                                      letterSpacing: 0.0,
                                                    ),
                                            hintStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .override(
                                                      fontFamily:
                                                          'Plus Jakarta Sans',
                                                      letterSpacing: 0.0,
                                                    ),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .alternate,
                                                width: 1.0,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Color(0x00000000),
                                                width: 1.0,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Color(0x00000000),
                                                width: 1.0,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            focusedErrorBorder:
                                                OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Color(0x00000000),
                                                width: 1.0,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            filled: true,
                                            fillColor:
                                                FlutterFlowTheme.of(context)
                                                    .secondaryBackground,
                                          ),
                                          style: FlutterFlowTheme.of(context)
                                              .bodyLarge
                                              .override(
                                                fontFamily: 'Plus Jakarta Sans',
                                                letterSpacing: 0.0,
                                              ),
                                          minLines: 1,
                                          validator: _model
                                              .textController1Validator
                                              .asValidator(context),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            12, 18, 12, 0),
                                        child: TextFormField(
                                          controller: dateController,
                                          focusNode: _model.textFieldFocusNode2,
                                          autofocus: false,
                                          obscureText: false,
                                          readOnly: true,
                                          decoration: InputDecoration(
                                            labelText: 'Enter Task Time',
                                            labelStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .override(
                                                      fontFamily:
                                                          'Plus Jakarta Sans',
                                                      letterSpacing: 0.0,
                                                    ),
                                            hintStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .override(
                                                      fontFamily:
                                                          'Plus Jakarta Sans',
                                                      letterSpacing: 0.0,
                                                    ),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .alternate,
                                                width: 1.0,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Color(0x00000000),
                                                width: 1.0,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Color(0x00000000),
                                                width: 1.0,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            focusedErrorBorder:
                                                OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Color(0x00000000),
                                                width: 1.0,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            filled: true,
                                            fillColor:
                                                FlutterFlowTheme.of(context)
                                                    .secondaryBackground,
                                          ),
                                          style: FlutterFlowTheme.of(context)
                                              .bodyLarge
                                              .override(
                                                fontFamily: 'Plus Jakarta Sans',
                                                letterSpacing: 0.0,
                                              ),
                                          minLines: 1,
                                          validator: _model
                                              .textController2Validator
                                              .asValidator(context),
                                          onTap: () async {
                                            TimeOfDay? newTime =
                                                await showTimePicker(
                                              context: context,
                                              initialTime: TimeOfDay.now(),
                                              builder: (context, child) {
                                                return Theme(
                                                  data:
                                                      ThemeData.dark().copyWith(
                                                    colorScheme:
                                                        ColorScheme.dark(
                                                      primary:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primary,
                                                      surface: FlutterFlowTheme
                                                              .of(context)
                                                          .secondaryBackground,
                                                    ),
                                                    timePickerTheme:
                                                        TimePickerThemeData(
                                                      dayPeriodColor:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primary
                                                              .withOpacity(0.2),
                                                      dayPeriodTextColor:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primaryText,
                                                      dayPeriodBorderSide:
                                                          BorderSide(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        width: 2,
                                                      ),
                                                    ),
                                                  ),
                                                  child: child!,
                                                );
                                              },
                                            );
                                            if (newTime != null) {
                                              setState(() {
                                                dateController.text =
                                                    newTime.format(context);
                                              });
                                            }
                                          },
                                        ),
                                      ),
                                      Container(
                                        width: MediaQuery.sizeOf(context).width,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          shape: BoxShape.rectangle,
                                        ),
                                        child: Align(
                                          alignment: AlignmentDirectional(0, 0),
                                          child: Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    0, 16, 0, 16),
                                            child: SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: Row(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  FlutterFlowChoiceChips(
                                                    options: [
                                                      ChipData('S'),
                                                      ChipData('M'),
                                                      ChipData('T'),
                                                      ChipData('W'),
                                                      ChipData('Th'),
                                                      ChipData('F'),
                                                      ChipData('Sa')
                                                    ],
                                                    onChanged: (val) =>
                                                        safeSetState(() => _model
                                                                .choiceChipsValues =
                                                            val),
                                                    selectedChipStyle:
                                                        ChipStyle(
                                                      backgroundColor:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primary,
                                                      textStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMedium
                                                              .override(
                                                                fontFamily:
                                                                    'Plus Jakarta Sans',
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .primaryBackground,
                                                                letterSpacing:
                                                                    0.0,
                                                              ),
                                                      iconColor:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primaryBackground,
                                                      iconSize: 0,
                                                      elevation: 0,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              24),
                                                    ),
                                                    unselectedChipStyle:
                                                        ChipStyle(
                                                      backgroundColor:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primaryBackground,
                                                      textStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodySmall
                                                              .override(
                                                                fontFamily:
                                                                    'Plus Jakarta Sans',
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .secondaryText,
                                                                letterSpacing:
                                                                    0.0,
                                                              ),
                                                      iconColor:
                                                          Color(0x00000000),
                                                      iconSize: 0,
                                                      elevation: 0,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              16),
                                                    ),
                                                    chipSpacing: 0,
                                                    rowSpacing: 0,
                                                    multiselect: true,
                                                    initialized: _model
                                                            .choiceChipsValues !=
                                                        null,
                                                    alignment:
                                                        WrapAlignment.start,
                                                    controller: _model
                                                            .choiceChipsValueController ??=
                                                        FormFieldController<
                                                            List<String>>(
                                                      [],
                                                    ),
                                                    wrapped: false,
                                                    multiSelect: true,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: MediaQuery.sizeOf(context).width,
                                        decoration: BoxDecoration(
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  16, 16, 16, 16),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Row(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    'Added Tasks',
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .titleMedium
                                                        .override(
                                                          fontFamily:
                                                              'Plus Jakarta Sans',
                                                          letterSpacing: 0.0,
                                                        ),
                                                  ),
                                                  FlutterFlowIconButton(
                                                    borderColor:
                                                        Colors.transparent,
                                                    borderRadius: 20,
                                                    buttonSize: 40,
                                                    fillColor:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .primary,
                                                    icon: Icon(
                                                      Icons.add_rounded,
                                                      color: FlutterFlowTheme
                                                              .of(context)
                                                          .primaryBackground,
                                                      size: 24,
                                                    ),
                                                    onPressed: _addTask,
                                                  ),
                                                ],
                                              ),
                                              ListView.builder(
                                                padding: EdgeInsets.zero,
                                                primary: false,
                                                shrinkWrap: true,
                                                scrollDirection: Axis.vertical,
                                                itemCount: tasks.length,
                                                itemBuilder: (context, index) {
                                                  return Container(
                                                    width: MediaQuery.sizeOf(
                                                            context)
                                                        .width,
                                                    decoration: BoxDecoration(
                                                      color: FlutterFlowTheme
                                                              .of(context)
                                                          .primaryBackground,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(16, 16,
                                                                  16, 16),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                tasks[index]
                                                                    .title,
                                                                style: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyLarge
                                                                    .override(
                                                                      fontFamily:
                                                                          'Plus Jakarta Sans',
                                                                      letterSpacing:
                                                                          0.0,
                                                                    ),
                                                              ),
                                                              Text(
                                                                tasks[index]
                                                                    .selectedDays
                                                                    .join(', '),
                                                                style: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodySmall
                                                                    .override(
                                                                      fontFamily:
                                                                          'Plus Jakarta Sans',
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .secondaryText,
                                                                      letterSpacing:
                                                                          0.0,
                                                                    ),
                                                              ),
                                                            ],
                                                          ),
                                                          Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .max,
                                                            children: [
                                                              FlutterFlowIconButton(
                                                                borderColor: Colors
                                                                    .transparent,
                                                                borderRadius:
                                                                    20,
                                                                buttonSize: 40,
                                                                fillColor:
                                                                    FlutterFlowTheme.of(
                                                                            context)
                                                                        .accent2,
                                                                icon: Icon(
                                                                  Icons.edit,
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .info,
                                                                  size: 20,
                                                                ),
                                                                onPressed: () {
                                                                  print(
                                                                      'IconButton pressed ...');
                                                                },
                                                              ),
                                                              FlutterFlowIconButton(
                                                                borderColor: Colors
                                                                    .transparent,
                                                                borderRadius:
                                                                    20,
                                                                buttonSize: 40,
                                                                fillColor:
                                                                    FlutterFlowTheme.of(
                                                                            context)
                                                                        .error,
                                                                icon: Icon(
                                                                  Icons.delete,
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .info,
                                                                  size: 20,
                                                                ),
                                                                onPressed: () {
                                                                  print(
                                                                      'IconButton pressed ...');
                                                                },
                                                              ),
                                                            ].divide(SizedBox(
                                                                width: 8)),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                FFButtonWidget(
                                  onPressed: _addRoutine,
                                  text: 'Add Routine',
                                  options: FFButtonOptions(
                                    width: MediaQuery.sizeOf(context).width *
                                        0.728,
                                    height: 50,
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0, 0, 0, 0),
                                    iconAlignment: IconAlignment.start,
                                    iconPadding: EdgeInsetsDirectional.fromSTEB(
                                        0, 0, 0, 0),
                                    color: FlutterFlowTheme.of(context).primary,
                                    textStyle: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .override(
                                          fontFamily: 'Plus Jakarta Sans',
                                          color: FlutterFlowTheme.of(context)
                                              .primaryBackground,
                                          letterSpacing: 0.0,
                                        ),
                                    elevation: 2,
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                                Container(
                                  width: MediaQuery.sizeOf(context).width,
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                Container(
                                  width: MediaQuery.sizeOf(context).width,
                                  height: 0,
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                  ),
                                ),
                              ].divide(SizedBox(height: 24)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Padding(
                          padding:
                              EdgeInsetsDirectional.fromSTEB(16, 16, 16, 16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    width: 273,
                                    child: TextFormField(
                                      controller: _model.textController3,
                                      focusNode: _model.textFieldFocusNode3,
                                      autofocus: false,
                                      obscureText: false,
                                      decoration: InputDecoration(
                                        labelText: 'Enter Routine Code',
                                        labelStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily: 'Plus Jakarta Sans',
                                              letterSpacing: 0.0,
                                            ),
                                        hintStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily: 'Plus Jakarta Sans',
                                              letterSpacing: 0.0,
                                            ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: FlutterFlowTheme.of(context)
                                                .alternate,
                                            width: 1.0,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Color(0x00000000),
                                            width: 1.0,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Color(0x00000000),
                                            width: 1.0,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Color(0x00000000),
                                            width: 1.0,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        filled: true,
                                        fillColor: FlutterFlowTheme.of(context)
                                            .secondaryBackground,
                                      ),
                                      style: FlutterFlowTheme.of(context)
                                          .bodyLarge
                                          .override(
                                            fontFamily: 'Plus Jakarta Sans',
                                            fontSize: 18,
                                            letterSpacing: 0.0,
                                          ),
                                      minLines: 1,
                                      validator: _model.textController3Validator
                                          .asValidator(context),
                                    ),
                                  ),
                                  FlutterFlowIconButton(
                                    borderRadius: 8,
                                    buttonSize: 54,
                                    fillColor:
                                        FlutterFlowTheme.of(context).warning,
                                    icon: Icon(
                                      Icons.search_rounded,
                                      color: FlutterFlowTheme.of(context)
                                          .primaryBackground,
                                      size: 24,
                                    ),
                                    onPressed: () {
                                      _importRoutine(
                                          _model.textController3.text);
                                    },
                                  ),
                                ],
                              ),
                            ].divide(SizedBox(height: 16)),
                          ),
                        ),
                        Container(
                          width: MediaQuery.sizeOf(context).width,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding:
                                EdgeInsetsDirectional.fromSTEB(16, 16, 16, 16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (tasks.isNotEmpty ||
                                    importedRoutineName != null)
                                  Container(
                                    width: double.infinity,
                                    margin: EdgeInsetsDirectional.fromSTEB(
                                        0, 0, 0, 12),
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        16, 12, 16, 12),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          FlutterFlowTheme.of(context)
                                              .primary
                                              .withOpacity(0.1),
                                          FlutterFlowTheme.of(context)
                                              .primary
                                              .withOpacity(0.05),
                                        ],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: FlutterFlowTheme.of(context)
                                            .primary
                                            .withOpacity(0.2),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.import_contacts_rounded,
                                          color: FlutterFlowTheme.of(context)
                                              .primary,
                                          size: 24,
                                        ),
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            importedRoutineName ??
                                                'Imported Routine',
                                            style: FlutterFlowTheme.of(context)
                                                .titleLarge
                                                .override(
                                                  fontFamily:
                                                      'Plus Jakarta Sans',
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primary,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ListView.builder(
                                  padding: EdgeInsets.zero,
                                  primary: false,
                                  shrinkWrap: true,
                                  scrollDirection: Axis.vertical,
                                  itemCount: tasks.length,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      width: MediaQuery.sizeOf(context).width,
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context)
                                            .primaryBackground,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            16, 16, 16, 16),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  tasks[index].title,
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyLarge
                                                      .override(
                                                        fontFamily:
                                                            'Plus Jakarta Sans',
                                                        letterSpacing: 0.0,
                                                      ),
                                                ),
                                                Text(
                                                  tasks[index]
                                                      .selectedDays
                                                      .join(', '),
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodySmall
                                                      .override(
                                                        fontFamily:
                                                            'Plus Jakarta Sans',
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .secondaryText,
                                                        letterSpacing: 0.0,
                                                      ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                FlutterFlowIconButton(
                                                  borderColor:
                                                      Colors.transparent,
                                                  borderRadius: 20,
                                                  buttonSize: 40,
                                                  fillColor:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .accent2,
                                                  icon: Icon(
                                                    Icons.edit,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .info,
                                                    size: 20,
                                                  ),
                                                  onPressed: () {
                                                    print(
                                                        'IconButton pressed ...');
                                                  },
                                                ),
                                                FlutterFlowIconButton(
                                                  borderColor:
                                                      Colors.transparent,
                                                  borderRadius: 20,
                                                  buttonSize: 40,
                                                  fillColor:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .error,
                                                  icon: Icon(
                                                    Icons.delete,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .info,
                                                    size: 20,
                                                  ),
                                                  onPressed: () {
                                                    print(
                                                        'IconButton pressed ...');
                                                  },
                                                ),
                                              ].divide(SizedBox(width: 8)),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
                          child: FFButtonWidget(
                            onPressed: _addRoutine,
                            text: 'Add Routine',
                            options: FFButtonOptions(
                              width: MediaQuery.sizeOf(context).width * 0.728,
                              height: 50,
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                              iconAlignment: IconAlignment.start,
                              iconPadding:
                                  EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                              color: FlutterFlowTheme.of(context).primary,
                              textStyle: FlutterFlowTheme.of(context)
                                  .titleSmall
                                  .override(
                                    fontFamily: 'Plus Jakarta Sans',
                                    color: FlutterFlowTheme.of(context)
                                        .primaryBackground,
                                    letterSpacing: 0.0,
                                  ),
                              elevation: 2,
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                        ),
                      ],
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

  void _addTask() {
    // Validate task title
    final title = titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a task title'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate task time
    final selectedTime = dateController.text.trim();
    if (selectedTime.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a task time'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate selected days
    final selectedDays = _model.choiceChipsValues;
    if (selectedDays == null || selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select at least one day for the task'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // If all validations pass, add the task
    setState(() {
      tasks.add(Hello(
        title: title,
        dueTime: selectedTime,
        selectedDays: selectedDays,
      ));

      // Clear input fields
      titleController.clear();
      dateController.clear();

      _model.choiceChipsValues = [];
    });
  }

  Future<void> _addRoutine() async {
    try {
      // Check if we have an imported routine name
      if (importedRoutineName != null && importedRoutineName!.isNotEmpty) {
        // Use the RoutineImportController to import the routine
        final importController = Get.find<RoutineImportController>();

        // Import the routine
        await importController.importRoutine(_model.textController3!.text);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Routine imported successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Reset the imported routine name
        setState(() {
          importedRoutineName = null;
          tasks.clear();
        });

        // Clear the text field
        _model.textController3?.clear();

        return;
      }

      // Check if routine name is already entered
      final routineName = _model.textController1!.text.trim();

      // Validate tasks
      if (tasks.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please add at least one task to the routine'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // If no routine name, show dialog to enter routine name
      if (routineName.isEmpty) {
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            final TextEditingController routineNameController =
                TextEditingController();
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 8,
              backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
              child: Container(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Name Your Routine',
                      style:
                          FlutterFlowTheme.of(context).headlineSmall.override(
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.0,
                              ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Create a meaningful name for your new routine',
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                            color: FlutterFlowTheme.of(context).secondaryText,
                            letterSpacing: 0.0,
                          ),
                    ),
                    SizedBox(height: 24),
                    TextField(
                      controller: routineNameController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Routine name',
                        hintStyle: FlutterFlowTheme.of(context)
                            .bodyMedium
                            .override(
                              letterSpacing: 0.0,
                              color: FlutterFlowTheme.of(context).secondaryText,
                            ),
                        filled: true,
                        fillColor:
                            FlutterFlowTheme.of(context).primaryBackground,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                      style: FlutterFlowTheme.of(context).bodyLarge.override(
                            letterSpacing: 0.0,
                          ),
                    ),
                    SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(
                            'Cancel',
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryText,
                                  letterSpacing: 0.0,
                                ),
                          ),
                        ),
                        SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: () {
                            if (routineNameController.text.isNotEmpty) {
                              _model.textController1?.text =
                                  routineNameController.text.trim();
                              Navigator.of(context).pop();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                FlutterFlowTheme.of(context).primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            elevation: 2,
                          ),
                          child: Text(
                            'Create',
                            style: FlutterFlowTheme.of(context)
                                .titleSmall
                                .override(
                                  color: FlutterFlowTheme.of(context)
                                      .primaryBackground,
                                  letterSpacing: 0.0,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );

        // If user cancelled or didn't enter a name, return
        if (_model.textController1!.text.trim().isEmpty) {
          return;
        }
      }

      // Validate tasks
      List<Map<String, dynamic>> formattedTasks = tasks.map((task) {
        // Validate individual task
        if (task.title.trim().isEmpty) {
          throw Exception('Task title cannot be empty');
        }

        return {
          'title': task.title,
          'dueTime': task.dueTime,
          'selectedDays': task.selectedDays
        };
      }).toList();

      // Add routine
      final addRoutineController = Get.find<AddRoutineController>();
      await addRoutineController.addRoutine(
        _model.textController1!.text.trim(),
        formattedTasks,
      );

      // Clear fields and reset state
      setState(() {
        _model.textController1?.clear();
        tasks.clear();
        importedRoutineName = null;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Routine added successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding routine: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Import routine method
  Future<void> _importRoutine(String routineId) async {
    try {
      // Validate input
      if (routineId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please enter a Routine ID'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Use the RoutineImportController to import the routine
      final importController = Get.find<RoutineImportController>();

      // Fetch the routine details before importing
      final routineDoc = await importController.fetchRoutineById(routineId);

      if (routineDoc == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No routine found with ID: $routineId'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Get the routine name
      final importedRoutineName =
          routineDoc['routine_name'] ?? 'Imported Routine';

      // Fetch tasks for this routine
      final tasksSnapshot =
          await routineDoc.reference.collection('tasks').get();

      // Convert tasks to Hello objects to match existing UI
      List<Hello> importedTasks = tasksSnapshot.docs.map((taskDoc) {
        var taskData = taskDoc.data();
        return Hello(
          title: taskData['title'] ?? '',
          dueTime: taskData['due_time'] ?? '',
          selectedDays: List<String>.from(taskData['selected_days'] ?? []),
          routineId: taskDoc.id,
        );
      }).toList();

      // Set the imported routine name in the state
      setState(() {
        this.importedRoutineName = importedRoutineName;
        tasks.addAll(importedTasks);
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Routine details loaded. Press Add Routine to import.'),
          backgroundColor: Colors.green,
        ),
      );

      // Clear the text field
      _model.textController3?.clear();
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error importing routine: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

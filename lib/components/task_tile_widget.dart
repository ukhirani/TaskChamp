import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_champ/components/category_tag_widget.dart';
import 'package:task_champ/controllers/task_creation_contorller.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';

final TaskController _taskController = Get.put(TaskController());

class TaskTileWidget extends StatelessWidget {
  final String title;
  final List<String> tags;
  final DateTime dueDate;
  final bool isCompleted;
  final bool isRoutine;
  final Color routineColor;

  const TaskTileWidget({
    super.key,
    required this.title,
    required this.tags,
    required this.dueDate,
    required this.isCompleted,
    this.isRoutine = false,
    this.routineColor = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: isRoutine ? routineColor.withOpacity(0.1) : FlutterFlowTheme.of(context).primary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isRoutine ? routineColor : FlutterFlowTheme.of(context).primaryBackground,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(15.0, 0.0, 0.0, 0.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    return Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          0.0, 10.0, 0.0, 0.0),
                      child: Text(
                        title,
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Plus Jakarta Sans',
                              color: isRoutine ? routineColor : FlutterFlowTheme.of(context).primaryBackground,
                              fontSize: 40.0,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.w600,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        // Calculate the maximum width available for the text
                        softWrap: false,
                      ),
                    );
                  },
                ),
                Padding(
                  padding:
                      const EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 6.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: tags.map((tag) {
                      return CategoryTagWidget(category: tag);
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 15.0, 0.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Align(
                  alignment: const AlignmentDirectional(0.0, 0.0),
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        0.0, 5.0, 10.0, 0.0),
                    child: FlutterFlowIconButton(
                      buttonSize: 45.0,
                      fillColor: isCompleted
                          ? FlutterFlowTheme.of(context).primary
                          : FlutterFlowTheme.of(context).primary,
                      icon: Icon(
                        isCompleted ? Icons.check_circle : Icons.circle,
                        color: isCompleted
                            ? FlutterFlowTheme.of(context).primaryBackground
                            : FlutterFlowTheme.of(context).alternate,
                        size: 50.0,
                      ),
                      onPressed: () {
                        print('Task marked as completed: $title');
                        _taskController.updateTaskInDatabase(
                            dueDate, title, isCompleted);
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                      10.0, 20.0, 0.0, 0.0),
                  child: Text(
                    '${dueDate.hour}:${dueDate.minute.toString().padLeft(2, '0')} ${dueDate.hour < 12 ? "AM" : "PM"}',
                    textAlign: TextAlign.end,
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'Plus Jakarta Sans',
                          color: isRoutine ? routineColor : FlutterFlowTheme.of(context).primaryBackground,
                          fontSize: 10.0,
                          letterSpacing: 0.0,
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

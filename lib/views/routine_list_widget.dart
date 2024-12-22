import 'package:task_champ/views/add_routine_widget.dart';
import '/flutter_flow/flutter_flow_button_tabbar.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/show_routines_controller.dart';
import 'package:intl/intl.dart';

class RoutineListWidget extends StatefulWidget {
  const RoutineListWidget({super.key});

  @override
  State<RoutineListWidget> createState() => _RoutineListWidgetState();
}

class _RoutineListWidgetState extends State<RoutineListWidget>
    with TickerProviderStateMixin {
  late final TabController tabController;
  late final ShowRoutinesController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(ShowRoutinesController());
    tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderColor: Colors.transparent,
            borderRadius: 30.0,
            borderWidth: 1.0,
            buttonSize: 60.0,
            icon: Icon(
              Icons.arrow_back_rounded,
              color: FlutterFlowTheme.of(context).primaryText,
              size: 30.0,
            ),
            onPressed: () => context.pushNamed('HomePageWidget'),
          ),
          title: Text(
            'Routines',
            style: FlutterFlowTheme.of(context).titleLarge.override(
                  fontFamily: 'Urbanist',
                  letterSpacing: 0.0,
                ),
          ),
          centerTitle: false,
          elevation: 0.0,
        ),
        body: Column(
          children: [
            _buildTabBar(context),
            Expanded(
              child: TabBarView(
                controller: tabController,
                children: [
                  _buildRoutinesList(true),
                  _buildRoutinesList(false),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Get.to(() => const AddRoutineWidget()),
          label: Text(
            'Add Routine',
            style: FlutterFlowTheme.of(context).titleSmall.override(
                  fontFamily: 'Plus Jakarta Sans',
                  color: FlutterFlowTheme.of(context).primaryBackground,
                ),
          ),
          icon: Icon(
            Icons.add,
            color: FlutterFlowTheme.of(context).primaryBackground,
          ),
          backgroundColor: FlutterFlowTheme.of(context).primary,
        ),
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return FlutterFlowButtonTabBar(
      useToggleButtonStyle: true,
      labelStyle: FlutterFlowTheme.of(context).titleMedium,
      unselectedLabelStyle: FlutterFlowTheme.of(context).titleMedium,
      labelColor: FlutterFlowTheme.of(context).primaryBackground,
      unselectedLabelColor: FlutterFlowTheme.of(context).secondaryText,
      backgroundColor: FlutterFlowTheme.of(context).primary,
      unselectedBackgroundColor: FlutterFlowTheme.of(context).alternate,
      borderColor: FlutterFlowTheme.of(context).primary,
      borderWidth: 2,
      borderRadius: 8,
      elevation: 0,
      tabs: const [
        Tab(text: 'Active'),
        Tab(text: 'Inactive'),
      ],
      controller: tabController,
    );
  }

  Widget _buildRoutinesList(bool isActive) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final routines =
          isActive ? controller.activeRoutines : controller.inactiveRoutines;

      if (routines.isEmpty) {
        return Center(
          child: Text(
            isActive ? 'No active routines' : 'No inactive routines',
            style: FlutterFlowTheme.of(context).labelMedium,
          ),
        );
      }

      return ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: routines.length,
        itemBuilder: (context, index) {
          final routine = routines[index];
          return _buildRoutineCard(routine, isActive);
        },
      );
    });
  }

  Widget _buildRoutineCard(Routine routine, bool isActive) {
    return InkWell(
      onTap: () => _showRoutineDetails(routine, isActive),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 0),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).secondaryBackground,
            boxShadow: const [
              BoxShadow(
                blurRadius: 3,
                color: Color(0x33000000),
                offset: Offset(0, 1),
              )
            ],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _buildRoutineAvatar(routine, isActive),
                _buildRoutineInfo(routine),
                _buildOptionsButton(routine, isActive),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoutineAvatar(Routine routine, bool isActive) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Color(
            (routine.name.hashCode * (isActive ? 0xFF3498db : 0xFF95a5a6)) &
                0xFFFFFFFF),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Text(
        routine.name[0].toUpperCase(),
        style: FlutterFlowTheme.of(context).headlineMedium.override(
              fontFamily: 'Urbanist',
              color: Colors.white,
            ),
      ),
    );
  }

  Widget _buildRoutineInfo(Routine routine) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              routine.name,
              style: FlutterFlowTheme.of(context).bodyLarge,
            ),
            Text(
              'Added on: ${DateFormat('MMM d, yyyy').format(routine.dateAdded)}',
              style: FlutterFlowTheme.of(context).labelSmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionsButton(Routine routine, bool isActive) {
    return IconButton(
      icon: const Icon(Icons.more_vert),
      onPressed: () => Get.bottomSheet(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(isActive ? Icons.visibility_off : Icons.visibility),
              title: Text(isActive ? 'Make Inactive' : 'Make Active'),
              onTap: () {
                controller.toggleRoutineStatus(routine.id, isActive);
                Get.back();
              },
            ),
          ],
        ),
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
    );
  }

  void _showRoutineDetails(Routine routine, bool isActive) {
    Get.bottomSheet(
      Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    routine.name,
                    style: FlutterFlowTheme.of(context).headlineMedium,
                  ),
                  Switch(
                    value: isActive,
                    onChanged: (value) {
                      controller.toggleRoutineStatus(routine.id, isActive);
                      Get.back();
                    },
                    activeColor: FlutterFlowTheme.of(context).primary,
                  ),
                ],
              ),
            ),
            const Divider(),
            // Tasks List
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: controller.getRoutineTasks(routine.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(
                        'No tasks found',
                        style: FlutterFlowTheme.of(context).labelMedium,
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final task = snapshot.data![index];
                      return ListTile(
                        title: Text(task['title']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Due Time: ${task['dueTime']}'),
                            Text(
                              'Repeats on: ${(task['selectedDays'] as List).join(", ")}',
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}

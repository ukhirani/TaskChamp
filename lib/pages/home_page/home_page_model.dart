import '/components/task_tile_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'home_page_widget.dart' show HomePageWidget;
import 'package:flutter/material.dart';

class HomePageModel extends FlutterFlowModel<HomePageWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for TabBar widget.
  TabController? tabBarController;
  int get tabBarCurrentIndex =>
      tabBarController != null ? tabBarController!.index : 0;

  // Model for TaskTile component.
  late TaskTileModel taskTileModel1;
  // Model for TaskTile component.
  late TaskTileModel taskTileModel2;
  // Model for TaskTile component.
  late TaskTileModel taskTileModel3;
  // Model for TaskTile component.
  late TaskTileModel taskTileModel4;
  // Model for TaskTile component.
  late TaskTileModel taskTileModel5;
  // Model for TaskTile component.
  late TaskTileModel taskTileModel6;
  // Model for TaskTile component.
  late TaskTileModel taskTileModel7;
  // Model for TaskTile component.
  late TaskTileModel taskTileModel8;
  // Model for TaskTile component.
  late TaskTileModel taskTileModel9;

  @override
  void initState(BuildContext context) {
    taskTileModel1 = createModel(context, () => TaskTileModel());
    taskTileModel2 = createModel(context, () => TaskTileModel());
    taskTileModel3 = createModel(context, () => TaskTileModel());
    taskTileModel4 = createModel(context, () => TaskTileModel());
    taskTileModel5 = createModel(context, () => TaskTileModel());
    taskTileModel6 = createModel(context, () => TaskTileModel());
    taskTileModel7 = createModel(context, () => TaskTileModel());
    taskTileModel8 = createModel(context, () => TaskTileModel());
    taskTileModel9 = createModel(context, () => TaskTileModel());
  }

  @override
  void dispose() {
    tabBarController?.dispose();
    taskTileModel1.dispose();
    taskTileModel2.dispose();
    taskTileModel3.dispose();
    taskTileModel4.dispose();
    taskTileModel5.dispose();
    taskTileModel6.dispose();
    taskTileModel7.dispose();
    taskTileModel8.dispose();
    taskTileModel9.dispose();
  }
}

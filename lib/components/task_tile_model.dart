import '/components/category_tag_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'task_tile_widget.dart' show TaskTileWidget;
import 'package:flutter/material.dart';

class TaskTileModel extends FlutterFlowModel<TaskTileWidget> {
  ///  State fields for stateful widgets in this component.

  // Model for CategoryTag component.
  late CategoryTagModel categoryTagModel1;
  // Model for CategoryTag component.
  late CategoryTagModel categoryTagModel2;

  @override
  void initState(BuildContext context) {
    categoryTagModel1 = createModel(context, () => CategoryTagModel());
    categoryTagModel2 = createModel(context, () => CategoryTagModel());
  }

  @override
  void dispose() {
    categoryTagModel1.dispose();
    categoryTagModel2.dispose();
  }
}

import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'category_tag_model.dart';
export 'category_tag_model.dart';

class CategoryTagWidget extends StatefulWidget {
  const CategoryTagWidget({super.key});

  @override
  State<CategoryTagWidget> createState() => _CategoryTagWidgetState();
}

class _CategoryTagWidgetState extends State<CategoryTagWidget> {
  late CategoryTagModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CategoryTagModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 2.0, 2.0, 2.0),
      child: Container(
        width: 60.0,
        height: 22.0,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).primaryText,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(20.0),
            bottomRight: Radius.circular(20.0),
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
          border: Border.all(
            color: FlutterFlowTheme.of(context).primaryBackground,
            width: 1.0,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Icon(
                Icons.circle,
                color: FlutterFlowTheme.of(context).primaryBackground,
                size: 15.0,
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(2.0, 0.0, 0.0, 0.0),
                child: Text(
                  'Fitness',
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'Plus Jakarta Sans',
                        color: FlutterFlowTheme.of(context).primaryBackground,
                        fontSize: 10.0,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.normal,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

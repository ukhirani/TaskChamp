import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'category_tag_model.dart';
export 'category_tag_model.dart';

class CategoryTagWidget extends StatefulWidget {
  final String category; // Add a category parameter

  const CategoryTagWidget({Key? key, required this.category}) : super(key: key);

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
      padding: EdgeInsetsDirectional.fromSTEB(0, 2, 2, 2),
      child: Container(
        constraints: BoxConstraints(
          minWidth: 40,
          maxWidth: 120,
        ),
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).primaryText,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: FlutterFlowTheme.of(context).primaryBackground,
            width: 1,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.circle,
                color: FlutterFlowTheme.of(context).primaryBackground,
                size: 15,
              ),
              Flexible(
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(2, 0, 0, 0),
                  child: Text(
                    widget.category,
                    overflow: TextOverflow.ellipsis,
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'Plus Jakarta Sans',
                          color: FlutterFlowTheme.of(context).primaryBackground,
                          fontSize: 10,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.normal,
                        ),
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

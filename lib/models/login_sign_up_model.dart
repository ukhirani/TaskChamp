import '/flutter_flow/flutter_flow_util.dart';
import '../views/login_sign_up_widget.dart' show LoginSignUpWidget;
import 'package:flutter/material.dart';

class LoginSignUpModel extends FlutterFlowModel<LoginSignUpWidget> {
  // State fields for UI management (unchanged)
  TabController? tabBarController;
  int get tabBarCurrentIndex =>
      tabBarController != null ? tabBarController!.index : 0;

  // Login fields (no change here)
  FocusNode? emailAddressFocusNode;
  TextEditingController? emailAddressTextController;
  String? Function(BuildContext, String?)? emailAddressTextControllerValidator;

  FocusNode? passwordFocusNode;
  TextEditingController? passwordTextController;
  late bool passwordVisibility;
  String? Function(BuildContext, String?)? passwordTextControllerValidator;

  // Sign-Up fields
  FocusNode? emailAddressCreateFocusNode;
  TextEditingController? emailAddressCreateTextController;
  String? Function(BuildContext, String?)?
      emailAddressCreateTextControllerValidator;

  FocusNode? passwordCreateFocusNode;
  TextEditingController? passwordCreateTextController;
  late bool passwordCreateVisibility;
  String? Function(BuildContext, String?)?
      passwordCreateTextControllerValidator;

  FocusNode? passwordConfirmFocusNode;
  TextEditingController? passwordConfirmTextController;
  late bool passwordConfirmVisibility;
  String? Function(BuildContext, String?)?
      passwordConfirmTextControllerValidator;

  @override
  void initState(BuildContext context) {
    passwordVisibility = false;
    passwordCreateVisibility = false;
    passwordConfirmVisibility = false;
  }

  @override
  void dispose() {
    tabBarController?.dispose();
    emailAddressFocusNode?.dispose();
    emailAddressTextController?.dispose();
    passwordFocusNode?.dispose();
    passwordTextController?.dispose();
    emailAddressCreateFocusNode?.dispose();
    emailAddressCreateTextController?.dispose();
    passwordCreateFocusNode?.dispose();
    passwordCreateTextController?.dispose();
    passwordConfirmFocusNode?.dispose();
    passwordConfirmTextController?.dispose();
  }

  // Update loading or error UI states (optional)
  void updateState(String? errorMessage) {
    if (errorMessage != null && errorMessage.isNotEmpty) {
      // Show error message to the user
      // E.g., showSnackbar(context, errorMessage);
    }
    // You can add more logic to update UI based on the app state
  }
}

import 'package:tgo_acudir/presentation/screens/face_recognition/widgets/camera_widget/recognition_camera_widget.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'recognition_screen_model.dart';
export 'recognition_screen_model.dart';

class RecognitionScreenWidget extends StatefulWidget {
  const RecognitionScreenWidget({Key? key}) : super(key: key);

  @override
  _RecognitionScreenWidgetState createState() =>
      _RecognitionScreenWidgetState();
}

class _RecognitionScreenWidgetState extends State<RecognitionScreenWidget> {
  late RecognitionScreenModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => RecognitionScreenModel());
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isiOS) {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarBrightness: Theme.of(context).brightness,
          systemStatusBarContrastEnforced: true,
        ),
      );
    }

    context.watch<FFAppState>();

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      body: const Center(child: RecognitionCameraWidget()),
    );
  }
}

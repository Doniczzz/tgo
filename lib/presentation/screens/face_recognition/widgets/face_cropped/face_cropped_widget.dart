import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:tgo_acudir/presentation/screens/face_recognition/recognizer.dart';

import 'package:image/image.dart' as img;

import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'face_cropped_model.dart';
export 'face_cropped_model.dart';

class FaceCroppedWidget extends StatefulWidget {
  const FaceCroppedWidget({
    super.key,
    required this.userFace,
    required this.faceRect,
    required this.register,
  });

  final img.Image userFace;
  final Rect faceRect;
  final bool register;

  @override
  FaceCroppedWidgetState createState() => FaceCroppedWidgetState();
}

class FaceCroppedWidgetState extends State<FaceCroppedWidget> {
  late FaceCroppedModel _model;
  late Recognizer recognizer;

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => FaceCroppedModel());

    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();
    recognizer = Recognizer();
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const AlignmentDirectional(0, 0),
      child: Container(
        width: 340,
        constraints: const BoxConstraints(
          maxHeight: 480,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
              blurRadius: 3.0,
              color: Color(0x33000000),
              offset: Offset(0.0, 1.0),
            )
          ],
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: const Color(0xFFE0E3E7),
          ),
        ),
        alignment: const AlignmentDirectional(0.0, 0.0),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(10.0, 10.0, 10.0, 10.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    KeyboardVisibilityBuilder(
                      builder: (context, isKeyboardVisible) {
                        return isKeyboardVisible
                            ? Container()
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child: Image.memory(
                                  img.encodeJpg(widget.userFace),
                                ),
                              );
                      },
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
                      child: Text(
                        'Guardar en base de datos',
                        style: FlutterFlowTheme.of(context).bodyLarge.override(
                              fontFamily: 'Plus Jakarta Sans',
                              color: const Color(0xFF14181B),
                              fontSize: 16.0,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 8.0, 0.0),
                      child: TextFormField(
                        controller: _model.textController,
                        focusNode: _model.textFieldFocusNode,
                        autofocus: true,
                        obscureText: false,
                        decoration: InputDecoration(
                          labelText: 'Nombre',
                          labelStyle: FlutterFlowTheme.of(context).labelMedium,
                          hintStyle: FlutterFlowTheme.of(context).labelMedium,
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: FlutterFlowTheme.of(context).alternate,
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: FlutterFlowTheme.of(context).primary,
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          errorBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: FlutterFlowTheme.of(context).error,
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          focusedErrorBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: FlutterFlowTheme.of(context).error,
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        style: FlutterFlowTheme.of(context).bodyMedium,
                        validator: _model.textControllerValidator.asValidator(context),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () async {
                  await recognizer.recognize(widget.userFace, widget.faceRect, true, _model.textController.text);
                },
                child: Container(
                  width: double.infinity,
                  height: 44.0,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4B39EF),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(12.0),
                      bottomRight: Radius.circular(12.0),
                      topLeft: Radius.circular(0.0),
                      topRight: Radius.circular(0.0),
                    ),
                  ),
                  alignment: const AlignmentDirectional(0.0, 0.0),
                  child: Text(
                    'Guardar',
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'Plus Jakarta Sans',
                          color: Colors.white,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w500,
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

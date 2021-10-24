library scan;

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Scan {
  static const _channel = MethodChannel('io.improvising/scan');

  static Future<String?> get platformVersion async {
    final version = await _channel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  static Future<String?> parse(String path) async {
    final result = await _channel.invokeMethod<String>('parse', path);
    return result;
  }
}

class ScanView extends StatefulWidget {
  ScanView({
    Key? key,
    ScanController? controller,
    this.onCapture,
    this.scanLineColor = Colors.green,
    this.scanAreaScale = 0.7,
  })  : assert(scanAreaScale <= 1.0, 'scanAreaScale must <= 1.0'),
        assert(scanAreaScale > 0.0, 'scanAreaScale must > 0.0'),
        controller = controller ?? ScanController(),
        super(key: key);

  final ScanController controller;
  final CaptureCallback? onCapture;
  final Color scanLineColor;
  final double scanAreaScale;

  @override
  State<StatefulWidget> createState() => _ScanViewState();
}

class _ScanViewState extends State<ScanView> {
  MethodChannel? _channel;

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return UiKitView(
        viewType: 'io.improvising/scan_view',
        creationParamsCodec: const StandardMessageCodec(),
        creationParams: {
          'r': widget.scanLineColor.red,
          'g': widget.scanLineColor.green,
          'b': widget.scanLineColor.blue,
          'a': widget.scanLineColor.opacity,
          'scale': widget.scanAreaScale,
        },
        onPlatformViewCreated: (id) {
          _onPlatformViewCreated(id);
        },
      );
    } else {
      return AndroidView(
        viewType: 'io.improvising/scan_view',
        creationParamsCodec: const StandardMessageCodec(),
        creationParams: {
          'r': widget.scanLineColor.red,
          'g': widget.scanLineColor.green,
          'b': widget.scanLineColor.blue,
          'a': widget.scanLineColor.opacity,
          'scale': widget.scanAreaScale,
        },
        onPlatformViewCreated: (id) {
          _onPlatformViewCreated(id);
        },
      );
    }
  }

  void _onPlatformViewCreated(int id) {
    _channel = MethodChannel('io.improvising/scan/method_$id');
    _channel?.setMethodCallHandler((MethodCall call) async {
      if (call.method == 'onCaptured') {
        if (widget.onCapture != null) {
          widget.onCapture!(call.arguments.toString());
        }
      }
    });
    widget.controller._channel = _channel;
  }
}

typedef CaptureCallback = Function(String data);

class ScanArea {
  const ScanArea(this.width, this.height);

  final double width;
  final double height;
}

class ScanController {
  MethodChannel? _channel;

  void resume() {
    _channel?.invokeMethod('resume');
  }

  void pause() {
    _channel?.invokeMethod('pause');
  }

  void toggleTorchMode() {
    _channel?.invokeMethod('toggleTorchMode');
  }
}

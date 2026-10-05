import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:screenshot/screenshot.dart';

/// Renderiza widgets off-screen e exporta PNG sem piscar na UI visível.
class ImageExportService {
  ImageExportService({ScreenshotController? controller})
      : _controller = controller ?? ScreenshotController();

  final ScreenshotController _controller;

  static const Size storyCanvasSize = Size(360, 640); // proporção 9:16

  Future<Uint8List> captureWidget(Widget widget, {double pixelRatio = 3}) async {
    return _controller.captureFromWidget(
      MediaQuery(
        data: const MediaQueryData(),
        child: Material(
          color: Colors.transparent,
          child: widget,
        ),
      ),
      pixelRatio: pixelRatio,
      targetSize: storyCanvasSize,
    );
  }

  Future<Uint8List> captureRepaintBoundary(
    GlobalKey boundaryKey, {
    double pixelRatio = 3,
  }) async {
    final context = boundaryKey.currentContext;
    if (context == null) {
      throw StateError('Boundary não montado.');
    }

    final boundary = context.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) {
      throw StateError('RepaintBoundary inválido.');
    }

    final image = await boundary.toImage(pixelRatio: pixelRatio);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    if (bytes == null) throw StateError('Falha ao gerar PNG.');
    return bytes.buffer.asUint8List();
  }
}

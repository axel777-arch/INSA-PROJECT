import 'dart:io';
import 'package:flutter/widgets.dart';

/// Native (non-web) implementation rendering files via `Image.file(File(...))`.
Widget renderPlatformFileImage(
  String path, {
  double? width,
  double? height,
  BoxFit? fit,
  Widget Function(BuildContext, Object, StackTrace?)? errorBuilder,
}) {
  return Image.file(
    File(path),
    width: width,
    height: height,
    fit: fit,
    errorBuilder: errorBuilder,
  );
}

import 'dart:io';
import 'dart:typed_data';

import 'package:open_filex/open_filex.dart';

Future<void> openCaseAttachmentFile(Uint8List bytes, String fileName) async {
  final safeName = fileName.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
  final directory = await Directory.systemTemp.createTemp(
    'agri-case-attachment-',
  );
  final file = File('${directory.path}${Platform.pathSeparator}$safeName');
  await file.writeAsBytes(bytes, flush: true);
  await openCaseAttachmentPath(file.path);
}

Future<void> openCaseAttachmentPath(String path) async {
  final result = await OpenFilex.open(path);
  if (result.type != ResultType.done) {
    throw StateError(result.message);
  }
}

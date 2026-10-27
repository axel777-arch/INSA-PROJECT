import 'dart:typed_data';

import 'case_attachment_file_stub.dart'
    if (dart.library.io) 'case_attachment_file_io.dart'
    if (dart.library.html) 'case_attachment_file_web.dart'
    as platform_file;

Future<void> openCaseAttachmentFile(Uint8List bytes, String fileName) =>
    platform_file.openCaseAttachmentFile(bytes, fileName);

Future<void> openCaseAttachmentPath(String path) =>
    platform_file.openCaseAttachmentPath(path);

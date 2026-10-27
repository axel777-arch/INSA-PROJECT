import 'dart:typed_data';

Future<void> openCaseAttachmentFile(Uint8List bytes, String fileName) async {
  throw UnsupportedError(
    'Opening local attachments is not supported on this platform.',
  );
}

Future<void> openCaseAttachmentPath(String path) async {
  throw UnsupportedError(
    'Opening local attachments is not supported on this platform.',
  );
}

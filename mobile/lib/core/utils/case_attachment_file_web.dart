import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

Future<void> openCaseAttachmentFile(Uint8List bytes, String _) async {
  final blob = web.Blob(
    [bytes.toJS].toJS,
    web.BlobPropertyBag(type: 'application/pdf'),
  );
  final url = web.URL.createObjectURL(blob);
  if (web.window.open(url, '_blank') == null) {
    throw StateError('The PDF could not be opened in a new browser tab.');
  }
}

Future<void> openCaseAttachmentPath(String path) async {
  throw UnsupportedError(
    'Local attachment paths cannot be opened in a browser.',
  );
}

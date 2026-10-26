import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'case_attachment_file.dart';

Future<void> openCaseAttachment(BuildContext context, String attachment) async {
  final uri = Uri.tryParse(attachment);
  if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw StateError('The attachment link could not be opened.');
    }
    return;
  }

  final match = RegExp(
    r'^data:([^;,]+)(?:;name=([^;,]+))?;base64,(.*)$',
    dotAll: true,
  ).firstMatch(attachment);
  if (match == null) {
    await openCaseAttachmentPath(attachment);
    return;
  }

  final mimeType = match.group(1)!.toLowerCase();
  final name = Uri.decodeComponent(
    match.group(2) ?? _defaultFileName(mimeType),
  );
  final bytes = base64Decode(match.group(3)!);
  if (mimeType == 'application/pdf') {
    await openCaseAttachmentFile(bytes, name);
    return;
  }

  if (!mimeType.startsWith('image/')) {
    throw UnsupportedError('This case attachment format is not supported.');
  }

  if (!context.mounted) return;
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => Dialog(
      child: InteractiveViewer(child: Image.memory(bytes, fit: BoxFit.contain)),
    ),
  );
}

String _defaultFileName(String mimeType) {
  if (mimeType == 'application/pdf') return 'case-attachment.pdf';
  final extension = mimeType.split('/').last;
  return 'case-attachment.$extension';
}

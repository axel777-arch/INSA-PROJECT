import 'package:flutter/material.dart';
import 'advisory_approval_screen.dart';

/// Legacy screen wrapper routing to the official AdvisoryApprovalScreen.
/// Connects actual backend endpoints instead of static mock data.
class ContentReviewDetailsScreen extends StatelessWidget {
  final String contentId;

  const ContentReviewDetailsScreen({super.key, required this.contentId});

  @override
  Widget build(BuildContext context) {
    return AdvisoryApprovalScreen(contentId: contentId);
  }
}

import 'package:flutter/material.dart';
import '../../features/admin/screens/admin_home_screen.dart';
import '../../features/agricultural_expert/screens/content_review_details_screen.dart';
import '../../features/agricultural_expert/screens/content_review_screen.dart';
import '../../features/agricultural_expert/screens/expert_home_screen.dart';
import '../../features/agricultural_expert/screens/expert_profile_screen.dart';
import '../../features/alerts/screens/alerts_list_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/pending_approval_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/content/screens/content_detail_screen.dart';
import '../../features/content/screens/content_form_screen.dart';
import '../../features/content/screens/content_list_screen.dart';
import '../../features/extension_worker/screens/assigned_workflow_screen.dart';
import '../../features/extension_worker/screens/extension_home_screen.dart';
import '../../features/extension_worker/screens/extension_worker_profile_screen.dart';
import '../../features/extension_worker/screens/farmer_information_screen.dart';
import '../../features/farmer/screens/farmer_home_screen.dart';
import '../../features/farmer/screens/farmer_profile_screen.dart';
import '../../features/simulator/screens/ivr_simulator_screen.dart';
import '../../features/simulator/screens/sms_simulator_screen.dart';

class AppRouter {
  // Auth
  static const String login = '/login';
  static const String register = '/register';
  static const String pendingApproval = '/auth/pending-approval';

  // Farmer
  static const String farmerHome = '/farmer/home';
  static const String farmerProfile = '/farmer/profile';

  // Extension Worker
  static const String extensionHome = '/extension/home';
  static const String extensionProfile = '/extension/profile';
  static const String farmerInformation = '/extension/farmer-information';
  static const String assignedWorkflow = '/extension/assigned-workflow';

  // Agricultural Expert
  static const String expertHome = '/expert/home';
  static const String expertProfile = '/expert/profile';
  static const String contentReviewQueue = '/expert/content-review';
  static const String contentReviewDetails = '/expert/content-review-details';

  // Admin
  static const String adminHome = '/admin/home';

  // Content
  static const String contentList = '/content/list';
  static const String contentDetail = '/content/detail';
  static const String contentCreate = '/content/create';

  // Alerts
  static const String alertsList = '/alerts';

  // Simulators
  static const String smsSimulator = '/simulator/sms';
  static const String ivrSimulator = '/simulator/ivr';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case pendingApproval:
        final role = settings.arguments as String? ?? 'Extension';
        return MaterialPageRoute(builder: (_) => PendingApprovalScreen(role: role));
      case farmerHome:
        return MaterialPageRoute(builder: (_) => const FarmerHomeScreen());
      case farmerProfile:
        return MaterialPageRoute(builder: (_) => const FarmerProfileScreen());
      case extensionHome:
        return MaterialPageRoute(builder: (_) => const ExtensionHomeScreen());
      case extensionProfile:
        return MaterialPageRoute(builder: (_) => const ExtensionWorkerProfileScreen());
      case farmerInformation:
        return MaterialPageRoute(builder: (_) => const FarmerInformationScreen());
      case assignedWorkflow:
        return MaterialPageRoute(builder: (_) => const AssignedWorkflowScreen());
      case expertHome:
        return MaterialPageRoute(builder: (_) => const ExpertHomeScreen());
      case expertProfile:
        return MaterialPageRoute(builder: (_) => const ExpertProfileScreen());
      case contentReviewQueue:
        return MaterialPageRoute(builder: (_) => const ContentReviewScreen());
      case contentReviewDetails:
        final contentId = settings.arguments as String? ?? '1';
        return MaterialPageRoute(builder: (_) => ContentReviewDetailsScreen(contentId: contentId));
      case adminHome:
        return MaterialPageRoute(builder: (_) => const AdminHomeScreen());
      case contentList:
        return MaterialPageRoute(builder: (_) => const ContentListScreen());
      case contentDetail:
        final contentId = settings.arguments as String? ?? '1';
        return MaterialPageRoute(builder: (_) => ContentDetailScreen(contentId: contentId));
      case contentCreate:
        return MaterialPageRoute(builder: (_) => const ContentFormScreen());
      case alertsList:
        return MaterialPageRoute(builder: (_) => const AlertsListScreen());
      case smsSimulator:
        return MaterialPageRoute(builder: (_) => const SmsSimulatorScreen());
      case ivrSimulator:
        return MaterialPageRoute(builder: (_) => const IvrSimulatorScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}

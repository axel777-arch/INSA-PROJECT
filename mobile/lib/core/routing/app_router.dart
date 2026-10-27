import 'package:flutter/material.dart';
import '../../features/admin/screens/admin_main_layout.dart';
import '../../features/admin/screens/admin_audit_logs_screen.dart';
import '../../features/agricultural_expert/screens/advisory_approval_screen.dart';
import '../../features/agricultural_expert/screens/content_review_list_screen.dart';
import '../../features/agricultural_expert/screens/expert_analytics_screen.dart';
import '../../features/agricultural_expert/screens/expert_escalated_cases_screen.dart';
import '../../features/agricultural_expert/screens/expert_main_layout.dart';
import '../../features/agricultural_expert/screens/field_case_response_screen.dart';
import '../../features/alerts/screens/alerts_list_screen.dart';
import '../../features/auth/screens/account_under_review_screen.dart';
import '../../features/auth/screens/choose_language_screen.dart';
import '../../features/auth/screens/expert_registration_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/pending_approval_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/role_onboarding_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/content/screens/content_detail_screen.dart';
import '../../features/content/screens/content_form_screen.dart';
import '../../features/content/screens/content_list_screen.dart';
import '../../features/extension_worker/screens/add_crop_screen.dart';
import '../../features/extension_worker/screens/extension_cases_screen.dart';
import '../../features/extension_worker/screens/extension_drafts_screen.dart';
import '../../features/extension_worker/screens/extension_followups_screen.dart';
import '../../features/extension_worker/screens/crop_recording_screen.dart';
import '../../features/extension_worker/screens/extension_alerts_screen.dart';
import '../../features/extension_worker/screens/extension_main_layout.dart';
import '../../features/extension_worker/screens/extension_profile_screen.dart';
import '../../features/extension_worker/screens/farmer_management_screen.dart';
import '../../features/extension_worker/screens/register_farmer_flow.dart';
import '../../features/extension_worker/screens/field_observation_screen.dart';
import '../../features/extension_worker/screens/schedule_follow_up_screen.dart';
import '../../features/farmer/screens/accessibility_hub_screen.dart';
import '../../features/farmer/screens/ask_extension_worker_screen.dart';
import '../../features/farmer/screens/crop_calendar_screen.dart';
import '../../features/farmer/screens/farmer_main_layout.dart';
import '../../features/farmer/screens/farmer_profile_screen.dart';
import '../../features/farmer/screens/market_prices_screen.dart';
import '../../features/farmer/screens/offline_advisories_screen.dart';
import '../../features/simulator/screens/ivr_simulator_screen.dart';
import '../../features/simulator/screens/sms_simulator_screen.dart';

class AppRouter {
  static const String splash = '/splash';
  static const String chooseLanguage = '/choose-language';
  static const String login = '/login';
  static const String register = '/register';
  static const String expertRegister = '/expert/register';
  static const String pendingApproval = '/auth/pending-approval';
  static const String accountUnderReview = '/auth/account-under-review';
  static const String roleOnboarding = '/auth/onboarding';
  static const String farmerHome = '/farmer/home';
  static const String farmerProfile = '/farmer/profile';
  static const String farmerMarket = '/farmer/market';
  static const String farmerCropCalendar = '/farmer/crop-calendar';
  static const String farmerOfflineAdvisories = '/farmer/offline-advisories';
  static const String farmerCases = '/farmer/cases';
  static const String farmerAccessibility = '/farmer/accessibility';
  static const String expertHome = '/expert/home';
  static const String expertReviewList = '/expert/review/list';
  static const String expertReviewDetail = '/expert/review/detail';
  static const String expertCaseDetail = '/expert/case/detail';
  static const String expertEscalatedCases = '/expert/cases/escalated';
  static const String expertAnalytics = '/expert/analytics';
  static const String extensionHome = '/extension/home';
  static const String extensionCases = '/extension/cases';
  static const String extensionDrafts = '/extension/drafts';
  static const String extensionFollowUps = '/extension/follow-ups';
  static const String extensionFarmerDirectory = '/extension/farmer/directory';
  static const String extensionFarmerRegister = '/extension/farmer/register';
  static const String extensionFieldObservations =
      '/extension/field/observations';
  static const String extensionScheduleFollowUp =
      '/extension/follow-up/schedule';
  static const String extensionAddCrop = '/extension/crops/add';
  static const String extensionCrops = '/extension/crops';
  static const String extensionProfile = '/extension/profile';
  static const String extensionAlerts = '/extension/alerts';
  static const String adminHome = '/admin/home';
  static const String adminAuditLogs = '/admin/audit-logs';
  static const String contentList = '/content/list';
  static const String contentDetail = '/content/detail';
  static const String contentCreate = '/content/create';
  static const String alertsList = '/alerts';
  static const String smsSimulator = '/simulator/sms';
  static const String ivrSimulator = '/simulator/ivr';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case chooseLanguage:
        return MaterialPageRoute(builder: (_) => const ChooseLanguageScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case expertRegister:
        return MaterialPageRoute(
          builder: (_) => const ExpertRegistrationScreen(),
        );
      case pendingApproval:
        final arguments = settings.arguments;
        final role = arguments is PendingApprovalArguments
            ? arguments.role
            : arguments as String? ?? 'Extension';
        return MaterialPageRoute(
          builder: (_) => PendingApprovalScreen(
            role: role,
            identifier: arguments is PendingApprovalArguments
                ? arguments.identifier
                : null,
            password: arguments is PendingApprovalArguments
                ? arguments.password
                : null,
          ),
        );
      case accountUnderReview:
        return MaterialPageRoute(
          builder: (_) => const AccountUnderReviewScreen(),
        );
      case roleOnboarding:
        final role = settings.arguments as String? ?? 'Farmer';
        return MaterialPageRoute(
          builder: (_) => RoleOnboardingScreen(role: role),
        );
      case farmerHome:
        return MaterialPageRoute(builder: (_) => const FarmerMainLayout());
      case farmerProfile:
        return MaterialPageRoute(builder: (_) => const FarmerProfileScreen());
      case farmerMarket:
        return MaterialPageRoute(builder: (_) => const MarketPricesScreen());
      case farmerCropCalendar:
        return MaterialPageRoute(builder: (_) => const CropCalendarScreen());
      case farmerOfflineAdvisories:
        return MaterialPageRoute(
          builder: (_) => const OfflineAdvisoriesScreen(),
        );
      case farmerCases:
        return MaterialPageRoute(
          builder: (_) => const AskExtensionWorkerScreen(),
        );
      case farmerAccessibility:
        return MaterialPageRoute(
          builder: (_) => const AccessibilityHubScreen(),
        );
      case expertHome:
        return MaterialPageRoute(builder: (_) => const ExpertMainLayout());
      case expertReviewList:
        return MaterialPageRoute(
          builder: (_) => const ContentReviewListScreen(),
        );
      case expertReviewDetail:
        return MaterialPageRoute(
          builder: (_) => const AdvisoryApprovalScreen(),
        );
      case expertCaseDetail:
        return MaterialPageRoute(
          builder: (_) => const FieldCaseResponseScreen(),
        );
      case expertEscalatedCases:
        return MaterialPageRoute(
          builder: (_) => const ExpertEscalatedCasesScreen(),
        );
      case expertAnalytics:
        return MaterialPageRoute(builder: (_) => const ExpertAnalyticsScreen());
      case extensionHome:
        return MaterialPageRoute(builder: (_) => const ExtensionMainLayout());
      case extensionCases:
        return MaterialPageRoute(builder: (_) => const ExtensionCasesScreen());
      case extensionDrafts:
        return MaterialPageRoute(builder: (_) => const ExtensionDraftsScreen());
      case extensionFollowUps:
        return MaterialPageRoute(
          builder: (_) => const ExtensionFollowUpsScreen(),
        );
      case extensionFarmerDirectory:
        return MaterialPageRoute(
          builder: (_) => const FarmerManagementScreen(),
        );
      case extensionFarmerRegister:
        return MaterialPageRoute(builder: (_) => const RegisterFarmerFlow());
      case extensionFieldObservations:
        return MaterialPageRoute(
          builder: (_) => const FieldObservationScreen(),
        );
      case extensionScheduleFollowUp:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => ScheduleFollowUpScreen(
            initialFarmerId: args?['farmerId'] as String?,
            initialFarmerName: args?['farmerName'] as String?,
            initialObservationId: args?['observationId'] as String?,
          ),
        );
      case extensionAddCrop:
        return MaterialPageRoute(builder: (_) => const AddCropScreen());
      case extensionCrops:
        return MaterialPageRoute(builder: (_) => const CropRecordingScreen());
      case extensionProfile:
        return MaterialPageRoute(
          builder: (_) => const ExtensionProfileScreen(),
        );
      case extensionAlerts:
        return MaterialPageRoute(builder: (_) => const ExtensionAlertsScreen());
      case adminHome:
        return MaterialPageRoute(builder: (_) => const AdminMainLayout());
      case adminAuditLogs:
        return MaterialPageRoute(builder: (_) => const AdminAuditLogsScreen());
      case contentList:
        return MaterialPageRoute(builder: (_) => const ContentListScreen());
      case contentDetail:
        final contentId = settings.arguments as String? ?? '1';
        return MaterialPageRoute(
          builder: (_) => ContentDetailScreen(contentId: contentId),
        );
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

# UI/UX Workflows & Cross-Platform Specification
## Agri-Insight Beacon Platform

**Client Framework:** Flutter (Dart 3.x)  
**Target Environments:** Modern Web Browsers (Chrome, Edge, Safari, Firefox) & Android  
**Design System:** Material 3 with Custom Emerald Agriculture Theme  
**Last Updated:** October 2026  

---

## 1. Screen Navigation Hierarchy & Route Map

Navigation is managed via declarative routing in [AppRouter](file:///c:/Insa/grad_project/INSA-PROJECT/mobile/lib/core/routing/app_router.dart) with deterministic role-based redirections upon session verification:

```
                              ┌────────────────┐
                              │  SplashScreen  │
                              │      ('/')     │
                              └───────┬────────┘
                                      │
                   ┌──────────────────┴──────────────────┐
                   ▼                                     ▼
          [No Active Token]                      [Valid Token Restored]
          ┌────────────────┐                                     │
          │  LoginScreen   │                                     │
          │   ('/login')   │                                     │
          └───────┬────────┘                                     │
                  │                                              │
    ┌─────────────┴─────────────┐                                │
    ▼                           ▼                                │
┌──────────────────┐    ┌─────────────────┐                      │
│  RegisterScreen  │    │ExpertRegScreen  │                      │
│   ('/register')  │    │('/expert-reg')  │                      │
└──────────────────┘    └─────────────────┘                      │
                  │ Authenticated Login                          │
                  └───────────────────────┬──────────────────────┘
                                          │
                   ┌──────────────────────┴──────────────────────┐
                   │ Role Evaluator                              │
                   ├─────────────────────────────────────────────┤
                   │ - FARMER           ───► FarmerHomeScreen    │
                   │ - EXTENSION_WORKER ───► ExtensionHomeScreen │
                   │ - EXPERT           ───► ExpertMainLayout    │
                   │ - ADMIN            ───► AdminMainLayout     │
                   └─────────────────────────────────────────────┘
```

### 1.1 Detailed Sub-Navigation Trees

#### A. Farmer Portal (`FARMER`)
- **[FarmerHomeScreen](file:///c:/Insa/grad_project/INSA-PROJECT/mobile/lib/features/farmer/screens/farmer_home_screen.dart) (`/farmer-home`):**
  - Displays localized crop weather alerts, subscribed agronomic advisories, and quick actions.
  - $\longrightarrow$ **Advisory Details Dialog:** Opens detailed publication with expert credentials.
  - $\longrightarrow$ **[FarmerProfileScreen](file:///c:/Insa/grad_project/INSA-PROJECT/mobile/lib/features/farmer/screens/farmer_profile_screen.dart) (`/farmer-profile`):** Edit woreda/kebele location and alert preferences.
  - $\longrightarrow$ **[IvrSimulatorScreen](file:///c:/Insa/grad_project/INSA-PROJECT/mobile/lib/features/simulator/screens/ivr_simulator_screen.dart) (`/simulator-ivr`):** Access simulated audio advisory dialer.

#### B. Extension Worker Portal (`EXTENSION_WORKER`)
- **[ExtensionHomeScreen](file:///c:/Insa/grad_project/INSA-PROJECT/mobile/lib/features/extension_worker/screens/extension_home_screen.dart) (`/extension-home`):**
  - Shows assigned operational zone summary, registered farmers count, and recent field escalations.
  - $\longrightarrow$ **[FarmerManagementScreen](file:///c:/Insa/grad_project/INSA-PROJECT/mobile/lib/features/extension_worker/screens/farmer_management_screen.dart) (`/farmer-management`):** Onboard new smallholders, link crop varieties.
  - $\longrightarrow$ **[FieldObservationScreen](file:///c:/Insa/grad_project/INSA-PROJECT/mobile/lib/features/extension_worker/screens/field_observation_screen.dart) (`/field-observation`):** Document crop pest outbreaks with field imagery.
  - $\longrightarrow$ **[ContentFormScreen](file:///c:/Insa/grad_project/INSA-PROJECT/mobile/lib/features/content/screens/content_form_screen.dart) (`/content-form`):** Draft local field notices.

#### C. Agricultural Expert Portal (`EXPERT`)
- **[ExpertMainLayout](file:///c:/Insa/grad_project/INSA-PROJECT/mobile/lib/features/agricultural_expert/screens/expert_main_layout.dart) (`/expert-layout`):**
  - Tabbed interface spanning validation queues, escalated cases, and active bulletins.
  - $\longrightarrow$ **[ContentReviewScreen](file:///c:/Insa/grad_project/INSA-PROJECT/mobile/lib/features/agricultural_expert/screens/content_review_screen.dart) (`/content-review`):** Inspect draft advisories, approve or reject with comments.
  - $\longrightarrow$ **[FieldCaseResponseScreen](file:///c:/Insa/grad_project/INSA-PROJECT/mobile/lib/features/agricultural_expert/screens/field_case_response_screen.dart) (`/field-case-response`):** High-priority escalated field cases requiring expert diagnosis.

#### D. System Administration (`ADMIN`)
- **[AdminMainLayout](file:///c:/Insa/grad_project/INSA-PROJECT/mobile/lib/features/admin/screens/admin_main_layout.dart) (`/admin-home`):**
  - Master controls for system operations.
  - $\longrightarrow$ **[AdminUserManagementScreen](file:///c:/Insa/grad_project/INSA-PROJECT/mobile/lib/features/admin/screens/admin_user_management_screen.dart) (`/admin-users`):** Promote users, toggle RBAC permissions.
  - $\longrightarrow$ **[AdminAuditLogsScreen](file:///c:/Insa/grad_project/INSA-PROJECT/mobile/lib/features/admin/screens/admin_audit_logs_screen.dart) (`/admin-audit-logs`):** Inspect tamper-evident audit trails.

---

## 2. Cross-Platform Execution Rules (Web vs. Native)

Flutter applications targeting both Web (CanvasKit/HTML) and Native (Android/iOS) encounter strict runtime constraints regarding filesystem access and byte encoding:

### 2.1 The `Image.file` Incompatibility on Web
In standard Flutter development, reading photos from disk uses `Image.file(File(path))`. However, the Dart Web runtime stub for `dart:io` contains an explicit runtime assertion:

```dart
// flutter/packages/flutter/lib/src/widgets/image.dart
Image.file(...) : assert(!kIsWeb, 'Image.file is not supported on Flutter Web.');
```

If an app invokes `Image.file` in a browser environment, it throws an unhandled assertion exception, completely terminating the widget rendering pipeline.

### 2.2 Technical Requirements for Safe Cross-Platform Media

1. **Zero Direct `dart:io` Imports in UI Code:**
   UI widgets (such as `field_case_response_screen.dart`) must never contain `import 'dart:io';` at the top of the file without conditional compilation gates. Direct top-level imports prevent tree-shaking and generate compiler warnings or runtime stubs.

2. **Conditional Compilation via Library Detection:**
   Implement an abstraction boundary using Dart conditional exports:
   ```dart
   // mobile/lib/core/utils/platform_image.dart
   export 'platform_image_web.dart'
       if (dart.library.io) 'platform_image_io.dart';
   ```
   - When compiled for Web, `dart.library.io` evaluates to `false`, importing `platform_image_web.dart`.
   - When compiled for Native, `dart.library.io` evaluates to `true`, importing `platform_image_io.dart`.

3. **In-Memory Buffer Ingestion (`XFile.fromData`):**
   When users pick images on Web using `file_picker` or `image_picker`, the browser security sandbox does not expose a local filesystem path (`file.path` is empty or a temporary blob URI). Image bytes must be extracted directly:
   ```dart
   final picked = <XFile>[];
   for (final file in result.files) {
     if (file.bytes != null) {
       picked.add(XFile.fromData(file.bytes!, name: file.name));
     } else if (file.path != null && file.path!.isNotEmpty) {
       picked.add(XFile(file.path!));
     }
   }
   ```

4. **Tri-State Rendering Strategy:**
   ```
                       Is kIsWeb == true?
                           /        \
                        YES          NO
                        /              \
           Does path start with         Render via Native
           http://, https://, blob:?    Image.file(File(path))
                 /       \
               YES        NO
               /            \
          Render via       Render in-memory
         Image.network    Uint8List via Image.memory
   ```

5. **Defensive Error Fallbacks:**
   Every image preview widget must define both an `errorBuilder` and an asynchronous loading placeholder to ensure corrupt files, cancelled selections, or slow network streams never crash the widget tree.

---

## 3. UI Resilience & Defensive Component Guidelines

### 3.1 Empty State Handling
Every list view across the application adheres to defensive rendering rules:
```dart
child: _items.isEmpty
    ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 48, color: Colors.grey),
            SizedBox(height: 8),
            Text('No advisories found for the selected filter.'),
          ],
        ),
      )
    : ListView.builder(...);
```

### 3.2 Form Validation & Inline Notifications
All user inputs (login credentials, advisory diagnosis, crop observations) must pass client-side validation rules before triggering asynchronous network dispatches. Network errors display persistent floating SnackBars styled with `AppColors.error` rather than terminating current screen state.

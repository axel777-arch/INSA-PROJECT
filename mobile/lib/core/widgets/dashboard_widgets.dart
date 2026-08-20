// ============================================================================
// DASHBOARD DESIGN SYSTEM WIDGETS
// ----------------------------------------------------------------------------
// Shared building blocks used to give every dashboard-style screen in the
// app (Expert, Farmer, Extension Worker, Admin, list/detail screens, etc.)
// the same look and feel as the "Agri-Insight Beacon" reference design:
//   - App header with logo chip, theme toggle and notification bell
//   - Welcome banner
//   - Sync-data banner
//   - Left-accent-bar action/navigation cards with icon chips + badges
//   - Recent activity rows with status pills
//   - Section headers with an optional "View all" link
// ============================================================================

import 'package:flutter/material.dart';
import '../constants/app_sizes.dart';
import '../theme/app_colors.dart';

/// Simple accent tint used across icon chips, badges and left-accent bars.
enum DashAccent { green, amber, blue, red }

class _TintPair {
  final Color bg;
  final Color fg;
  const _TintPair(this.bg, this.fg);
}

_TintPair _tintFor(DashAccent accent, bool isDark) {
  switch (accent) {
    case DashAccent.green:
      return isDark
          ? const _TintPair(AppColors.tintGreenBgDark, AppColors.tintGreenFgDark)
          : const _TintPair(AppColors.tintGreenBg, AppColors.tintGreenFg);
    case DashAccent.amber:
      return isDark
          ? const _TintPair(AppColors.tintAmberBgDark, AppColors.tintAmberFgDark)
          : const _TintPair(AppColors.tintAmberBg, AppColors.tintAmberFg);
    case DashAccent.blue:
      return isDark
          ? const _TintPair(AppColors.tintBlueBgDark, AppColors.tintBlueFgDark)
          : const _TintPair(AppColors.tintBlueBg, AppColors.tintBlueFg);
    case DashAccent.red:
      return isDark
          ? const _TintPair(AppColors.tintRedBgDark, AppColors.tintRedFgDark)
          : const _TintPair(AppColors.tintRedBg, AppColors.tintRedFg);
  }
}

// ============================================================================
// APP HEADER — logo chip + product name + theme toggle + notification bell
// ============================================================================

class DashboardAppHeader extends StatelessWidget {
  final String title;
  final IconData logoIcon;
  final bool isDark;
  final VoidCallback? onToggleTheme;
  final VoidCallback? onNotifications;
  final bool showNotificationDot;
  final VoidCallback? onLogout;

  const DashboardAppHeader({
    super.key,
    required this.title,
    this.logoIcon = Icons.eco_rounded,
    required this.isDark,
    this.onToggleTheme,
    this.onNotifications,
    this.showNotificationDot = true,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tint = _tintFor(DashAccent.green, isDark);

    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: tint.bg,
            borderRadius: BorderRadius.circular(AppSizes.r12),
          ),
          child: Icon(logoIcon, color: tint.fg, size: 24),
        ),
        const SizedBox(width: AppSizes.p12),
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        IconButton(
          tooltip: 'Change theme',
          icon: Icon(
            isDark ? Icons.dark_mode_rounded : Icons.light_mode_outlined,
          ),
          onPressed: onToggleTheme,
        ),
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              tooltip: 'Notifications',
              icon: const Icon(Icons.notifications_none_rounded),
              onPressed: onNotifications,
            ),
            if (showNotificationDot)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: const BoxDecoration(
                    color: AppColors.notificationDot,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
        if (onLogout != null)
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout_rounded),
            onPressed: onLogout,
          ),
      ],
    );
  }
}

// ============================================================================
// WELCOME BANNER
// ============================================================================

class DashboardWelcomeBanner extends StatelessWidget {
  final String greeting;
  final String subtitle;

  const DashboardWelcomeBanner({
    super.key,
    required this.greeting,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(subtitle, style: theme.textTheme.bodyMedium),
      ],
    );
  }
}

// ============================================================================
// SYNC DATA BANNER
// ============================================================================

class SyncDataBanner extends StatelessWidget {
  final bool isSyncing;
  final String lastSyncedLabel;
  final VoidCallback? onSync;
  final String label;

  const SyncDataBanner({
    super.key,
    required this.isSyncing,
    required this.lastSyncedLabel,
    required this.onSync,
    this.label = 'Sync Data',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      borderRadius: BorderRadius.circular(AppSizes.r16),
      onTap: isSyncing ? null : onSync,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.p16,
          vertical: AppSizes.p12,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.syncBannerBgDark : AppColors.syncBannerBg,
          borderRadius: BorderRadius.circular(AppSizes.r16),
          border: Border.all(
            color: isDark
                ? AppColors.syncBannerBorderDark
                : AppColors.syncBannerBorder,
          ),
        ),
        child: Row(
          children: [
            isSyncing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(Icons.sync_rounded, color: theme.colorScheme.primary),
            const SizedBox(width: AppSizes.p12),
            Expanded(
              child: Text(
                isSyncing ? 'Syncing...' : label,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Last synced',
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                ),
                Text(
                  lastSyncedLabel,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            const SizedBox(width: AppSizes.p8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.refresh_rounded,
                size: 18,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// SECTION HEADER — title (+ optional "View all")
// ============================================================================

class DashboardSectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const DashboardSectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        if (actionLabel != null)
          InkWell(
            onTap: onAction,
            borderRadius: BorderRadius.circular(AppSizes.r8),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 4,
                vertical: 4,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    actionLabel!,
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: theme.colorScheme.primary,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

// ============================================================================
// DASHBOARD ACTION CARD — left accent bar + icon chip + title + badge + arrow
// ============================================================================

class DashboardActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? badgeLabel;
  final DashAccent accent;
  final VoidCallback onTap;

  const DashboardActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
    this.badgeLabel,
    this.accent = DashAccent.green,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tint = _tintFor(accent, isDark);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.p12),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(AppSizes.r16),
        border: Border.all(
          color: isDark ? AppColors.borderDarkTheme : AppColors.divider,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.0 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 4, color: tint.fg),
            Expanded(
              child: InkWell(
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.p16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: tint.bg,
                          borderRadius: BorderRadius.circular(AppSizes.r12),
                        ),
                        child: Icon(icon, color: tint.fg, size: 26),
                      ),
                      const SizedBox(width: AppSizes.p16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              description,
                              style: theme.textTheme.bodyMedium,
                            ),
                            if (badgeLabel != null) ...[
                              const SizedBox(height: AppSizes.p8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: tint.bg,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  badgeLabel!,
                                  style: TextStyle(
                                    color: tint.fg,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSizes.p8),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// STATUS PILL — small colored label used in activity rows / list screens
// ============================================================================

class StatusPill extends StatelessWidget {
  final String label;
  final DashAccent accent;

  const StatusPill({super.key, required this.label, required this.accent});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tint = _tintFor(accent, isDark);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: tint.bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: tint.fg,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// ============================================================================
// RECENT ACTIVITY CARD + ROW
// ============================================================================

class RecentActivityCard extends StatelessWidget {
  final List<Widget> children;

  const RecentActivityCard({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(AppSizes.r16),
        border: Border.all(
          color: isDark ? AppColors.borderDarkTheme : AppColors.divider,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

class RecentActivityRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String pillLabel;
  final DashAccent accent;
  final bool showDivider;

  const RecentActivityRow({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.pillLabel,
    required this.accent,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tint = _tintFor(accent, isDark);

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSizes.p16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: tint.bg, shape: BoxShape.circle),
                child: Icon(icon, color: tint.fg, size: 20),
              ),
              const SizedBox(width: AppSizes.p12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(subtitle, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              const SizedBox(width: AppSizes.p8),
              StatusPill(label: pillLabel, accent: accent),
            ],
          ),
        ),
        if (showDivider) const Divider(height: 1),
      ],
    );
  }
}

// ============================================================================
// OVERVIEW STAT CHIP (small stat used inline, e.g. "148 Approvals | 23 Rejections")
// ============================================================================

class InlineStatChip extends StatelessWidget {
  final String value;
  final String label;
  final DashAccent accent;

  const InlineStatChip({
    super.key,
    required this.value,
    required this.label,
    this.accent = DashAccent.blue,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tint = _tintFor(accent, isDark);

    return RichText(
      text: TextSpan(
        style: TextStyle(color: tint.fg, fontWeight: FontWeight.bold, fontSize: 14),
        children: [
          TextSpan(text: value),
          const TextSpan(text: ' '),
          TextSpan(
            text: label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

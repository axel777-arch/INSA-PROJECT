import 'package:flutter/material.dart';
import '../../../../../main.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../../../core/widgets/screen_backdrop.dart';

class AccessibilityHubScreen extends StatefulWidget {
  const AccessibilityHubScreen({super.key});

  @override
  State<AccessibilityHubScreen> createState() => _AccessibilityHubScreenState();
}

class _AccessibilityHubScreenState extends State<AccessibilityHubScreen> {
  bool _isPlayingAudio = false;

  final String _simulatedSpokenPrompt =
      'Audio Advisory for Oromia & Amhara farmers: Wheat stripe rust alert. '
      'Please inspect your wheat fields for yellowish spots. '
      'If detected, contact your local extension officer immediately.';

  void _toggleAudioSimulation() {
    setState(() {
      _isPlayingAudio = !_isPlayingAudio;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final loc = AppLocalizations.current;

    return ScreenBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(loc.accessibilitySettings),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.p16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Notice banner
              Card(
                color: theme.primaryColor.withValues(alpha: 0.08),
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.p16),
                  child: Row(
                    children: [
                      Icon(Icons.accessibility_new_rounded, color: theme.primaryColor, size: 32),
                      const SizedBox(width: AppSizes.p12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Voice & High-Contrast Center',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Designed for easy readability in outdoor daylight and voice-assisted interaction for rural farmers.',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.p16),

              // Simulated Audio Player
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.p16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _isPlayingAudio ? Icons.volume_up_rounded : Icons.headphones_outlined,
                                color: theme.primaryColor,
                              ),
                              const SizedBox(width: AppSizes.p8),
                              const Text(
                                'Audio Readout Simulation',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Simulation',
                              style: TextStyle(fontSize: 10, color: Colors.blue, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.p12),
                      Text(
                        '"$_simulatedSpokenPrompt"',
                        style: const TextStyle(fontStyle: FontStyle.italic, height: 1.4),
                      ),
                      const SizedBox(height: AppSizes.p12),

                      Row(
                        children: [
                          IconButton.filled(
                            icon: Icon(_isPlayingAudio ? Icons.pause_rounded : Icons.play_arrow_rounded),
                            onPressed: _toggleAudioSimulation,
                          ),
                          const SizedBox(width: AppSizes.p12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                LinearProgressIndicator(
                                  value: _isPlayingAudio ? 0.65 : 0.0,
                                  backgroundColor: Colors.grey.shade200,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _isPlayingAudio ? 'Reading aloud (0:18 / 0:28)' : 'Tap play to listen',
                                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.p20),

              // Large, high-contrast quick action cards
              Text(
                'Large Quick-Action Buttons',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSizes.p12),

              _buildLargeButton(
                context,
                icon: Icons.support_agent_rounded,
                title: loc.askExtensionWorker,
                subtitle: 'Submit field photos & get advice',
                color: Colors.green,
                onTap: () => Navigator.pushNamed(context, '/farmer/cases'),
              ),
              const SizedBox(height: AppSizes.p12),

              _buildLargeButton(
                context,
                icon: Icons.storefront_rounded,
                title: loc.marketPricesTitle,
                subtitle: 'Browse commodity prices (Kg/Quintal)',
                color: Colors.amber.shade800,
                onTap: () => Navigator.pushNamed(context, '/farmer/market'),
              ),
              const SizedBox(height: AppSizes.p12),

              _buildLargeButton(
                context,
                icon: Icons.calendar_month_rounded,
                title: loc.cropCalendar,
                subtitle: 'Seasonal planting & weeding schedule',
                color: Colors.indigo,
                onTap: () => Navigator.pushNamed(context, '/farmer/crop-calendar'),
              ),
              const SizedBox(height: AppSizes.p12),

              _buildLargeButton(
                context,
                icon: Icons.offline_pin_rounded,
                title: loc.offlineLibrary,
                subtitle: 'Read saved advice with no internet',
                color: Colors.teal,
                onTap: () => Navigator.pushNamed(context, '/farmer/offline-advisories'),
              ),
              const SizedBox(height: AppSizes.p12),

              _buildLargeButton(
                context,
                icon: Icons.settings_phone_rounded,
                title: 'IVR Voice Simulator',
                subtitle: 'Interactive automated phone keypad menu',
                color: Colors.blue,
                onTap: () => Navigator.pushNamed(context, '/simulator/ivr'),
              ),
              const SizedBox(height: AppSizes.p24),

              // Theme & Language Controls
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.p16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Display & Contrast Settings',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Divider(height: AppSizes.p20),
                      SwitchListTile(
                        title: const Text('Dark Mode / High Contrast'),
                        subtitle: const Text('Improves visibility in bright sunlight'),
                        value: isDark,
                        onChanged: (val) {
                          MyApp.themeNotifier.value = val ? ThemeMode.dark : ThemeMode.light;
                        },
                      ),
                      ListTile(
                        title: const Text('Change Language'),
                        subtitle: Text(
                          'Current: ${LocaleProvider.instance.currentLanguage.englishName} (${LocaleProvider.instance.currentLanguage.nativeName})',
                        ),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => Navigator.pushNamed(context, '/choose-language'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLargeButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.r16),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.p16),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(AppSizes.r16),
          border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppSizes.r12),
              ),
              child: Icon(icon, color: color, size: 30),
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
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: color, size: 18),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_button.dart';

class IvrSimulatorScreen extends StatefulWidget {
  const IvrSimulatorScreen({super.key});

  @override
  State<IvrSimulatorScreen> createState() => _IvrSimulatorScreenState();
}

class _IvrSimulatorScreenState extends State<IvrSimulatorScreen> {
  String _currentMenu = 'language'; // language, main, advisories, weather, alerts
  String _spokenText = 'Welcome to Agri-Insight Beacon. Please select your language. Press 1 for English, 2 for Amharic, 3 for Afaan Oromoo.';
  String _lastInput = '';
  bool _isPlaying = true;

  void _pressKey(String key) {
    setState(() {
      _lastInput = key;
      _isPlaying = true;

      if (_currentMenu == 'language') {
        if (key == '1') {
          _currentMenu = 'main';
          _spokenText = 'English selected. Main Menu: Press 1 for Crop Advisories, Press 2 for Weather Reports, Press 3 for Alert Settings.';
        } else if (key == '2') {
          _currentMenu = 'main';
          _spokenText = 'Amharic selected. Main Menu: Press 1 for Crop Advisories, Press 2 for Weather Reports, Press 3 for Alert Settings.';
        } else if (key == '3') {
          _currentMenu = 'main';
          _spokenText = 'Oromo selected. Main Menu: Press 1 for Crop Advisories, Press 2 for Weather Reports, Press 3 for Alert Settings.';
        } else {
          _spokenText = 'Invalid option. Press 1 for English, 2 for Amharic, 3 for Afaan Oromoo.';
        }
      } else if (_currentMenu == 'main') {
        if (key == '1') {
          _currentMenu = 'advisories';
          _spokenText = 'Crop Advisories: Press 1 for Wheat Rust warning, Press 2 for Maize irrigation tips. Press * to return to Main Menu.';
        } else if (key == '2') {
          _currentMenu = 'weather';
          _spokenText = 'Weather Report: Fair agricultural weather conditions expected this week. Optimal temperature 24°C. Press * to return to Main Menu.';
        } else if (key == '3') {
          _currentMenu = 'alerts';
          _spokenText = 'Alert Settings: Press 1 to Enable SMS Alerts, Press 2 to Disable SMS Alerts. Press * to return to Main Menu.';
        } else {
          _spokenText = 'Invalid option. Main Menu: Press 1 for Crop Advisories, Press 2 for Weather Reports, Press 3 for Alert Settings.';
        }
      } else if (_currentMenu == 'advisories') {
        if (key == '*') {
          _currentMenu = 'main';
          _spokenText = 'Main Menu: Press 1 for Crop Advisories, Press 2 for Weather Reports, Press 3 for Alert Settings.';
        } else if (key == '1') {
          _spokenText = 'Wheat Rust Warning: High probability of fungal growth. Ensure chemical treatment is applied before morning dew. Press * to return to Main Menu.';
        } else if (key == '2') {
          _spokenText = 'Maize irrigation tips: Drip irrigate crops during evenings. Avoid midday watering. Press * to return to Main Menu.';
        }
      } else if (_currentMenu == 'alerts' || _currentMenu == 'weather') {
        if (key == '*') {
          _currentMenu = 'main';
          _spokenText = 'Main Menu: Press 1 for Crop Advisories, Press 2 for Weather Reports, Press 3 for Alert Settings.';
        } else if (_currentMenu == 'alerts' && key == '1') {
          _spokenText = 'SMS alerts successfully enabled. You will receive agricultural updates on your phone. Press * to return to Main Menu.';
        } else if (_currentMenu == 'alerts' && key == '2') {
          _spokenText = 'SMS alerts disabled. Press * to return to Main Menu.';
        }
      }
    });
  }

  void _resetIvr() {
    setState(() {
      _currentMenu = 'language';
      _spokenText = 'Welcome to Agri-Insight Beacon. Please select your language. Press 1 for English, 2 for Amharic, 3 for Afaan Oromoo.';
      _lastInput = '';
      _isPlaying = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('IVR Voice Simulator'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.p16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Voice bubble / spoken response mockup
            Card(
              color: theme.primaryColor.withValues(alpha: 0.05),
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.p20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isPlaying ? Icons.volume_up_rounded : Icons.volume_mute_rounded,
                          color: theme.primaryColor,
                          size: 32,
                        ),
                        const SizedBox(width: AppSizes.p12),
                        Text(
                          'Simulating Spoken Audio',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.p16),
                    Text(
                      '"$_spokenText"',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: AppSizes.p16),
                    
                    // Mock audio wave indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(15, (index) {
                        return Container(
                          width: 4,
                          height: _isPlaying ? (10.0 + (index % 3 == 0 ? 25.0 : 12.0)) : 4.0,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            color: theme.primaryColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: AppSizes.p16),
            if (_lastInput.isNotEmpty) ...[
              Text(
                'Last key pressed: $_lastInput',
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSizes.p12),
            ],

            // Phone Keypad
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.p16),
                child: Column(
                  children: [
                    Text(
                      'Interactive Phone Keypad',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSizes.p16),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 1.5,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: 12,
                      itemBuilder: (context, index) {
                        String keyText = '';
                        if (index < 9) {
                          keyText = '${index + 1}';
                        } else if (index == 9) {
                          keyText = '*';
                        } else if (index == 10) {
                          keyText = '0';
                        } else if (index == 11) {
                          keyText = '#';
                        }

                        return OutlinedButton(
                          onPressed: () => _pressKey(keyText),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppSizes.r8),
                            ),
                          ),
                          child: Text(
                            keyText,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSizes.p16),
            AppButton(
              label: 'Reset IVR Session',
              onPressed: _resetIvr,
            ),
          ],
        ),
      ),
    );
  }
}

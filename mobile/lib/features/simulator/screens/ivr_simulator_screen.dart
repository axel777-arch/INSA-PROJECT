import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/screen_backdrop.dart';
import '../../../../services/api_client.dart';
import '../../../../services/messaging_service.dart';

class IvrSimulatorScreen extends StatefulWidget {
  const IvrSimulatorScreen({super.key});

  @override
  State<IvrSimulatorScreen> createState() => _IvrSimulatorScreenState();
}

class _IvrSimulatorScreenState extends State<IvrSimulatorScreen> {
  late final MessagingService _messagingService;
  final FlutterTts _flutterTts = FlutterTts();

  String? _sessionId;
  String _currentMenu = 'language';
  String _spokenText =
      'Welcome to Agri-Insight Beacon. Please select your language. Press 1 for English, 2 for Amharic, 3 for Afaan Oromoo.';
  String _lastInput = '';
  bool _isLoading = false;
  bool _isSpeaking = false;
  bool _isAudioEnabled = true;
  bool _usingLocalFallback = false;

  int _callDurationSeconds = 0;
  Timer? _callTimer;

  static const List<Map<String, String>> _keypadKeys = [
    {'digit': '1', 'letters': ''},
    {'digit': '2', 'letters': 'ABC'},
    {'digit': '3', 'letters': 'DEF'},
    {'digit': '4', 'letters': 'GHI'},
    {'digit': '5', 'letters': 'JKL'},
    {'digit': '6', 'letters': 'MNO'},
    {'digit': '7', 'letters': 'PQRS'},
    {'digit': '8', 'letters': 'TUV'},
    {'digit': '9', 'letters': 'WXYZ'},
    {'digit': '*', 'letters': 'BACK'},
    {'digit': '0', 'letters': '+'},
    {'digit': '#', 'letters': 'ENTER'},
  ];

  @override
  void initState() {
    super.initState();
    _messagingService = MessagingService(apiClient: ApiClient());
    _initTts();
    _startCallTimer();
    _initIvrSession();
  }

  void _startCallTimer() {
    _callTimer?.cancel();
    _callDurationSeconds = 0;
    _callTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _callDurationSeconds++);
    });
  }

  Future<void> _initTts() async {
    try {
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);

      _flutterTts.setStartHandler(() {
        if (mounted) setState(() => _isSpeaking = true);
      });
      _flutterTts.setCompletionHandler(() {
        if (mounted) setState(() => _isSpeaking = false);
      });
      _flutterTts.setErrorHandler((_) {
        if (mounted) setState(() => _isSpeaking = false);
      });
    } catch (e) {
      debugPrint('[IVR TTS] init error: $e');
    }
  }

  Future<void> _speakText(String text) async {
    if (!_isAudioEnabled) return;
    try {
      await _flutterTts.stop();
      if (text.isEmpty) return;

      // Detect Amharic characters: Unicode range U+1200 - U+137F
      final isAmharic = RegExp(r'[\u1200-\u137F]').hasMatch(text);
      if (isAmharic) {
        await _flutterTts.setLanguage('am-ET');
      } else {
        await _flutterTts.setLanguage('en-US');
      }

      await _flutterTts.speak(text);
    } catch (e) {
      debugPrint('[IVR TTS] speak error: $e');
    }
  }

  @override
  void dispose() {
    _callTimer?.cancel();
    try {
      _flutterTts.stop();
    } catch (_) {}
    super.dispose();
  }

  Future<void> _initIvrSession() async {
    setState(() => _isLoading = true);
    try {
      final res = await _messagingService.startIvrSession('+251911000000');
      if (mounted) {
        final prompt =
            res['prompt']?.toString() ??
            res['message']?.toString() ??
            _spokenText;
        setState(() {
          _usingLocalFallback = false;
          _sessionId = res['sessionId']?.toString();
          _currentMenu = res['currentMenu']?.toString() ?? 'language';
          _spokenText = prompt;
          _isLoading = false;
        });
        _speakText(prompt);
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _usingLocalFallback = true;
        });
        _speakText(_spokenText);
      }
    }
  }

  Future<void> _pressKey(String key) async {
    setState(() {
      _lastInput = key;
    });

    if (_sessionId != null) {
      try {
        final res = await _messagingService.sendIvrDtmf(
          sessionId: _sessionId!,
          key: key,
        );
        if (mounted) {
          final prompt =
              res['prompt']?.toString() ??
              res['message']?.toString() ??
              _spokenText;
          setState(() {
            _currentMenu = res['currentMenu']?.toString() ?? _currentMenu;
            _spokenText = prompt;
          });
          _speakText(prompt);
          return;
        }
      } catch (e) {
        debugPrint('[IVR UI] DTMF network error, using offline demo: $e');
        if (mounted) setState(() => _usingLocalFallback = true);
      }
    }

    _runLocalFallback(key);
  }

  void _runLocalFallback(String key) {
    setState(() {
      if (_currentMenu == 'language') {
        if (key == '1') {
          _currentMenu = 'main';
          _spokenText =
              'English selected. Main Menu: Press 1 for Crop Advisories, Press 2 for Weather Reports, Press 3 for Alert Settings.';
        } else if (key == '2') {
          _currentMenu = 'main';
          _spokenText =
              'አማርኛ ተመርጧል። ዋና ማውጫ፦ ለሰብል ምክሮች 1 ይጫኑ፣ ለአየር ሁኔታ መረጃ 2 ይጫኑ፣ ለአደጋ ጥንቃቄ ቅንብሮች 3 ይጫኑ።';
        } else if (key == '3') {
          _currentMenu = 'main';
          _spokenText =
              'Afaan Oromoo filatameera. Baafata Guddaa: Gorsa midhaaniif 1 tuqi, Haala qilleensaaf 2 tuqi, Qophii akeekkachiisaaf 3 tuqi.';
        } else {
          _spokenText =
              'Invalid option. Press 1 for English, 2 for Amharic, 3 for Afaan Oromoo.';
        }
      } else if (_currentMenu == 'main') {
        if (key == '1') {
          _currentMenu = 'advisories';
          _spokenText =
              'Simulation menu: Press 1 for a sample wheat advisory, Press 2 for sample maize irrigation guidance. Press * to return to Main Menu.';
        } else if (key == '2') {
          _currentMenu = 'weather';
          _spokenText =
              'Simulation only: No live weather provider is configured. Check local forecasts. Press * to return to Main Menu.';
        } else if (key == '3') {
          _currentMenu = 'alerts';
          _spokenText =
              'Alert settings simulation: Press 1 or 2 to preview. No preference will be changed. Press * to return.';
        } else {
          _spokenText =
              'Invalid option. Main Menu: Press 1 for Crop Advisories, Press 2 for Weather Reports, Press 3 for Alert Settings.';
        }
      } else if (_currentMenu == 'advisories') {
        if (key == '*') {
          _currentMenu = 'main';
          _spokenText =
              'Main Menu: Press 1 for Crop Advisories, Press 2 for Weather Reports, Press 3 for Alert Settings.';
        } else if (key == '1') {
          _spokenText =
              'Sample wheat rust advisory for simulator demonstration only. Consult an extension worker for local diagnosis. Press * to return.';
        } else if (key == '2') {
          _spokenText =
              'Sample maize irrigation guidance for simulator demonstration only. Press * to return.';
        } else {
          _spokenText =
              'Invalid selection. Press 1 for wheat, 2 for maize, or * to return.';
        }
      } else if (_currentMenu == 'alerts' || _currentMenu == 'weather') {
        if (key == '*') {
          _currentMenu = 'main';
          _spokenText =
              'Main Menu: Press 1 for Crop Advisories, Press 2 for Weather Reports, Press 3 for Alert Settings.';
        } else if (_currentMenu == 'alerts' && key == '1') {
          _spokenText =
              'Simulation only: SMS alerts would be enabled; no preference was changed. Press * to return.';
        } else if (_currentMenu == 'alerts' && key == '2') {
          _spokenText =
              'Simulation only: SMS alerts would be disabled; no preference was changed. Press * to return.';
        } else if (_currentMenu == 'alerts') {
          _spokenText = 'Invalid selection. Press 1 or 2, or * to return.';
        }
      }
    });
    _speakText(_spokenText);
  }

  Future<void> _resetIvr() async {
    _startCallTimer();
    setState(() {
      _usingLocalFallback = false;
      _currentMenu = 'language';
      _spokenText =
          'Welcome to Agri-Insight Beacon. Please select your language. Press 1 for English, 2 for Amharic, 3 for Afaan Oromoo.';
      _lastInput = '';
    });
    await _initIvrSession();
  }

  String _formatCallDuration(int totalSeconds) {
    final m = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ScreenBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Voice IVR Simulator'),
          actions: [
            IconButton(
              icon: Icon(
                _isAudioEnabled
                    ? Icons.volume_up_rounded
                    : Icons.volume_off_rounded,
              ),
              tooltip: _isAudioEnabled
                  ? 'Mute Voice Audio'
                  : 'Unmute Voice Audio',
              onPressed: () {
                setState(() => _isAudioEnabled = !_isAudioEnabled);
                if (!_isAudioEnabled) {
                  _flutterTts.stop();
                } else {
                  _speakText(_spokenText);
                }
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.p16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.only(bottom: AppSizes.p8),
                  child: LinearProgressIndicator(),
                ),

              if (_usingLocalFallback)
                const Padding(
                  padding: EdgeInsets.only(bottom: AppSizes.p8),
                  child: Text(
                    'Offline simulator demo — backend session is unavailable; no call is being placed.',
                    style: TextStyle(
                      color: AppColors.warning,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

              // Active Call Status Banner
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.p16,
                  vertical: AppSizes.p8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.success.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Simulated Call: ${_formatCallDuration(_callDurationSeconds)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: AppColors.success,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Menu: ${_currentMenu.toUpperCase()}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.p12),

              // Spoken Audio / IVR Prompt Bubble
              Card(
                color: theme.primaryColor.withValues(alpha: 0.06),
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.p16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _isSpeaking
                                ? Icons.record_voice_over_rounded
                                : Icons.voice_chat_rounded,
                            color: theme.primaryColor,
                            size: 26,
                          ),
                          const SizedBox(width: AppSizes.p8),
                          Text(
                            _isSpeaking
                                ? 'Voice Streaming (TTS Playing)'
                                : 'IVR Audio Prompt',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: theme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.replay_rounded, size: 20),
                            tooltip: 'Replay audio prompt',
                            onPressed: () => _speakText(_spokenText),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.p12),
                      Text(
                        '"$_spokenText"',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: AppSizes.p12),

                      // Animated equalizer waves
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(16, (index) {
                          final h = _isSpeaking
                              ? (index % 4 == 0
                                    ? 24.0
                                    : (index % 2 == 0 ? 16.0 : 8.0))
                              : 4.0;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 3,
                            height: h,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              color: _isSpeaking
                                  ? theme.primaryColor
                                  : Colors.grey.shade400,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),

              if (_lastInput.isNotEmpty) ...[
                const SizedBox(height: AppSizes.p8),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: theme.dividerColor),
                    ),
                    child: Text(
                      'Last DTMF Key: "$_lastInput"',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: AppSizes.p12),

              // Interactive DTMF Dialpad
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.p16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.dialpad_rounded, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Interactive DTMF Keypad',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.p16),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              childAspectRatio: 1.45,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                        itemCount: _keypadKeys.length,
                        itemBuilder: (context, index) {
                          final item = _keypadKeys[index];
                          final digit = item['digit']!;
                          final letters = item['letters']!;

                          return OutlinedButton(
                            onPressed: () => _pressKey(digit),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppSizes.r12,
                                ),
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  digit,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (letters.isNotEmpty)
                                  Text(
                                    letters,
                                    style: const TextStyle(
                                      fontSize: 9,
                                      color: Colors.grey,
                                      letterSpacing: 1,
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSizes.p16),
              OutlinedButton.icon(
                icon: const Icon(
                  Icons.call_end_rounded,
                  color: AppColors.error,
                ),
                label: const Text(
                  'Reset / Restart IVR Session',
                  style: TextStyle(color: AppColors.error),
                ),
                onPressed: _resetIvr,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

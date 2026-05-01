import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sakinah_flow/core/widgets/glass_card.dart';
import 'package:sakinah_flow/core/providers/theme_provider.dart';
import 'package:sakinah_flow/features/notifications/services/notification_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _prayerReminders = true;
  bool _habitReminders = true;
  String _selectedTheme = 'Green (Default)';
  String _selectedAdhan = 'Adhan 1';

  final List<String> _themes = [
    'Green (Default)',
    'Blue Ocean',
    'Desert Gold',
    'Night Purple',
  ];

  final List<String> _adhans = [
    'Adhan 1',
    'Adhan 2',
    'Adhan 3',
    'Adhan 4',
    'Adhan 5',
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final notificationService = NotificationService();

    setState(() {
      _prayerReminders = prefs.getBool('prayer_reminders_enabled') ?? true;
      _habitReminders = prefs.getBool('habit_reminders_enabled') ?? true;
      _selectedTheme = ref.read(themeProvider);
      _selectedAdhan = prefs.getString('selected_adhan') ?? 'Adhan 1';
    });

    _notificationsEnabled = await notificationService.hasPermission();
  }

  @override
  void dispose() {
    // Stop any playing adhan when leaving settings
    NotificationService().stopAdhan();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('prayer_reminders_enabled', _prayerReminders);
    await prefs.setBool('habit_reminders_enabled', _habitReminders);
    await ref.read(themeProvider.notifier).setTheme(_selectedTheme);
    await prefs.setString('selected_adhan', _selectedAdhan);
  }

  @override
  Widget build(BuildContext context) {
    final themeColors = ref.watch(themeColorsProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: themeColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          color: Color(0xFFD4AF37),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Settings',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFD4AF37),
                          ),
                        ),
                        Text(
                          'الإعدادات',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFFD4AF37),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    const Text(
                      'Notifications',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFD4AF37),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildSettingCard(
                      icon: Icons.notifications_rounded,
                      title: 'Enable Notifications',
                      arabicTitle: 'تفعيل الإشعارات',
                      value: _notificationsEnabled,
                      onChanged: (value) async {
                        if (value) {
                          final granted = await NotificationService().requestPermission();
                          setState(() {
                            _notificationsEnabled = granted;
                          });
                          if (!granted) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Notification permission denied'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        } else {
                          setState(() {
                            _notificationsEnabled = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildSettingCard(
                      icon: Icons.mosque_rounded,
                      title: 'Prayer Reminders',
                      arabicTitle: 'تذكير الصلاة',
                      value: _prayerReminders,
                      onChanged: (value) {
                        setState(() {
                          _prayerReminders = value;
                        });
                        _saveSettings();
                      },
                    ),
                    if (_prayerReminders) ...[
                      const SizedBox(height: 12),
                      _buildAdhanSelector(),
                    ],
                    const SizedBox(height: 12),
                    _buildSettingCard(
                      icon: Icons.check_circle_rounded,
                      title: 'Habit Reminders',
                      arabicTitle: 'تذكير العادات',
                      value: _habitReminders,
                      onChanged: (value) {
                        setState(() {
                          _habitReminders = value;
                        });
                        _saveSettings();
                      },
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Appearance',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFD4AF37),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildThemeSelector(),
                    const SizedBox(height: 24),
                    const Text(
                      'About',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFD4AF37),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      icon: Icons.info_rounded,
                      title: 'Version',
                      arabicTitle: 'الإصدار',
                      value: '1.0.0',
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      icon: Icons.privacy_tip_rounded,
                      title: 'Privacy Policy',
                      arabicTitle: 'سياسة الخصوصية',
                      value: '',
                      onTap: _openPrivacyPolicy,
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeSelector() {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: InkWell(
        onTap: _showThemeSelectionDialog,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFD4AF37), Color(0xFFB8941C)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.palette_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'App Theme',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      'مظهر التطبيق',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _selectedTheme,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFFD4AF37),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFFD4AF37),
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdhanSelector() {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: InkWell(
        onTap: _showAdhanSelectionDialog,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF059669)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.music_note_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Adhan Sound',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      'صوت الأذان',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _selectedAdhan,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF10B981),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF10B981),
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    required String arabicTitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  arabicTitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFFD4AF37),
            activeTrackColor: const Color(0xFFD4AF37).withValues(alpha: 0.5),
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: Colors.grey.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String arabicTitle,
    required String value,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6B7280), Color(0xFF4B5563)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    arabicTitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            if (value.isNotEmpty)
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              )
            else
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white.withValues(alpha: 0.5),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _openPrivacyPolicy() async {
    final url = Uri.parse('https://omaratef3221.github.io/sakinah-app/privacy.html');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open privacy policy'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showAdhanSelectionDialog() async {
    String? tempSelectedAdhan = _selectedAdhan;
    String? tempPlayingAdhan;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF0F3D30),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: const Color(0xFF10B981).withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF10B981), Color(0xFF059669)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.music_note_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select Adhan Sound',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF10B981),
                          ),
                        ),
                        Text(
                          'اختر صوت الأذان',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Tap to select, press play to preview',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.7),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...List.generate(_adhans.length, (index) {
                      final adhan = _adhans[index];
                      final isSelected = adhan == tempSelectedAdhan;
                      final isPlaying = tempPlayingAdhan == adhan;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GestureDetector(
                          onTap: () {
                            setDialogState(() {
                              tempSelectedAdhan = adhan;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: isSelected
                                  ? const LinearGradient(
                                      colors: [Color(0xFF10B981), Color(0xFF059669)],
                                    )
                                  : null,
                              color: isSelected ? null : Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF10B981)
                                    : Colors.white.withValues(alpha: 0.2),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                // Play/Stop button
                                GestureDetector(
                                  onTap: () async {
                                    if (isPlaying) {
                                      await NotificationService().stopAdhan();
                                      setDialogState(() {
                                        tempPlayingAdhan = null;
                                      });
                                    } else {
                                      await NotificationService().stopAdhan();
                                      await NotificationService().playAdhan(adhan);
                                      setDialogState(() {
                                        tempPlayingAdhan = adhan;
                                      });
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: isPlaying
                                          ? const Color(0xFFEF4444)
                                          : const Color(0xFF10B981),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      isPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        adhan,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                      if (isPlaying)
                                        Text(
                                          'Playing...',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.white.withValues(alpha: 0.7),
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(
                                    Icons.check_circle,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    await NotificationService().stopAdhan();
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 15,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await NotificationService().stopAdhan();
                    setState(() {
                      _selectedAdhan = tempSelectedAdhan ?? _selectedAdhan;
                    });
                    await _saveSettings();
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Save',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showThemeSelectionDialog() async {
    String? tempSelectedTheme = _selectedTheme;

    final themeColors = {
      'Green (Default)': [const Color(0xFF10B981), const Color(0xFF059669)],
      'Blue Ocean': [const Color(0xFF3B82F6), const Color(0xFF2563EB)],
      'Desert Gold': [const Color(0xFFD4AF37), const Color(0xFFB8941C)],
      'Night Purple': [const Color(0xFF9333EA), const Color(0xFF7C3AED)],
    };

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF0F3D30),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFD4AF37), Color(0xFFB8941C)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.palette_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select App Theme',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFD4AF37),
                          ),
                        ),
                        Text(
                          'اختر مظهر التطبيق',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFFD4AF37),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Choose a theme for your app',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.7),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...List.generate(_themes.length, (index) {
                      final theme = _themes[index];
                      final isSelected = theme == tempSelectedTheme;
                      final colors = themeColors[theme]!;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GestureDetector(
                          onTap: () {
                            setDialogState(() {
                              tempSelectedTheme = theme;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: isSelected
                                  ? LinearGradient(colors: colors)
                                  : null,
                              color: isSelected ? null : Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? colors[0]
                                    : Colors.white.withValues(alpha: 0.2),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                // Color preview circle
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(colors: colors),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.3),
                                      width: 2,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    theme,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(
                                    Icons.check_circle,
                                    size: 24,
                                    color: Colors.white,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 15,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      _selectedTheme = tempSelectedTheme ?? _selectedTheme;
                    });
                    await _saveSettings();
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    foregroundColor: const Color(0xFF0F3D30),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Apply',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

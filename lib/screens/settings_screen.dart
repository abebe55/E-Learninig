import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app/app_theme.dart';

/// App settings — persisted locally via SharedPreferences.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifications = true;
  bool _wifiOnly = true;
  bool _offlineMode = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _notifications = prefs.getBool('notifications_enabled') ?? true;
      _wifiOnly = prefs.getBool('wifi_only_downloads') ?? true;
      _offlineMode = prefs.getBool('offline_mode') ?? false;
    });
  }

  Future<void> _saveBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
        children: [
          // ── Account ────────────────────────────────────────
          const _SectionHeading('Account'),
          _SettingsTile(
            icon: Icons.lock_outline_rounded,
            title: 'Change Password',
            subtitle: 'Requires a connected account service',
            onTap: () => _showInfo(
              'Password changes are unavailable in local demo mode. '
              'Connect a backend to enable this securely.',
            ),
          ),
          _SettingsTile(
            icon: Icons.notifications_none_rounded,
            title: 'Notification Preferences',
            subtitle: 'Manage learning reminders',
            trailing: Switch.adaptive(
              value: _notifications,
              onChanged: (value) {
                setState(() => _notifications = value);
                _saveBool('notifications_enabled', value);
              },
            ),
          ),
          const SizedBox(height: 18),

          // ── App ────────────────────────────────────────────
          const _SectionHeading('App'),
          _SettingsTile(
            icon: Icons.cloud_off_outlined,
            title: 'Offline Mode',
            subtitle: 'Prefer lessons already downloaded',
            trailing: Switch.adaptive(
              value: _offlineMode,
              onChanged: (value) {
                setState(() => _offlineMode = value);
                _saveBool('offline_mode', value);
              },
            ),
          ),
          _SettingsTile(
            icon: Icons.wifi_rounded,
            title: 'Wi-Fi Only Downloads',
            subtitle: 'Only download on Wi-Fi connections',
            trailing: Switch.adaptive(
              value: _wifiOnly,
              onChanged: (value) {
                setState(() => _wifiOnly = value);
                _saveBool('wifi_only_downloads', value);
              },
            ),
          ),
          _SettingsTile(
            icon: Icons.storage_outlined,
            title: 'Data Usage',
            subtitle: 'Downloads stored in app-private storage',
            onTap: () => _showInfo(
              'Downloaded videos are stored inside LearnFlow app storage '
              'and can be removed from the Downloads tab.',
            ),
          ),
          const SizedBox(height: 18),

          // ── About ──────────────────────────────────────────
          const _SectionHeading('About'),
          const _SettingsTile(
            icon: Icons.info_outline_rounded,
            title: 'App Version',
            subtitle: '1.0.0 • LearnFlow student app',
          ),
          const SizedBox(height: 20),
          const Text(
            'Some settings require a backend connection. '
            'This prototype stores preferences locally on your device.',
            style: TextStyle(
              color: AppTheme.muted,
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  void _showInfo(String message) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

// ── Private widgets ──────────────────────────────────────────────────────────

class _SectionHeading extends StatelessWidget {
  const _SectionHeading(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: AppTheme.blue,
          fontWeight: FontWeight.w800,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 7),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: AppTheme.blue, size: 21),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.muted,
                ),
              )
            : null,
        trailing: trailing ??
            const Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.muted,
              size: 20,
            ),
      ),
    );
  }
}

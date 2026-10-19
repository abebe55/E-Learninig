import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app/app_theme.dart';

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
  void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() { _notifications = prefs.getBool('notifications_enabled') ?? true; _wifiOnly = prefs.getBool('wifi_only_downloads') ?? true; _offlineMode = prefs.getBool('offline_mode') ?? false; });
  }
  Future<void> _save(String key, bool value) async { final prefs = await SharedPreferences.getInstance(); await prefs.setBool(key, value); }
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Settings')),
    body: ListView(padding: const EdgeInsets.fromLTRB(18, 8, 18, 24), children: [
      const _Heading('Account'),
      _SettingsTile(icon: Icons.lock_outline_rounded, title: 'Change Password', subtitle: 'Requires connected account service', onTap: () => _info('Password changes are unavailable in local demo mode. Connect the backend to enable this securely.')),
      _SettingsTile(icon: Icons.notifications_none_rounded, title: 'Notification Preferences', subtitle: 'Manage learning reminders', trailing: Switch.adaptive(value: _notifications, onChanged: (v) { setState(() => _notifications = v); _save('notifications_enabled', v); })),
      const SizedBox(height: 18),
      const _Heading('App'),
      _SettingsTile(icon: Icons.cloud_off_outlined, title: 'Offline Mode', subtitle: 'Prefer lessons already downloaded', trailing: Switch.adaptive(value: _offlineMode, onChanged: (v) { setState(() => _offlineMode = v); _save('offline_mode', v); })),
      _SettingsTile(icon: Icons.wifi_rounded, title: 'Wi-Fi Only Downloads', subtitle: 'Preference for future download controls', trailing: Switch.adaptive(value: _wifiOnly, onChanged: (v) { setState(() => _wifiOnly = v); _save('wifi_only_downloads', v); })),
      _SettingsTile(icon: Icons.storage_outlined, title: 'Data Usage', subtitle: 'Downloads are stored in app-private storage', onTap: () => _info('Downloaded videos are stored inside LearnFlow app storage and can be removed from the Downloads tab.')),
      const SizedBox(height: 18),
      const _Heading('About'),
      const _SettingsTile(icon: Icons.info_outline_rounded, title: 'App Version', subtitle: '1.0.0 • LearnFlow student app'),
      const SizedBox(height: 20),
      const Text('Some account settings require the planned backend. This prototype stores app preferences locally on this device.', style: TextStyle(color: AppTheme.muted, fontSize: 12, height: 1.5)),
    ]),
  );
  void _info(String message) => showDialog<void>(context: context, builder: (context) => AlertDialog(content: Text(message), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))]));
}
class _Heading extends StatelessWidget {
  const _Heading(this.title); final String title;
  @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(title, style: const TextStyle(color: AppTheme.blue, fontWeight: FontWeight.w800, fontSize: 13)));
}
class _SettingsTile extends StatelessWidget {
  const _SettingsTile({required this.icon, required this.title, this.subtitle, this.trailing, this.onTap}); final IconData icon; final String title; final String? subtitle; final Widget? trailing; final VoidCallback? onTap;
  @override Widget build(BuildContext context) => Card(margin: const EdgeInsets.only(bottom: 7), child: ListTile(onTap: onTap, leading: Icon(icon, color: AppTheme.blue, size: 21), title: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)), subtitle: subtitle == null ? null : Text(subtitle!, style: const TextStyle(fontSize: 11, color: AppTheme.muted)), trailing: trailing ?? const Icon(Icons.chevron_right_rounded, color: AppTheme.muted, size: 20)));
}

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/admin_page_scaffold.dart';
import '../../widgets/glass_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _clinicNameController = TextEditingController(text: 'PureDent Clinic');
  final _emailController = TextEditingController(text: 'hariharabalan787@gmail.com');
  final _phoneController = TextEditingController(text: '+1 (555) 234-9000');

  final Map<String, bool> _notifications = {
    'New appointment bookings': true,
    'Appointment cancellations': true,
    'Low inventory alerts': true,
    'Daily revenue summary email': false,
  };

  bool _showSaved = false;

  @override
  void dispose() {
    _clinicNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    setState(() => _showSaved = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _showSaved = false);
  }

  @override
  Widget build(BuildContext context) {
    return AdminPageScaffold(
      title: 'Settings',
      subtitle: 'Clinic profile & preferences',
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          children: [
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Clinic Profile', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 16),
                  _fieldLabel('Clinic Name'),
                  TextField(controller: _clinicNameController),
                  const SizedBox(height: 14),
                  _fieldLabel('Contact Email'),
                  TextField(controller: _emailController, keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 14),
                  _fieldLabel('Phone Number'),
                  TextField(controller: _phoneController, keyboardType: TextInputType.phone),
                ],
              ),
            ),
            const SizedBox(height: 16),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Notification Preferences', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  ..._notifications.keys.map((key) {
                    return Row(
                      children: [
                        Expanded(child: Text(key, style: const TextStyle(fontSize: 13))),
                        Switch(
                          value: _notifications[key]!,
                          activeThumbColor: AppColors.primary,
                          onChanged: (value) => setState(() => _notifications[key] = value),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _handleSave,
                child: const Text('Save Changes'),
              ),
            ),
            const SizedBox(height: 12),
            AnimatedOpacity(
              opacity: _showSaved ? 1 : 0,
              duration: const Duration(milliseconds: 250),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.check_circle_rounded, color: AppColors.secondary, size: 18),
                  SizedBox(width: 6),
                  Text('Settings saved', style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant)),
      );
}
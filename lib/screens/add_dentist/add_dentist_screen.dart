import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/admin_page_scaffold.dart';
import '../../widgets/glass_card.dart';

class AddDentistScreen extends StatefulWidget {
  const AddDentistScreen({super.key});

  @override
  State<AddDentistScreen> createState() => _AddDentistScreenState();
}

class _AddDentistScreenState extends State<AddDentistScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _experienceController = TextEditingController();
  final _bioController = TextEditingController();

  String _specialization = 'General Dentistry';
  final _specializations = const [
    'General Dentistry',
    'Orthodontics',
    'Periodontics',
    'Oral Surgery',
    'Cosmetic Dentistry',
    'Endodontics',
    'Pediatric Dentistry',
  ];

  final Set<String> _workingDays = {};
  final _weekdays = const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  bool _isSubmitting = false;
  bool _showSuccess = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _experienceController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_nameController.text.trim().isEmpty || _emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in the required fields.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    // TODO: replace with a real POST to your server's /api/dentists endpoint,
    // e.g. using package:http and MultipartRequest for the photo upload.
    await Future.delayed(const Duration(milliseconds: 900));

    if (!mounted) return;
    setState(() {
      _isSubmitting = false;
      _showSuccess = true;
    });

    await Future.delayed(const Duration(milliseconds: 1600));
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AdminPageScaffold(
      title: 'Add Dentist',
      subtitle: 'Onboard a new specialist',
      child: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            child: GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.outlineVariant, width: 2),
                      ),
                      child: const Icon(Icons.person_outline_rounded, color: AppColors.outline, size: 36),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: TextButton.icon(
                      onPressed: () {
                        // TODO: hook up image_picker package here for photo upload.
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Add the image_picker package to enable photo upload.')),
                        );
                      },
                      icon: const Icon(Icons.upload_rounded),
                      label: const Text('Upload Photo'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _label('Full Name'),
                  TextField(controller: _nameController, decoration: const InputDecoration(hintText: 'Dr. Jane Doe')),
                  const SizedBox(height: 16),
                  _label('Specialization'),
                  DropdownButtonFormField<String>(
                    initialValue: _specialization,
                    decoration: const InputDecoration(),
                    items: _specializations
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (value) => setState(() => _specialization = value ?? _specialization),
                  ),
                  const SizedBox(height: 16),
                  _label('Email Address'),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(hintText: 'jane.doe@puredent.com'),
                  ),
                  const SizedBox(height: 16),
                  _label('Phone Number'),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(hintText: '+1 (555) 234-9000'),
                  ),
                  const SizedBox(height: 16),
                  _label('Years of Experience'),
                  TextField(
                    controller: _experienceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: '8'),
                  ),
                  const SizedBox(height: 16),
                  _label('Bio'),
                  TextField(
                    controller: _bioController,
                    maxLines: 4,
                    decoration: const InputDecoration(hintText: 'A short professional summary...'),
                  ),
                  const SizedBox(height: 16),
                  _label('Working Days'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _weekdays.map((day) {
                      final selected = _workingDays.contains(day);
                      return GestureDetector(
                        onTap: () => setState(() {
                          selected ? _workingDays.remove(day) : _workingDays.add(day);
                        }),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: selected ? AppColors.secondaryContainer.withValues(alpha: 0.5) : AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            day,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: selected ? AppColors.onSecondaryContainer : AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isSubmitting ? null : _handleSave,
                      icon: _isSubmitting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.person_add_alt_1_rounded, size: 18),
                      label: Text(_isSubmitting ? 'Saving...' : 'Save Dentist'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Success overlay animation
          AnimatedOpacity(
            duration: const Duration(milliseconds: 250),
            opacity: _showSuccess ? 1 : 0,
            child: IgnorePointer(
              ignoring: !_showSuccess,
              child: Container(
                color: AppColors.background.withValues(alpha: 0.95),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: _showSuccess ? 1 : 0),
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.elasticOut,
                        builder: (context, value, child) => Transform.scale(scale: value, child: child),
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: const BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle),
                          child: const Icon(Icons.check_rounded, color: Colors.white, size: 40),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text('Dentist added successfully', style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant)),
      );
}
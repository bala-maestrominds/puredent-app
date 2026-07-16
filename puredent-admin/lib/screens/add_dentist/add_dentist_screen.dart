import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/services/doctors_service.dart';
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
  final _feeController = TextEditingController();
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
  static const _fullDayNames = {
    'Mon': 'monday',
    'Tue': 'tuesday',
    'Wed': 'wednesday',
    'Thu': 'thursday',
    'Fri': 'friday',
    'Sat': 'saturday',
    'Sun': 'sunday',
  };

  XFile? _photo;
  bool _isSubmitting = false;
  bool _showSuccess = false;
  String? _errorText;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _experienceController.dispose();
    _feeController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1200, imageQuality: 85);
    if (file != null) setState(() => _photo = file);
  }

  Future<void> _handleSave() async {
    if (_nameController.text.trim().isEmpty || _emailController.text.trim().isEmpty) {
      setState(() => _errorText = 'Please fill in the required fields.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });

    try {
      // Every selected day gets a default 9:00-17:00 shift. Editable later
      // from a doctor's detail view if you build that out.
      final workingHours = _workingDays
          .map((d) => {'day': _fullDayNames[d]!, 'startTime': '09:00', 'endTime': '17:00'})
          .toList();

      await DoctorsService.instance.create(
        name: _nameController.text.trim(),
        specialty: _specialization,
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        experienceYears: int.tryParse(_experienceController.text.trim()) ?? 0,
        consultationFee: num.tryParse(_feeController.text.trim()) ?? 0,
        bio: _bioController.text.trim(),
        workingHours: workingHours,
        photoPath: _photo?.path,
      );

      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _showSuccess = true;
      });

      await Future.delayed(const Duration(milliseconds: 1600));
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorText = '$e';
      });
    }
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
                    child: GestureDetector(
                      onTap: _pickPhoto,
                      child: Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.outlineVariant, width: 2),
                          image: _photo != null
                              ? DecorationImage(image: FileImage(File(_photo!.path)), fit: BoxFit.cover)
                              : null,
                        ),
                        child: _photo == null
                            ? const Icon(Icons.person_outline_rounded, color: AppColors.outline, size: 36)
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: TextButton.icon(
                      onPressed: _pickPhoto,
                      icon: const Icon(Icons.upload_rounded),
                      label: Text(_photo == null ? 'Upload Photo' : 'Change Photo'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _label('Full Name'),
                  TextField(controller: _nameController, decoration: const InputDecoration(hintText: 'Dr. Jane Doe',hintStyle: TextStyle(color: Colors.grey))),
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
                    decoration: const InputDecoration(hintText: 'jane.doe@puredent.com',
                      hintStyle: TextStyle(color: Colors.grey)
                    ),
                  ),
                  const SizedBox(height: 16),
                  _label('Phone Number'),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(hintText: '+91 9876543210',
                      hintStyle: TextStyle(color: Colors.grey)
                    ),
                  ),
                  const SizedBox(height: 16),
                  _label('Years of Experience'),
                  TextField(
                    controller: _experienceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: '8', hintStyle: TextStyle(color: Colors.grey)
                    ),
                  ),
                  const SizedBox(height: 16),
                  _label('Consultation Fee (\$)'),
                  TextField(
                    controller: _feeController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(hintText: '120', hintStyle: TextStyle(color: Colors.grey)
                    ),
                  ),
                  const SizedBox(height: 16),
                  _label('Bio'),
                  TextField(
                    controller: _bioController,
                    maxLines: 4,
                    decoration: const InputDecoration(hintText: 'A short professional summary...', hintStyle: TextStyle(color: Colors.grey)
                    ),
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
                  AnimatedSize(
                    duration: const Duration(milliseconds: 250),
                    child: _errorText != null
                        ? Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: AppColors.errorContainer.withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.error.withValues(alpha: 0.15)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(_errorText!, style: const TextStyle(color: AppColors.error, fontSize: 13))),
                                ],
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
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

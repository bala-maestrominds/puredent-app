import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../bloc/booking_bloc.dart';

/// NOTE: The backend does not yet integrate a real payment gateway (Stripe/
/// Razorpay). Card and GPay payments here are processed as an instant mock
/// charge — the fields are NOT validated (any input is accepted), then
/// the appointment is booked with `paymentMethod: 'Card'` or `'GPay'`, which
/// the backend treats as paid immediately for whichever portion (full or
/// consultation fee) was selected. Swap `_charge()` for a real gateway call
/// once one is wired into the backend.
class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String _method = 'Card';

  final _cardNumberController = TextEditingController();
  final _cardExpiryController = TextEditingController();
  final _cardCvvController = TextEditingController();
  final _cardNameController = TextEditingController();
  final _upiIdController = TextEditingController();

  final _methods = const [
    ('Card', Icons.credit_card_rounded, 'Pay securely online, instantly'),
    (
      'GPay',
      Icons.qr_code_scanner_rounded,
      'Pay instantly via Google Pay / UPI'
    ),
    (
      'PayPal',
      Icons.account_balance_wallet_outlined,
      'Pay using your PayPal account'
    ),
    ('Razorpay', Icons.payment_rounded, 'Pay via card, UPI, netbanking & more'),
  ];

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardExpiryController.dispose();
    _cardCvvController.dispose();
    _cardNameController.dispose();
    _upiIdController.dispose();
    super.dispose();
  }

  void _confirm() {
    context.read<BookingBloc>().add(BookingPaymentMethodSelected(_method));
    context.read<BookingBloc>().add(const BookingSubmitRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: BlocConsumer<BookingBloc, BookingState>(
        listener: (context, state) {
          if (state.status == BookingStatus.success) {
            context.go('/booking/confirmation');
          }
          if (state.status == BookingStatus.failure) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(
                  content: Text(state.failure?.message ?? 'Booking failed')));
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(AppSpacing.marginMobile),
            child: ListView(
              children: [
                _SummaryCard(state: state),
                const SizedBox(height: AppSpacing.lg),
                Text('How would you like to pay?',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: AppSpacing.sm),
                _PaymentOptionCard(
                  title: 'Pay full amount now',
                  subtitle:
                      'Settle the entire treatment cost (\$${state.servicePrice.toStringAsFixed(2)}) today.',
                  icon: Icons.payments_rounded,
                  selected: state.paymentOption == kFullPayment,
                  onTap: () => context
                      .read<BookingBloc>()
                      .add(const BookingPaymentOptionSelected(kFullPayment)),
                ),
                const SizedBox(height: 10),
                _PaymentOptionCard(
                  title: 'Pay consultation fee only',
                  subtitle: state.consultationFee > 0
                      ? 'Pay just \$${state.consultationFee.toStringAsFixed(2)} now. The remaining '
                          '\$${(state.servicePrice - state.consultationFee).clamp(0, double.infinity).toStringAsFixed(2)} '
                          'is due after your treatment.'
                      : 'Pay only the consultation fee now; the treatment balance is settled after your visit.',
                  icon: Icons.medical_services_outlined,
                  selected: state.paymentOption == kConsultationFeeOnly,
                  onTap: () => context.read<BookingBloc>().add(
                      const BookingPaymentOptionSelected(kConsultationFeeOnly)),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text('Payment method',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: AppSpacing.sm),
                ..._methods.map((m) {
                  final (label, icon, subtitle) = m;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Card(
                      child: RadioListTile<String>(
                        value: label,
                        groupValue: _method,
                        onChanged: (v) => setState(() => _method = v!),
                        secondary: Icon(icon, color: AppColors.primary),
                        title: Text(label),
                        subtitle: Text(subtitle,
                            style: Theme.of(context).textTheme.bodySmall),
                      ),
                    ),
                  );
                }),
                if (_method == 'Card') ...[
                  const SizedBox(height: 4),
                  _CardDetailsForm(
                    numberController: _cardNumberController,
                    expiryController: _cardExpiryController,
                    cvvController: _cardCvvController,
                    nameController: _cardNameController,
                  ),
                ],
                if (_method == 'GPay') ...[
                  const SizedBox(height: 4),
                  _GPayDetailsForm(upiIdController: _upiIdController),
                ],
                const SizedBox(height: AppSpacing.lg),
                _AmountDueCard(state: state),
                const SizedBox(height: AppSpacing.lg),
                AppPrimaryButton(
                  label:
                      'Pay \$${state.amountDueNow.toStringAsFixed(2)} & Confirm',
                  isLoading: state.status == BookingStatus.submitting,
                  onPressed: _confirm,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CardDetailsForm extends StatelessWidget {
  const _CardDetailsForm({
    required this.numberController,
    required this.expiryController,
    required this.cvvController,
    required this.nameController,
  });

  final TextEditingController numberController;
  final TextEditingController expiryController;
  final TextEditingController cvvController;
  final TextEditingController nameController;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lock_outline_rounded,
                    size: 15, color: AppColors.outline),
                const SizedBox(width: 6),
                Text('Card details',
                    style: Theme.of(context).textTheme.titleSmall),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: nameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Name on card'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: numberController,
              keyboardType: TextInputType.number,
              maxLength: 19,
              decoration: const InputDecoration(
                  labelText: 'Card number', counterText: ''),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: expiryController,
                    keyboardType: TextInputType.datetime,
                    decoration: const InputDecoration(labelText: 'MM/YY'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: cvvController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    maxLength: 4,
                    decoration: const InputDecoration(
                        labelText: 'CVV', counterText: ''),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GPayDetailsForm extends StatelessWidget {
  const _GPayDetailsForm({required this.upiIdController});

  final TextEditingController upiIdController;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.qr_code_scanner_rounded,
                    size: 15, color: AppColors.outline),
                const SizedBox(width: 6),
                Text('Google Pay / UPI',
                    style: Theme.of(context).textTheme.titleSmall),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: upiIdController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'UPI ID',
                hintText: 'yourname@okhdfcbank',
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'You\'ll get a payment request on your GPay app to approve.',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.outline),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentOptionCard extends StatelessWidget {
  const _PaymentOptionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color:
          selected ? AppColors.primaryContainer.withValues(alpha: 0.35) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.base),
        side: BorderSide(
            color: selected ? AppColors.primary : AppColors.outlineVariant,
            width: selected ? 1.5 : 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.base),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: AppColors.primary),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              Radio<bool>(
                  value: true,
                  groupValue: selected ? true : null,
                  onChanged: (_) => onTap()),
            ],
          ),
        ),
      ),
    );
  }
}

class _AmountDueCard extends StatelessWidget {
  const _AmountDueCard({required this.state});
  final BookingState state;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Row(
                label: 'Amount due now',
                value: '\$${state.amountDueNow.toStringAsFixed(2)}',
                emphasize: true),
            if (state.isConsultationOnly)
              _Row(
                  label: 'Balance after treatment',
                  value: '\$${state.balanceDue.toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.state});
  final BookingState state;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Booking Summary',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            _Row(label: 'Doctor', value: state.doctorName ?? '-'),
            _Row(label: 'Service', value: state.serviceName ?? '-'),
            _Row(label: 'Date', value: state.date ?? '-'),
            _Row(label: 'Time', value: state.time ?? '-'),
            _Row(label: 'Patient', value: state.patientName ?? '-'),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(
      {required this.label, required this.value, this.emphasize = false});
  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          Text(
            value,
            style: emphasize
                ? Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.primary, fontWeight: FontWeight.w700)
                : Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

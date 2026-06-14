import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/validators.dart';
import '../../models/provider_model.dart';
import '../../models/service_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../widgets/custom_button.dart';
import 'booking_confirmation_screen.dart';

/// The booking form — lets the user pick date, time, and enter their address
class BookingScreen extends StatefulWidget {
  final ProviderModel provider;
  final ServiceCategory category;

  const BookingScreen({
    super.key,
    required this.provider,
    required this.category,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _landmarkController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime? _selectedDate;
  String? _selectedTime;

  // Available time slots
  final List<String> _timeSlots = [
    '8:00 AM', '9:00 AM', '10:00 AM', '11:00 AM',
    '12:00 PM', '1:00 PM', '2:00 PM', '3:00 PM',
    '4:00 PM', '5:00 PM', '6:00 PM', '7:00 PM',
  ];

  @override
  void dispose() {
    _addressController.dispose();
    _landmarkController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Date Picker
  // ---------------------------------------------------------------------------

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  // ---------------------------------------------------------------------------
  // Confirm Booking
  // ---------------------------------------------------------------------------

  void _confirmBooking() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date for the service.')),
      );
      return;
    }

    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a preferred time slot.')),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final bookingProvider = context.read<BookingProvider>();
    final user = authProvider.currentUser!;

    final success = await bookingProvider.createBooking(
      customerId: user.uid,
      customerName: user.fullName,
      customerPhone: user.phoneNumber,
      providerId: widget.provider.id,
      providerName: widget.provider.fullName,
      serviceId: widget.category.id,
      serviceName: widget.category.name,
      serviceCategory: widget.category.id,
      scheduledDate: _selectedDate!,
      scheduledTime: _selectedTime!,
      address: _addressController.text.trim(),
      landmark: _landmarkController.text.trim().isEmpty
          ? null
          : _landmarkController.text.trim(),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      estimatedAmount: widget.provider.chargePerHour,
    );

    if (success && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => BookingConfirmationScreen(
            bookingId: bookingProvider.lastCreatedBookingId ?? '',
            providerName: widget.provider.fullName,
            serviceName: widget.category.name,
            date: DateFormat('EEE, d MMM yyyy').format(_selectedDate!),
            time: _selectedTime!,
            address: _addressController.text.trim(),
            amount: widget.provider.chargePerHour,
          ),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.bookingFailed)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = context.watch<BookingProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text(AppStrings.bookService)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ----------------------------------------------------------------
            // Provider summary card at the top
            // ----------------------------------------------------------------
            _ProviderSummaryCard(
              provider: widget.provider,
              category: widget.category,
            ),

            const SizedBox(height: 24),

            // ----------------------------------------------------------------
            // Section: Select Date
            // ----------------------------------------------------------------
            const _SectionLabel(AppStrings.selectDate),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border.all(
                    color: _selectedDate != null
                        ? AppColors.primary
                        : AppColors.border,
                    width: _selectedDate != null ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded,
                        color: AppColors.primary, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      _selectedDate != null
                          ? DateFormat('EEEE, d MMMM yyyy')
                              .format(_selectedDate!)
                          : 'Tap to choose a date',
                      style: TextStyle(
                        color: _selectedDate != null
                            ? AppColors.textPrimary
                            : AppColors.textHint,
                        fontWeight: _selectedDate != null
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 22),

            // ----------------------------------------------------------------
            // Section: Select Time Slot
            // ----------------------------------------------------------------
            const _SectionLabel(AppStrings.selectTime),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _timeSlots.map((slot) {
                final isSelected = _selectedTime == slot;
                return GestureDetector(
                  onTap: () => setState(() => _selectedTime = slot),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.surface,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.border,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      slot,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 22),

            // ----------------------------------------------------------------
            // Section: Address
            // ----------------------------------------------------------------
            const _SectionLabel(AppStrings.enterAddress),
            const SizedBox(height: 10),
            TextFormField(
              controller: _addressController,
              validator: Validators.address,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: AppStrings.addressHint,
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: Icon(Icons.location_on_outlined),
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _landmarkController,
              decoration: const InputDecoration(
                hintText: 'e.g. Near City Mall',
                prefixIcon: Icon(Icons.flag_outlined),
                labelText: AppStrings.landmark,
              ),
            ),

            const SizedBox(height: 22),

            // ----------------------------------------------------------------
            // Section: Notes
            // ----------------------------------------------------------------
            const _SectionLabel(AppStrings.addNotes),
            const SizedBox(height: 10),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: AppStrings.notesHint,
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 44),
                  child: Icon(Icons.note_outlined),
                ),
              ),
            ),

            const SizedBox(height: 22),

            // ----------------------------------------------------------------
            // Pricing summary
            // ----------------------------------------------------------------
            _PriceSummaryRow(
              serviceName: widget.category.name,
              amount: widget.provider.chargePerHour,
            ),

            const SizedBox(height: 28),

            // Confirm booking button
            CustomButton(
              label: AppStrings.confirmBooking,
              onPressed: _confirmBooking,
              isLoading: bookingProvider.isCreating,
              icon: Icons.check_circle_rounded,
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------------------
// Internal sub-widgets
// ----------------------------------------------------------------

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _ProviderSummaryCard extends StatelessWidget {
  final ProviderModel provider;
  final ServiceCategory category;
  const _ProviderSummaryCard(
      {required this.provider, required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: AppColors.primaryLight.withValues(alpha: 0.2),
            child: Text(
              provider.fullName[0].toUpperCase(),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  provider.fullName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  category.name,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  const Icon(Icons.star_rounded,
                      color: AppColors.starActive, size: 15),
                  const SizedBox(width: 3),
                  Text(
                    provider.rating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              Text(
                provider.formattedCharge,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PriceSummaryRow extends StatelessWidget {
  final String serviceName;
  final double amount;
  const _PriceSummaryRow({required this.serviceName, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _Row(label: 'Service', value: serviceName),
          const Divider(height: 16, color: AppColors.divider),
          _Row(label: 'Service Charge', value: '₹${amount.toStringAsFixed(0)}/hr'),
          const Divider(height: 16, color: AppColors.divider),
          const _Row(label: 'Payment Mode', value: AppStrings.cashOnService),
          const Divider(height: 16, color: AppColors.divider),
          _Row(
            label: 'Estimated Total',
            value: '₹${amount.toStringAsFixed(0)}',
            isBold: true,
            valueColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;
  const _Row({
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13, color: AppColors.textSecondary)),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

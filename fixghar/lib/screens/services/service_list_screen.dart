import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../models/provider_model.dart';
import '../../models/service_model.dart';
import '../../providers/service_provider.dart';
import '../../widgets/service_card.dart';
import '../booking/booking_screen.dart';

/// Lists all available service providers for the selected category
class ServiceListScreen extends StatefulWidget {
  final ServiceCategory category;

  const ServiceListScreen({super.key, required this.category});

  @override
  State<ServiceListScreen> createState() => _ServiceListScreenState();
}

class _ServiceListScreenState extends State<ServiceListScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch providers when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<ServiceProvider>()
          .fetchProvidersByCategory(widget.category.id);
    });
  }

  @override
  void dispose() {
    context.read<ServiceProvider>().clearProviders();
    super.dispose();
  }

  void _openBooking(ProviderModel provider) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BookingScreen(
          provider: provider,
          category: widget.category,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final serviceProvider = context.watch<ServiceProvider>();
    final providers = serviceProvider.providers;
    final isLoading = serviceProvider.isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.category.name),
        actions: [
          // Filter icon (placeholder — wire up filter sheet as a future feature)
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            onPressed: () => _showFilterSheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              onChanged: context.read<ServiceProvider>().updateSearchQuery,
              decoration: InputDecoration(
                hintText: 'Search providers, areas...',
                prefixIcon: const Icon(Icons.search_rounded,
                    color: AppColors.textSecondary, size: 20),
                suffixIcon: serviceProvider.searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: context.read<ServiceProvider>().clearSearch,
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
              ),
            ),
          ),

          // Result count
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
            child: Row(
              children: [
                Text(
                  isLoading
                      ? 'Loading...'
                      : '${providers.length} provider${providers.length == 1 ? '' : 's'} found',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Provider list
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : providers.isEmpty
                    ? _EmptyState(categoryName: widget.category.name)
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                        itemCount: providers.length,
                        itemBuilder: (context, index) {
                          return ServiceCard(
                            provider: providers[index],
                            onBookTap: () => _openBooking(providers[index]),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  /// Bottom sheet for filtering providers (Rating, Price, Availability)
  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter & Sort',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            _FilterChipRow(
              label: 'Sort by Rating',
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 12),
            _FilterChipRow(
              label: 'Sort by Price (Low to High)',
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 12),
            _FilterChipRow(
              label: 'Available Only',
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _FilterChipRow extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _FilterChipRow({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 14)),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String categoryName;
  const _EmptyState({required this.categoryName});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off_rounded,
                size: 72, color: AppColors.textHint),
            const SizedBox(height: 16),
            const Text(
              AppStrings.noProvidersFound,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'We\'re working on expanding $categoryName services in your area.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

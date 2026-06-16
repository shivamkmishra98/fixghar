import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../models/service_model.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/category_card.dart';
import '../services/service_list_screen.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../services/location_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// Main home screen showing greeting, search bar, and service category grid
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();

  String location = "Shivam Test";
  final LocationService _locationService = LocationService();

  final TextEditingController _locationSearchController =
    TextEditingController();

  List<String> _placeSuggestions = [];

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  Future<void> _loadLocation() async {
    String address = await _locationService.getCurrentAddress();

    if (mounted) {
      setState(() {
        location = address;
      });
    }
  }
  Future<void> _searchPlaces(String query) async {
  if (query.isEmpty) {
    setState(() {
      _placeSuggestions = [];
    });
    return;
  }

  const apiKey = "AIzaSyAURTGJuPNFtfK1H_yKP2iANEgYLu01rNA";

  final url =
      "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&key=$apiKey";

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final data = json.decode(response.body);

    setState(() {
      _placeSuggestions = (data['predictions'] as List)
          .map((e) => e['description'].toString())
          .toList();
    });
  }
}

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Returns time-appropriate greeting
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return AppStrings.goodMorning;
    if (hour < 17) return AppStrings.goodAfternoon;
    return AppStrings.goodEvening;
  }

  /// Navigate to the service listing screen for a category
  void _openCategory(ServiceCategory category) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ServiceListScreen(category: category),
      ),
    );
  }

  /// Handles search — filters by query text and navigates to results
  void _onSearch(String query) {
    if (query.trim().isEmpty) return;
    // Find matching category and navigate, or show generic results
    final match = ServiceCategory.all
        .where((c) => c.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
    if (match.isNotEmpty) {
      _openCategory(match.first);
    }
  }
  void _showLocationBottomSheet() {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      // return Container(
      //   padding: const EdgeInsets.all(20),
      //   child: const Text("Choose Location"),
      // );
      return Container(
       padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

           const Text(
              "Select delivery location",
              style: TextStyle(
                fontSize: 18,
               fontWeight: FontWeight.bold,
             ),
            ),

           const SizedBox(height: 16),

          //  TextField(
          //    decoration: InputDecoration(
          //      hintText: "Search area, street name...",
          //      prefixIcon: const Icon(Icons.search),
          //      filled: true,
          //       fillColor: Colors.grey.shade100,
          //      border: OutlineInputBorder(
          //        borderRadius: BorderRadius.circular(12),
          //        borderSide: BorderSide.none,
          //       ),
          //     ),
          //  ),
          TextField(
            controller: _locationSearchController,
            onChanged: (value) {
              _searchPlaces(value);
            },
            decoration: InputDecoration(
             hintText: "Search area, street name...",
             prefixIcon: const Icon(Icons.search),
             filled: true,
             fillColor: Colors.grey.shade100,
             border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          if (_placeSuggestions.isNotEmpty)
            SizedBox(
              height: 200,
             child: ListView.builder(
               itemCount: _placeSuggestions.length,
               itemBuilder: (context, index) {
                 return ListTile(
                   leading: const Icon(Icons.location_on),
                    title: Text(_placeSuggestions[index]),
                    onTap: () {
                      setState(() {
                        location = _placeSuggestions[index];
                      });

                     Navigator.pop(context);
                   },
                 );
               },
              ),
            ),

            const SizedBox(height: 16),

            ListTile(
              leading: const Icon(
               Icons.my_location,
               color: Colors.green,
             ),
             title: const Text("Use current location"),
              subtitle: const Text("Tap to fetch location"),
              onTap: () async {
                Navigator.pop(context);
                await _loadLocation();
              },
           ),

            const Divider(),

           ListTile(
             leading: const Icon(Icons.add),
             title: const Text("Add new address"),
             onTap: () {},
           ),

           ListTile(
             leading: const Icon(Icons.home_outlined),
             title: const Text("Home"),
              subtitle: const Text("Saved address"),
              onTap: () {},
            ),
         ],
       ),
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;
    final categories = ServiceCategory.all;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ----------------------------------------------------------------
          // SliverAppBar with greeting + search
          // ----------------------------------------------------------------
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.primary,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primaryDark, AppColors.primary],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Greeting row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                          GestureDetector(
                            onTap: () {
                              _showLocationBottomSheet();
                           },
                          child:Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      location,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Icon(
                                      Icons.keyboard_arrow_down,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ],
                                ),
                                SizedBox(height: 2),
                                Text(
                                  "Near Your Location",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                            // Notification bell
                            Stack(
                              children: [
                                CircleAvatar(
                                  backgroundColor:
                                      Colors.white.withValues(alpha: 0.15),
                                  radius: 22,
                                  child: const Icon(
                                    Icons.notifications_outlined,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ),
                                // Unread badge
                                Positioned(
                                  top: 2,
                                  right: 2,
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                      color: AppColors.warning,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Search bar pinned at the bottom of the app bar
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(56),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(12),
                  child: TextField(
                    controller: _searchController,
                    onSubmitted: _onSearch,
                    decoration: InputDecoration(
                      hintText: AppStrings.searchServices,
                      prefixIcon: const Icon(Icons.search_rounded,
                          color: AppColors.textSecondary),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      hintStyle: const TextStyle(
                        color: AppColors.textHint,
                        fontSize: 14,
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ),
            ),
          ),
          //-----------------------------------------------------------------
          //top hero section
          //-----------------------------------------------------------------
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: CarouselSlider(
                options: CarouselOptions(
                  height: 180,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 4),
                  viewportFraction: 1.0,
                  enlargeCenterPage: false,
                ),
                items: [
                  'assets/images/banners/ac_offer.png',
                  'assets/images/banners/plumbing_banner.png',
                  'assets/images/banners/cleaning_banner.png',
                ].map((imagePath) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.asset(
                      imagePath,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          //-----------------------------------------------------------------
          // ----------------------------------------------------------------
          // Categories section
          // ----------------------------------------------------------------
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    AppStrings.categories,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  TextButton(
                    onPressed: () {}, // Future: show all categories
                    child: const Text(
                      AppStrings.seeAll,
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: SizedBox(
              height: 110,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return SizedBox(
                    width: 75,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: CategoryCard(
                        category: categories[index],
                        onTap: () => _openCategory(categories[index]),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // ----------------------------------------------------------------
          // Popular Services section
          // ----------------------------------------------------------------
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 28, 20, 12),
              child: Text(
                AppStrings.popularServices,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),

          // Horizontal scrollable popular service chips
          SliverToBoxAdapter(
            child: SizedBox(
              height: 220,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  return GestureDetector(
                    onTap: () => _openCategory(cat),
                    child: _PopularServiceCard(category: cat),
                  );
                },
              ),
            ),
          ),
          //---------------------------------------------------------------------------------
          //---------------------------------------------------------------------------------
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _trustItem(
                    Icons.shield,
                    "Verified",
                    "Professionals",
                  ),
                  _trustItem(
                    Icons.verified,
                    "Reliable",
                    "& Trusted",
                  ),
                  _trustItem(
                    Icons.access_time,
                    "On-Time",
                    "Service",
                  ),
                  _trustItem(
                    Icons.support_agent,
                    "24/7",
                    "Support",
                  ),
                ],
              ),
            ),
          ),
          //---------------------------------------------------------------------------------

          //---------------------------------------------------------------------------------
          //FLAT 20% OFF Banner
          //---------------------------------------------------------------------------------
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F8F2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: const BoxDecoration(
                        color: Color(0xFF5AAA45),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.percent,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "FLAT 20% OFF",
                            style: TextStyle(
                              color: Color(0xFF4E9A3E),
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            "On your first booking",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Color(0xFFCFE5C7),
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Use Code: FIRST20",
                            style: TextStyle(
                              color: Color(0xFF4E9A3E),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 6),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 10,
                            color: Color(0xFF4E9A3E),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // ----------------------------------------------------------------
          // Bottom padding
          // ----------------------------------------------------------------
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

Widget _trustItem(
  IconData icon,
  String line1,
  String line2,
) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(
        icon,
        color: const Color(0xFF4CAF50),
        size: 24,
      ),
      const SizedBox(height: 2),
      Text(
        line1,
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
          height: 1.0,
        ),
      ),
      Text(
        line2,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
          height: 1.0,
        ),
      ),
    ],
  );
}

/// Horizontal "popular service" card used in the scrollable list
class _PopularServiceCard extends StatelessWidget {
  final ServiceCategory category;

  const _PopularServiceCard({required this.category});

  IconData _getIcon(String id) {
    switch (id) {
      case 'ac_repair':
        return Icons.ac_unit_rounded;
      case 'cleaning':
        return Icons.cleaning_services_rounded;
      case 'plumbing':
        return Icons.plumbing_rounded;
      case 'carpentry':
        return Icons.handyman_rounded;
      case 'electrical':
        return Icons.electrical_services_rounded;
      case 'pest_control':
        return Icons.bug_report_rounded;
      case 'appliance_repair':
        return Icons.kitchen_rounded;
      default:
        return Icons.build_rounded;
    }
  }

  //------------------------------------------------
  // Popular Services card image mapping (AC, Cleaning, Plumbing, etc.)
  //------------------------------------------------
  String _getImage(String id) {
    switch (id) {
      case 'ac_repair':
        return 'assets/images/services/ac.png';
      case 'cleaning':
        return 'assets/images/services/cleaning.png';
      case 'plumbing':
        return 'assets/images/services/plumbing.png';
      case 'carpentry':
        return 'assets/images/services/carpentry.png';
      case 'electrical':
        return 'assets/images/services/electrical.png';
      case 'pest_control':
        return 'assets/images/services/pest.png';
      case 'appliance_repair':
        return 'assets/images/services/appliance.png';
      default:
        return 'assets/images/services/ac.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bg = AppColors.categoryColors[category.colorIndex];
    final fg = AppColors.categoryIconColors[category.colorIndex];

    return Container(
      width: 170,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: fg.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              _getImage(category.id),
              height: 100,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                category.name,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: fg,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                'From ₹199',
                style: TextStyle(
                  fontSize: 11,
                  color: fg.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// All static text strings used in FixGhar
/// Centralising strings makes localisation easier later
class AppStrings {
  AppStrings._();

  // App General
  static const String appName = 'FixGhar';
  static const String appTagline = 'Home Services at Your Doorstep';

  // Auth Screen
  static const String login = 'Login';
  static const String register = 'Register';
  static const String phoneNumber = 'Phone Number';
  static const String email = 'Email Address';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String fullName = 'Full Name';
  static const String sendOtp = 'Send OTP';
  static const String verifyOtp = 'Verify OTP';
  static const String otpSent = 'OTP sent to your phone!';
  static const String enterOtp = 'Enter the 6-digit OTP';
  static const String resendOtp = 'Resend OTP';
  static const String dontHaveAccount = "Don't have an account? ";
  static const String alreadyHaveAccount = 'Already have an account? ';
  static const String signUp = 'Sign Up';
  static const String signIn = 'Sign In';
  static const String orContinueWith = 'Or continue with';
  static const String googleSignIn = 'Continue with Google';
  static const String logout = 'Logout';
  static const String logoutConfirm = 'Are you sure you want to logout?';

  // Home Screen
  static const String goodMorning = 'Good Morning';
  static const String goodAfternoon = 'Good Afternoon';
  static const String goodEvening = 'Good Evening';
  static const String whatDoYouNeed = 'What do you need help with?';
  static const String searchServices = 'Search for a service...';
  static const String categories = 'Categories';
  static const String popularServices = 'Popular Services';
  static const String seeAll = 'See All';

  // Categories
  static const String acRepair = 'AC Repair';
  static const String cleaning = 'Cleaning';
  static const String plumbing = 'Plumbing';
  static const String carpentry = 'Carpentry';
  static const String electrical = 'Electrical';
  static const String pestControl = 'Pest Control';
  static const String applianceRepair = 'Appliance Repair';

  // Service List Screen
  static const String availableProviders = 'Available Providers';
  static const String noProvidersFound = 'No providers found for this service.';
  static const String filterBy = 'Filter by';
  static const String sortBy = 'Sort by';
  static const String rating = 'Rating';
  static const String price = 'Price';
  static const String availability = 'Availability';
  static const String bookNow = 'Book Now';
  static const String viewProfile = 'View Profile';

  // Booking Screen
  static const String bookService = 'Book Service';
  static const String selectDate = 'Select Date';
  static const String selectTime = 'Select Time';
  static const String enterAddress = 'Enter Your Address';
  static const String addressHint = '123, Street Name, City';
  static const String landmark = 'Landmark (Optional)';
  static const String confirmBooking = 'Confirm Booking';
  static const String bookingConfirmed = 'Booking Confirmed!';
  static const String bookingFailed = 'Booking failed. Please try again.';
  static const String bookingDetails = 'Booking Details';
  static const String serviceType = 'Service Type';
  static const String providerName = 'Provider Name';
  static const String scheduledDate = 'Scheduled Date';
  static const String scheduledTime = 'Scheduled Time';
  static const String totalAmount = 'Total Amount';
  static const String paymentMode = 'Payment Mode';
  static const String cashOnService = 'Cash on Service';
  static const String addNotes = 'Add Notes (Optional)';
  static const String notesHint = 'Any special instructions for the provider...';

  // Booking History
  static const String myBookings = 'My Bookings';
  static const String upcomingBookings = 'Upcoming';
  static const String pastBookings = 'Past';
  static const String noUpcomingBookings = 'No upcoming bookings.';
  static const String noPastBookings = 'No past bookings.';
  static const String cancelBooking = 'Cancel Booking';
  static const String rateService = 'Rate Service';

  // Booking Status Labels
  static const String pending = 'Pending';
  static const String confirmed = 'Confirmed';
  static const String rejected = 'Rejected';
  static const String completed = 'Completed';
  static const String cancelled = 'Cancelled';

  // Profile Screen
  static const String myProfile = 'My Profile';
  static const String editProfile = 'Edit Profile';
  static const String personalInfo = 'Personal Information';
  static const String myAddresses = 'My Addresses';
  static const String helpSupport = 'Help & Support';
  static const String termsConditions = 'Terms & Conditions';
  static const String privacyPolicy = 'Privacy Policy';
  static const String appVersion = 'App Version 1.0.0';

  // Provider Panel
  static const String providerPanel = 'Provider Dashboard';
  static const String incomingRequests = 'Incoming Requests';
  static const String acceptBooking = 'Accept';
  static const String rejectBooking = 'Reject';
  static const String noIncomingBookings = 'No incoming booking requests.';

  // Errors & Validation
  static const String fieldRequired = 'This field is required';
  static const String invalidEmail = 'Please enter a valid email';
  static const String invalidPhone = 'Please enter a valid 10-digit phone number';
  static const String passwordTooShort = 'Password must be at least 6 characters';
  static const String passwordsDoNotMatch = 'Passwords do not match';
  static const String somethingWentWrong = 'Something went wrong. Please try again.';
  static const String noInternetConnection = 'No internet connection.';

  // Bottom Navigation
  static const String home = 'Home';
  static const String bookings = 'Bookings';
  static const String profile = 'Profile';
}

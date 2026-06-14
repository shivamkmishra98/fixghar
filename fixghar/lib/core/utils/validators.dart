/// Form field validator functions for FixGhar
/// Returns null if valid, or an error string if invalid
class Validators {
  Validators._();

  /// Validates that a field is not empty
  static String? required(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null
          ? '$fieldName is required'
          : 'This field is required';
    }
    return null;
  }

  /// Validates email format
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Validates a 10-digit phone number (Indian format)
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final phoneRegex = RegExp(r'^[6-9]\d{9}$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Please enter a valid 10-digit phone number';
    }
    return null;
  }

  /// Validates password length (min 6 characters)
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  /// Validates that confirm password matches the original
  static String? Function(String?) confirmPassword(String originalPassword) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return 'Please confirm your password';
      }
      if (value != originalPassword) {
        return 'Passwords do not match';
      }
      return null;
    };
  }

  /// Validates full name (at least 2 characters, letters and spaces only)
  static String? fullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    final nameRegex = RegExp(r"^[a-zA-Z\s']+$");
    if (!nameRegex.hasMatch(value.trim())) {
      return 'Name can only contain letters and spaces';
    }
    return null;
  }

  /// Validates an address (min 10 characters)
  static String? address(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Address is required';
    }
    if (value.trim().length < 10) {
      return 'Please enter a more complete address';
    }
    return null;
  }

  /// Validates a 6-digit OTP
  static String? otp(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'OTP is required';
    }
    if (value.trim().length != 6) {
      return 'OTP must be exactly 6 digits';
    }
    final digitRegex = RegExp(r'^\d{6}$');
    if (!digitRegex.hasMatch(value.trim())) {
      return 'OTP must contain only digits';
    }
    return null;
  }
}

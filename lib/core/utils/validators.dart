// Production-grade validators for every user input.
// Each validator returns null (valid) or String (error).
// All validators are STATIC — no state, no side effects.

class Validators {
  Validators._(); // prevent instantiation

  // ── Email ─────────────────────────────────────────
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email address is required';
    }
    final trimmed = value.trim().toLowerCase();
    if (trimmed.length > 254) {
      return 'Email address is too long';
    }
    // RFC 5322 compliant email regex
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.!#$%&'
      "'*+/=?^_`{|}~-]+"
      '@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}'
      r'[a-zA-Z0-9])?(?:\.[a-zA-Z0-9]'
      r'(?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$',
    );
    if (!emailRegex.hasMatch(trimmed)) {
      return 'Enter a valid email address';
    }
    // Block disposable email domains
    const blockedDomains = [
      'mailinator.com',
      'guerrillamail.com',
      'tempmail.com',
      'throwaway.email',
      '10minutemail.com',
      'yopmail.com',
    ];
    final domain = trimmed.split('@').last;
    if (blockedDomains.contains(domain)) {
      return 'Disposable email addresses are not allowed';
    }
    return null;
  }

  // ── Password ──────────────────────────────────────
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (value.length > 128) {
      return 'Password is too long (max 128 characters)';
    }
    if (!value.contains(RegExp('[A-Z]'))) {
      return 'Password must contain at least 1 uppercase letter';
    }
    if (!value.contains(RegExp('[a-z]'))) {
      return 'Password must contain at least 1 lowercase letter';
    }
    if (!value.contains(RegExp('[0-9]'))) {
      return 'Password must contain at least 1 number';
    }
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least 1 special character';
    }
    // Block common passwords
    const commonPasswords = [
      'Password1!',
      'Admin123!',
      'Welcome1!',
      'Passw0rd!',
      'Qwerty123!',
      'StyleCart1!',
    ];
    if (commonPasswords.contains(value)) {
      return 'This password is too common. Please choose a stronger password';
    }
    return null;
  }

  // ── Confirm Password ──────────────────────────────
  static String? validateConfirmPassword(
    String? value,
    String password,
  ) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  // ── Display Name ──────────────────────────────────
  static String? validateDisplayName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full name is required';
    }
    final trimmed = value.trim();
    if (trimmed.length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (trimmed.length > 60) {
      return 'Name is too long (max 60 characters)';
    }
    // Only allow letters, spaces, hyphens, apostrophes
    final nameRegex = RegExp(
      r"^[a-zA-Z\s\-'\.àáâãäåæçèéêëìíîïðñòóôõöøùúûüý"
      r'ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝ]+$',
    );
    if (!nameRegex.hasMatch(trimmed)) {
      return 'Name contains invalid characters';
    }
    // Block obvious spam names
    final lowerName = trimmed.toLowerCase();
    const spamNames = [
      'admin',
      'administrator',
      'root',
      'system',
      'support',
      'stylecart',
      'test',
      'null',
    ];
    if (spamNames.any((s) => lowerName == s)) {
      return 'This name is not allowed';
    }
    return null;
  }

  // ── Phone Number ──────────────────────────────────
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    // Remove spaces, dashes, parentheses
    final cleaned = value.replaceAll(
      RegExp(r'[\s\-\(\)]'),
      '',
    );
    // Must be 7-15 digits, optionally starting with +
    final phoneRegex = RegExp(r'^\+?[0-9]{7,15}$');
    if (!phoneRegex.hasMatch(cleaned)) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  // ── Price ─────────────────────────────────────────
  static String? validatePrice(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Price is required';
    }
    final price = double.tryParse(value.trim());
    if (price == null) {
      return 'Enter a valid price';
    }
    if (price <= 0) {
      return 'Price must be greater than 0';
    }
    if (price > 1000000) {
      return 'Price seems unrealistically high';
    }
    // Check for max 2 decimal places
    final parts = value.trim().split('.');
    if (parts.length > 1 && parts[1].length > 2) {
      return 'Price can have max 2 decimal places';
    }
    return null;
  }

  // ── Discount Percentage ───────────────────────────
  static String? validateDiscount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional
    }
    final pct = int.tryParse(value.trim());
    if (pct == null) {
      return 'Enter a valid percentage (0-90)';
    }
    if (pct < 0 || pct > 90) {
      return 'Discount must be between 0% and 90%';
    }
    return null;
  }

  // ── Stock Quantity ────────────────────────────────
  static String? validateStockQty(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // 0 is valid (out of stock)
    }
    final qty = int.tryParse(value.trim());
    if (qty == null) {
      return 'Enter a valid quantity';
    }
    if (qty < 0) {
      return 'Stock cannot be negative';
    }
    if (qty > 9999) {
      return 'Stock quantity seems too high (max 9999)';
    }
    return null;
  }

  // ── Product Name ──────────────────────────────────
  static String? validateProductName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Product name is required';
    }
    final trimmed = value.trim();
    if (trimmed.length < 3) {
      return 'Product name must be at least 3 characters';
    }
    if (trimmed.length > 120) {
      return 'Product name is too long (max 120 chars)';
    }
    // Block script injection
    if (trimmed.contains(RegExp(r'[<>{}|\\^`]'))) {
      return 'Product name contains invalid characters';
    }
    return null;
  }

  // ── Review Body ───────────────────────────────────
  static String? validateReviewBody(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Review text is required';
    }
    if (value.trim().length < 10) {
      return 'Review must be at least 10 characters';
    }
    if (value.trim().length > 1000) {
      return 'Review is too long (max 1000 characters)';
    }
    return null;
  }

  // ── Address Street ────────────────────────────────
  static String? validateStreet(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Street address is required';
    }
    if (value.trim().length < 5) {
      return 'Enter a complete street address';
    }
    if (value.trim().length > 200) {
      return 'Address is too long';
    }
    return null;
  }

  // ── Zip/Postal Code ───────────────────────────────
  static String? validateZipCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'ZIP/Postal code is required';
    }
    // Accepts US ZIP (5 or 9 digit) and international
    final zipRegex = RegExp(r'^[a-zA-Z0-9\s\-]{3,10}$');
    if (!zipRegex.hasMatch(value.trim())) {
      return 'Enter a valid ZIP/postal code';
    }
    return null;
  }

  // ── Notification Title ────────────────────────────
  static String? validateNotificationTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Notification title is required';
    }
    if (value.trim().length < 3) {
      return 'Title is too short (min 3 characters)';
    }
    if (value.trim().length > 65) {
      return 'Title is too long (max 65 characters)';
    }
    return null;
  }

  // ── Compatibility Aliases ─────────────────────────
  static String? validateName(String? value) => validateDisplayName(value);
  static String? validateBrand(String? value) => value != null && value.trim().isEmpty ? 'Brand required' : null;

  // ── Search Query ──────────────────────────────────
  static String? validateSearchQuery(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    if (value.trim().length > 100) {
      return 'Search query is too long';
    }
    // Block SQL/NoSQL injection attempts
    final dangerous = RegExp(r'[<>{}\[\]\\|^`~]');
    if (dangerous.hasMatch(value)) {
      return 'Search contains invalid characters';
    }
    return null;
  }

  // ── Password Strength (0-4) ───────────────────────
  static int passwordStrength(String password) {
    if (password.isEmpty) return 0;
    var score = 0;
    if (password.length >= 8) score++;
    if (password.contains(RegExp('[A-Z]'))) score++;
    if (password.contains(RegExp('[0-9]'))) score++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score++;
    return score;
  }
}

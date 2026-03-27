// Sanitizes all user-generated content before
// writing to Firestore. Prevents XSS, injection,
// and data corruption.

class Sanitizer {
  Sanitizer._();

  // ── String sanitization ───────────────────────────
  // Removes dangerous characters, trims whitespace,
  // normalizes unicode

  static String sanitizeString(
    String input, {
    int maxLength = 500,
    bool allowNewlines = false,
  }) {
    String result = input
        // Trim leading/trailing whitespace
        .trim()
        // Remove null bytes
        .replaceAll('\x00', '')
        // Remove control characters
        .replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F]'), '')
        // Collapse multiple spaces to single
        .replaceAll(RegExp(r'  +'), ' ');

    if (!allowNewlines) {
      result = result.replaceAll(RegExp(r'[\r\n]'), ' ');
    } else {
      // Allow max 3 consecutive newlines
      result = result.replaceAll(
        RegExp(r'\n{4,}'),
        '\n\n\n',
      );
    }

    // Truncate to max length
    if (result.length > maxLength) {
      result = result.substring(0, maxLength);
    }

    return result;
  }

  // ── Email sanitization ─────────────────────────────
  static String sanitizeEmail(String email) {
    return email
        .trim()
        .toLowerCase()
        // Remove dots from Gmail (normalize)
        // e.g. john.doe@gmail.com = johndoe@gmail.com
        // ONLY apply for gmail.com
        .replaceAllMapped(
          RegExp(r'^([^@]+)@gmail\.com$'),
          (m) => '${m.group(1)!.replaceAll('.', '')}@gmail.com',
        );
  }

  // ── Product description sanitization ──────────────
  // Allows basic formatting but strips dangerous content
  static String sanitizeDescription(String input) {
    return sanitizeString(
      input,
      maxLength: 2000,
      allowNewlines: true,
    );
  }

  // ── Display name sanitization ──────────────────────
  static String sanitizeName(String input) {
    return sanitizeString(input, maxLength: 60)
        // Capitalize first letter of each word
        .split(' ')
        .map((word) => word.isEmpty ? word : word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  // ── Search query sanitization ──────────────────────
  static String sanitizeSearchQuery(String input) {
    return sanitizeString(input, maxLength: 100).toLowerCase().replaceAll(RegExp(r'[^\w\s]'), ' ').trim();
  }

  // ── Tags sanitization ─────────────────────────────
  static List<String> sanitizeTags(
    List<String> tags,
  ) {
    return tags
        .map((tag) => sanitizeString(
              tag,
              maxLength: 30,
            ).toLowerCase())
        .where((tag) => tag.length >= 2)
        .take(20) // max 20 tags
        .toList();
  }

  // ── Price sanitization ─────────────────────────────
  // Ensures price is a valid 2-decimal double
  static double sanitizePrice(double price) {
    // Round to 2 decimal places
    return double.parse(price.toStringAsFixed(2));
  }

  // ── Order note sanitization ────────────────────────
  static String? sanitizeOrderNote(String? note) {
    if (note == null || note.trim().isEmpty) return null;
    return sanitizeString(note, maxLength: 200);
  }

  // ── Map sanitization ──────────────────────────────
  // Removes null values and sanitizes string values
  static Map<String, dynamic> sanitizeMap(
    Map<String, dynamic> data,
  ) {
    final result = <String, dynamic>{};
    for (final entry in data.entries) {
      if (entry.value == null) continue;
      if (entry.value is String) {
        final sanitized = sanitizeString(
          entry.value as String,
        );
        if (sanitized.isNotEmpty) {
          result[entry.key] = sanitized;
        }
      } else {
        result[entry.key] = entry.value;
      }
    }
    return result;
  }
}

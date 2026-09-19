/// Sanitize user-input notes before rendering or embedding.
/// Strips any HTML tags, control characters, and trims length.
String sanitizeNote(String raw) {
  // Remove HTML tags
  final noHtml = raw.replaceAll(RegExp(r'<[^>]*>'), '');
  // Remove control characters
  final noControl = noHtml.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '');
  // Trim whitespace and cap length at 200 chars
  return noControl.trim().length > 200
      ? '${noControl.trim().substring(0, 200)}...'
      : noControl.trim();
}

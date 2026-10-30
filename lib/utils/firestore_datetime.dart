// Converts a Firestore value into a [DateTime].
//
// Handles Firestore `Timestamp` (via its `toDate()`), `DateTime`, and ISO-8601
// strings (useful for mock/seed JSON), so models don't need to import
// cloud_firestore.
DateTime? parseDateTime(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  try {
    return (value as dynamic).toDate() as DateTime;
  } catch (_) {
    return null;
  }
}

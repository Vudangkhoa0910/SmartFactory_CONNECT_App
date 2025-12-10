/// Utility functions for Set operations
/// Used for comparing filter state changes

/// Check if two string sets are equal
bool setEquals(Set<String> a, Set<String> b) {
  if (a.length != b.length) return false;
  for (final item in a) {
    if (!b.contains(item)) return false;
  }
  return true;
}

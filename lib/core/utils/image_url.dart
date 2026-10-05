import '../constants/api_constants.dart';

/// Backend rasmlarni "/uploads/..." ko'rinishida (domensiz, ba'zan bo'sh joy bilan)
/// qaytaradi. Shu funksiya ularni to'liq URL ga aylantiradi.
String? fullImageUrl(String? path) {
  if (path == null || path.isEmpty) return null;
  if (path.startsWith('http')) return Uri.encodeFull(path);
  final normalized = path.startsWith('/') ? path : '/$path';
  return Uri.encodeFull('${ApiConstants.baseUrl}$normalized');
}

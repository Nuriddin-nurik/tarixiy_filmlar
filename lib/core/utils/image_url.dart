import '../constants/api_constants.dart';

String? fullImageUrl(String? path) {
  if (path == null || path.isEmpty) return null;
  if (path.startsWith('http')) return Uri.encodeFull(path);
  final normalized = path.startsWith('/') ? path : '/$path';
  return Uri.encodeFull('${ApiConstants.baseUrl}$normalized');
}

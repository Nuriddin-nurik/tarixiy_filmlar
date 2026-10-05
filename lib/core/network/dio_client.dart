import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../routes/app_routes.dart';
import '../constants/api_constants.dart';
import '../utils/device_id.dart';
import '../../core/widgets/app_widgets.dart';

class DioClient {
  late Dio dio;

  /// Bir vaqtda bir nechta so'rov 401 olsa ham, refresh faqat bir marta bajariladi.
  static Future<bool>? _refreshing;

  DioClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Tokenni qo'shish
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('access_token');
          final deviceId = await DeviceId.get();

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          options.headers['X-Device-Id'] = deviceId;

          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          final status = e.response?.statusCode;
          final opts = e.requestOptions;
          final isAuthCall = opts.path.startsWith('/auth/');

          // Access token 30 daqiqada eskiradi (backend: jwt.access-token-expiry-ms).
          // Shunda refresh token bilan yangisini olib, so'rovni qayta yuboramiz.
          if (status == 401 && !isAuthCall && opts.extra['retried'] != true) {
            final prefs = await SharedPreferences.getInstance();
            final hadToken = (prefs.getString('access_token') ?? '').isNotEmpty;
            if (!hadToken) return handler.next(e);

            if (await _refreshTokens()) {
              try {
                opts.extra['retried'] = true;
                // onRequest yangi tokenni o'zi qo'yadi.
                final response = await dio.fetch(opts);
                return handler.resolve(response);
              } on DioException catch (retryError) {
                return handler.next(retryError);
              }
            }

            // Refresh ham o'tmadi (30 kun o'tgan yoki boshqa qurilmadan kirilgan).
            await _logout();
          }
          return handler.next(e);
        },
      ),
    );
  }

  static Future<bool> _refreshTokens() {
    return _refreshing ??= _doRefresh().whenComplete(() => _refreshing = null);
  }

  static Future<bool> _doRefresh() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refresh_token');
    if (refreshToken == null || refreshToken.isEmpty) return false;
    try {
      // Interceptor'siz alohida Dio — aks holda refresh xatosi yana shu yerga tushadi.
      final res = await Dio(BaseOptions(baseUrl: ApiConstants.baseUrl)).post(
        ApiConstants.refresh,
        data: {'refreshToken': refreshToken},
        options: Options(headers: {'X-Device-Id': await DeviceId.get()}),
      );
      final token = res.data['token'] as String?;
      if (token == null || token.isEmpty) return false;
      await prefs.setString('access_token', token);
      final newRefresh = res.data['refreshToken'] as String?;
      if (newRefresh != null && newRefresh.isNotEmpty) {
        await prefs.setString('refresh_token', newRefresh);
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    if ((prefs.getString('access_token') ?? '').isEmpty) return; // allaqachon chiqarilgan
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    if (Get.currentRoute != Routes.AUTH) {
      Get.offAllNamed(Routes.AUTH);
      appSnack('Sessiya tugadi'.tr, 'Iltimos, qaytadan kiring'.tr);
    }
  }
}

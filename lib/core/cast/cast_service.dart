import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_chrome_cast/flutter_chrome_cast.dart';
import 'package:get/get.dart';

class CastService extends GetxService {
  static CastService get to => Get.find<CastService>();

  final available = false.obs;
  final connected = false.obs;
  final deviceName = ''.obs;
  final devices = <GoogleCastDevice>[].obs;

  StreamSubscription<GoogleCastSession?>? _sessionSub;
  StreamSubscription<List<GoogleCastDevice>>? _devicesSub;

  Future<CastService> init() async {
    if (!GetPlatform.isAndroid && !GetPlatform.isIOS) return this;
    try {
      if (kReleaseMode) GoogleCastLogger.level = CastLogLevel.none;
      const appId = GoogleCastDiscoveryCriteria.kDefaultApplicationId;
      final GoogleCastOptions options = GetPlatform.isIOS
          ? IOSGoogleCastOptions(
              GoogleCastDiscoveryCriteriaInitialize.initWithApplicationID(appId),
              stopCastingOnAppTerminated: true,
            )
          : GoogleCastOptionsAndroid(appId: appId, stopCastingOnAppTerminated: true);
      await GoogleCastContext.instance.setSharedInstanceWithOptions(options);
      _sessionSub = GoogleCastSessionManager.instance.currentSessionStream.listen(_onSession);
      _devicesSub = GoogleCastDiscoveryManager.instance.devicesStream.listen(devices.assignAll);
      available.value = true;
    } catch (_) {
      available.value = false;
    }
    return this;
  }

  void _onSession(GoogleCastSession? session) {
    final isConnected = session?.connectionState == GoogleCastConnectState.connected;
    deviceName.value = isConnected ? (session?.device?.friendlyName ?? '') : '';
    connected.value = isConnected;
  }

  Future<void> startDiscovery() async {
    if (!available.value) return;
    try {
      await GoogleCastDiscoveryManager.instance.startDiscovery(activeScan: true);
    } catch (_) {
    }
  }

  Future<void> stopDiscovery() async {
    if (!available.value) return;
    try {
      await GoogleCastDiscoveryManager.instance.stopDiscovery();
    } catch (_) {
    }
  }

  Future<bool> connect(GoogleCastDevice device) async {
    try {
      return await GoogleCastSessionManager.instance.startSessionWithDevice(device);
    } catch (_) {
      return false;
    }
  }

  Future<void> disconnect() async {
    try {
      await GoogleCastSessionManager.instance.endSessionAndStopCasting();
    } catch (_) {
    }
  }

  @override
  void onClose() {
    _sessionSub?.cancel();
    _devicesSub?.cancel();
    super.onClose();
  }
}

package com.example.tarixiy_filimlar

import android.os.Bundle
import android.os.StatFs
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Kontentni himoyalash: skrinshot va ekran yozuvi qora chiqadi,
        // "So'nggi ilovalar" ro'yxatida ham ilova ko'rinishi yashiriladi.
        window.setFlags(
            WindowManager.LayoutParams.FLAG_SECURE,
            WindowManager.LayoutParams.FLAG_SECURE
        )
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Yuklashdan oldin telefonda bo'sh joy yetarliligini tekshirish uchun.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "tarixiy/storage")
            .setMethodCallHandler { call, result ->
                if (call.method == "freeBytes") {
                    result.success(StatFs(filesDir.absolutePath).availableBytes)
                } else {
                    result.notImplemented()
                }
            }
    }
}

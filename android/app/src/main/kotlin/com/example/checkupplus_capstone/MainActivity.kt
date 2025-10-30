package com.example.checkupplus_capstone

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "secure_api_key"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getApiKey") {
                try {
                    val apiKey = getApiKey()
                    result.success(apiKey)
                } catch (e: Exception) {
                    result.error("UNAVAILABLE", "API key not available", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun getApiKey(): String {
        return BuildConfig.MAPS_API_KEY
    }
}

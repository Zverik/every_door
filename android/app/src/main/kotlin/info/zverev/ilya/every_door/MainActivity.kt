package info.zverev.ilya.every_door

import android.content.Context
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SECURE_STORAGE_RECOVERY_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "clearLegacySecureStorage" -> {
                        try {
                            val cleared = clearLegacySecureStorage()
                            result.success(cleared)
                        } catch (e: Exception) {
                            result.error(
                                "secure_storage_recovery_failed",
                                e.message,
                                null
                            )
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun clearLegacySecureStorage(): Boolean {
        var cleared = true
        for (name in LEGACY_SECURE_STORAGE_PREFS) {
            cleared = getSharedPreferences(name, Context.MODE_PRIVATE)
                .edit()
                .clear()
                .commit() && cleared
        }
        return cleared
    }

    companion object {
        private const val SECURE_STORAGE_RECOVERY_CHANNEL =
            "info.zverev.ilya.every_door/secure_storage_recovery"

        private val LEGACY_SECURE_STORAGE_PREFS = listOf(
            "FlutterSecureStorage",
            "FlutterSecureKeyStorage",
            "FlutterSecureStorageConfiguration",
            "FlutterSecureStorageConfiguration:FlutterSecureStorage"
        )
    }
}

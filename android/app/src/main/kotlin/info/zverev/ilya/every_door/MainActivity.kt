package info.zverev.ilya.every_door

import androidx.annotation.NonNull
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private var lastIntentUrlPassed = ""
    private val CHANNEL = "info.zverev.ilya.every_door/location"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            if (call.method == "getLocationFromIntent") {
                val intentLocationUrl = intent.data?.toString() ?: ""
                if (intentLocationUrl.startsWith("geo:") && intentLocationUrl != lastIntentUrlPassed) {
                    result.success(intentLocationUrl)
                    lastIntentUrlPassed = intentLocationUrl
                } else {
                    result.error("UNAVAILABLE", "Location url from Intent not available", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}

package space.mai.mai_stay_in_touch

import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.Intent
import android.net.Uri
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Wähl-App und WhatsApp öffnen (Kanal `mai/launch`). Gewählt wird in der
 * Wähl-App — die App braucht keine Telefon-Berechtigung.
 */
class LauncherChannel(private val activity: Activity) : MethodChannel.MethodCallHandler {
    companion object {
        const val NAME = "mai/launch"
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val number = call.arguments as? String
        if (number.isNullOrEmpty()) {
            result.success(false)
            return
        }
        when (call.method) {
            "dial" -> result.success(start(Intent(Intent.ACTION_DIAL, Uri.parse("tel:" + Uri.encode(number)))))
            // Nur Ziffern (international ohne „+“), siehe lib/domain/phone.dart.
            "whatsapp" -> result.success(
                start(Intent(Intent.ACTION_VIEW, Uri.parse("https://wa.me/" + number.filter { it.isDigit() }))),
            )
            else -> result.notImplemented()
        }
    }

    private fun start(intent: Intent): Boolean = try {
        activity.startActivity(intent)
        true
    } catch (_: ActivityNotFoundException) {
        false
    }
}

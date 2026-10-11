package space.mai.mai_stay_in_touch

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import space.mai.mai_stay_in_touch.widgets.TodayWidget
import space.mai.mai_stay_in_touch.widgets.WearSync
import space.mai.mai_stay_in_touch.widgets.WidgetStore
import java.util.TimeZone

class MainActivity : FlutterActivity() {
    private var widgetChannel: MethodChannel? = null
    private var contacts: ContactsChannel? = null
    private var initialLinkTaken = false

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val messenger = flutterEngine.dartExecutor.binaryMessenger
        MethodChannel(messenger, DatabaseKeyChannel.NAME)
            .setMethodCallHandler(DatabaseKeyChannel(applicationContext))
        // IANA-Zeitzone des Geräts (z. B. „Europe/Berlin“) für Benachrichtigungen.
        MethodChannel(messenger, "mai/device").setMethodCallHandler { call, result ->
            when (call.method) {
                "timeZone" -> result.success(TimeZone.getDefault().id)
                else -> result.notImplemented()
            }
        }
        MethodChannel(messenger, LauncherChannel.NAME).setMethodCallHandler(LauncherChannel(this))
        contacts = ContactsChannel(this).also {
            MethodChannel(messenger, ContactsChannel.NAME).setMethodCallHandler(it)
        }
        // Homescreen-Widget: Stand aus der App, Link beim Öffnen über das Widget.
        widgetChannel = MethodChannel(messenger, "mai/widgets").apply {
            setMethodCallHandler { call, result ->
                when (call.method) {
                    "update" -> {
                        val json = call.arguments as? String
                        if (json != null) {
                            WidgetStore.saveSnapshot(applicationContext, json)
                            TodayWidget.refreshAll(applicationContext)
                            // Wear-OS-Kachel/-Komplikation (nur mit Uhr-App).
                            WearSync.publish(applicationContext, WidgetStore.snapshot(applicationContext))
                        }
                        result.success(null)
                    }
                    "initialLink" -> {
                        val link = if (initialLinkTaken) null else widgetLink(intent)
                        initialLinkTaken = true
                        result.success(link)
                    }
                    else -> result.notImplemented()
                }
            }
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == ContactsChannel.REQUEST_CODE) contacts?.onPermissionResult(grantResults)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        widgetLink(intent)?.let { widgetChannel?.invokeMethod("open", it) }
    }

    private fun widgetLink(intent: Intent?): String? =
        intent?.data?.takeIf { it.scheme == TodayWidget.SCHEME }?.toString()
}

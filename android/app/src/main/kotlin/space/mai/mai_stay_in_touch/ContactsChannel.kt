package space.mai.mai_stay_in_touch

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.provider.ContactsContract
import android.provider.Settings
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Executors

/**
 * Adressbuch (Kanal `mai/contacts`). Gelesen werden nur Name und
 * Telefonnummern, und nur auf Wunsch des Nutzers (Import). Die App schreibt
 * nie ins Adressbuch.
 */
class ContactsChannel(private val activity: Activity) : MethodChannel.MethodCallHandler {
    companion object {
        const val NAME = "mai/contacts"
        const val REQUEST_CODE = 4711
        private const val PREFS = "mai_stay_in_touch_contacts"
        private const val KEY_ASKED = "asked"
    }

    private val worker = Executors.newSingleThreadExecutor()
    private var pending: MethodChannel.Result? = null

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "requestPermission" -> requestPermission(result)
            "list" -> list(result)
            "openSettings" -> {
                val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
                    .setData(Uri.fromParts("package", activity.packageName, null))
                    .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                activity.startActivity(intent)
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    private fun granted() = activity.checkSelfPermission(Manifest.permission.READ_CONTACTS) ==
        PackageManager.PERMISSION_GRANTED

    private fun requestPermission(result: MethodChannel.Result) {
        if (granted()) {
            result.success("granted")
            return
        }
        val prefs = activity.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        // Nach zweimaliger Ablehnung zeigt Android keinen Dialog mehr.
        if (prefs.getBoolean(KEY_ASKED, false) &&
            !activity.shouldShowRequestPermissionRationale(Manifest.permission.READ_CONTACTS)
        ) {
            result.success("permanentlyDenied")
            return
        }
        pending?.success("denied")
        pending = result
        prefs.edit().putBoolean(KEY_ASKED, true).apply()
        activity.requestPermissions(arrayOf(Manifest.permission.READ_CONTACTS), REQUEST_CODE)
    }

    /** Aus `MainActivity.onRequestPermissionsResult`. */
    fun onPermissionResult(grantResults: IntArray) {
        val result = pending ?: return
        pending = null
        result.success(
            if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                "granted"
            } else {
                "denied"
            },
        )
    }

    private fun list(result: MethodChannel.Result) {
        if (!granted()) {
            result.error("PERMISSION", "READ_CONTACTS not granted", null)
            return
        }
        worker.execute {
            try {
                val contacts = query()
                activity.runOnUiThread { result.success(contacts) }
            } catch (e: Exception) {
                activity.runOnUiThread { result.error("READ", e.message, null) }
            }
        }
    }

    /**
     * Alle Kontakte mit Telefonnummer: `[{id, name, phones}]`. ID ist der
     * Lookup-Schlüssel (bleibt bei Synchronisierung stabil). Hauptnummer
     * und Mobilnummern zuerst.
     */
    private fun query(): List<Map<String, Any>> {
        class Row(val name: String, val phones: MutableList<Pair<Int, String>>)
        val byKey = LinkedHashMap<String, Row>()
        val projection = arrayOf(
            ContactsContract.CommonDataKinds.Phone.LOOKUP_KEY,
            ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME_PRIMARY,
            ContactsContract.CommonDataKinds.Phone.NUMBER,
            ContactsContract.CommonDataKinds.Phone.TYPE,
            ContactsContract.CommonDataKinds.Phone.IS_SUPER_PRIMARY,
        )
        activity.contentResolver.query(
            ContactsContract.CommonDataKinds.Phone.CONTENT_URI,
            projection,
            null,
            null,
            null,
        )?.use { c ->
            while (c.moveToNext()) {
                val key = c.getString(0) ?: continue
                val name = c.getString(1)?.trim().orEmpty()
                val number = c.getString(2)?.trim().orEmpty()
                if (name.isEmpty() || number.isEmpty()) continue
                val rank = when {
                    c.getInt(4) != 0 -> 0
                    c.getInt(3) == ContactsContract.CommonDataKinds.Phone.TYPE_MOBILE -> 1
                    else -> 2
                }
                val row = byKey.getOrPut(key) { Row(name, ArrayList()) }
                val digits = number.filter { it.isDigit() }
                if (row.phones.none { it.second.filter { ch -> ch.isDigit() } == digits }) {
                    row.phones.add(rank to number)
                }
            }
        }
        return byKey.map { (key, row) ->
            mapOf(
                "id" to key,
                "name" to row.name,
                "phones" to row.phones.sortedBy { it.first }.map { it.second },
            )
        }
    }
}

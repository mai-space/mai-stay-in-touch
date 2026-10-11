package space.mai.mai_stay_in_touch.widgets

import android.content.Context
import org.json.JSONObject

/**
 * Speicher des Homescreen-Widgets (nur lokal, SharedPreferences): letzter
 * Stand aus der App (JSON, siehe `lib/home_widgets/widget_snapshot.dart`).
 */
object WidgetStore {
    private const val PREFS = "mai_stay_in_touch_widgets"
    private const val KEY_SNAPSHOT = "snapshot"

    private fun prefs(context: Context) =
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)

    fun saveSnapshot(context: Context, json: String) {
        prefs(context).edit().putString(KEY_SNAPSHOT, json).apply()
    }

    /** Letzter Stand der App oder `null` (App noch nie geöffnet/eingerichtet). */
    fun snapshot(context: Context): JSONObject? {
        val raw = prefs(context).getString(KEY_SNAPSHOT, null) ?: return null
        return try {
            JSONObject(raw)
        } catch (_: Exception) {
            null
        }
    }

    /**
     * Setzt den Status des Vorschlags für [day]/[id] im gespeicherten Stand
     * (z. B. „Heute nicht“ im Widget, bevor die App es übernimmt). Stammt der
     * Vorschlag aus der Vorschau (Tag nach dem letzten Öffnen), wird er zum
     * heutigen.
     */
    fun markStatus(context: Context, day: String, id: String, status: String) {
        val snap = snapshot(context) ?: return
        val today = snap.optJSONObject("today")
        if (today != null && today.optString("day") == day && today.optString("id") == id) {
            today.put("status", status)
        } else {
            val upcoming = snap.optJSONArray("upcoming") ?: return
            for (i in 0 until upcoming.length()) {
                val e = upcoming.optJSONObject(i) ?: continue
                if (e.optString("day") == day && e.optString("id") == id) {
                    snap.put("today", JSONObject(e.toString()).put("status", status))
                    break
                }
            }
        }
        saveSnapshot(context, snap.toString())
    }
}

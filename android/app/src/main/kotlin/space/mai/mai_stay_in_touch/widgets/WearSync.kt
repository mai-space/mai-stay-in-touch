package space.mai.mai_stay_in_touch.widgets

import android.content.Context
import com.google.android.gms.wearable.CapabilityClient
import com.google.android.gms.wearable.MessageEvent
import com.google.android.gms.wearable.PutDataMapRequest
import com.google.android.gms.wearable.Wearable
import com.google.android.gms.wearable.WearableListenerService
import org.json.JSONObject

/**
 * Stand für die Uhr (Wear-OS-Kachel und -Komplikation), abgeleitet aus dem
 * Widget-Stand. Geht nur an gekoppelte Uhren, auf denen die Ruf-durch-Uhr-App
 * installiert ist (Fähigkeit [CAPABILITY_WATCH]) — ohne Uhr verlässt nichts
 * das Telefon. Übertragung über die Wearable-Datenschicht der Google-Play-
 * Dienste, keine eigene Netzwerkverbindung. Keine Telefonnummern.
 *
 * Format (`v` bleibt 1, nur erweitern; die Uhr ignoriert Unbekanntes):
 * `{"v":1,"today":{"day":"2026-10-12","name":…,"detail":…,"status":"open"}|null,
 *   "upcoming":[{"day":…,"name":…}]}`
 */
object WearSync {
    const val PATH_NEXT = "/mai-stay-in-touch/next"
    const val PATH_REQUEST = "/mai-stay-in-touch/request"
    const val KEY_JSON = "json"
    private const val CAPABILITY_WATCH = "mai_stay_in_touch_watch"

    private const val PREFS = "mai_stay_in_touch_wear"
    private const val KEY_SENT = "sent"

    /**
     * Schickt den aktuellen Stand an die Uhr, falls er sich geändert hat
     * ([force]: auch unverändert, z. B. auf Anfrage einer neu eingerichteten
     * Uhr). Fehler (keine Play-Dienste, keine Uhr) werden ignoriert.
     */
    fun publish(context: Context, snapshot: JSONObject?, force: Boolean = false) {
        val app = context.applicationContext
        val payload = payload(snapshot ?: return).toString()
        val prefs = app.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        if (!force && prefs.getString(KEY_SENT, null) == payload) return
        try {
            Wearable.getCapabilityClient(app)
                .getCapability(CAPABILITY_WATCH, CapabilityClient.FILTER_ALL)
                .addOnSuccessListener { info ->
                    if (info.nodes.isEmpty()) return@addOnSuccessListener
                    val request = PutDataMapRequest.create(PATH_NEXT).apply {
                        dataMap.putString(KEY_JSON, payload)
                    }.asPutDataRequest().setUrgent()
                    Wearable.getDataClient(app).putDataItem(request)
                        .addOnSuccessListener {
                            prefs.edit().putString(KEY_SENT, payload).apply()
                        }
                }
        } catch (_: Exception) {
            // Uhr ist Beiwerk — Telefon-Widget und App laufen weiter.
        }
    }

    /** Nur das, was Kachel und Komplikation zeigen — keine Nummern, keine IDs. */
    fun payload(snap: JSONObject): JSONObject {
        val out = JSONObject()
        out.put("v", 1)
        val today = snap.optJSONObject("today")
        out.put(
            "today",
            if (today == null) {
                JSONObject.NULL
            } else {
                JSONObject()
                    .put("day", today.optString("day"))
                    .put("name", today.optString("name"))
                    .put("detail", today.optString("detail"))
                    .put("status", today.optString("status", "open"))
            },
        )
        val upcoming = org.json.JSONArray()
        val list = snap.optJSONArray("upcoming")
        if (list != null) {
            for (i in 0 until list.length()) {
                val e = list.optJSONObject(i) ?: continue
                upcoming.put(
                    JSONObject()
                        .put("day", e.optString("day"))
                        .put("name", e.optString("name"))
                        .put("detail", e.optString("detail")),
                )
            }
        }
        out.put("upcoming", upcoming)
        return out
    }
}

/**
 * Anfrage einer Uhr (z. B. direkt nach der Installation der Uhr-App): letzten
 * gespeicherten Stand schicken — funktioniert auch, wenn die App nicht läuft.
 */
class WearRequestListener : WearableListenerService() {
    override fun onMessageReceived(event: MessageEvent) {
        if (event.path == WearSync.PATH_REQUEST) {
            WearSync.publish(this, WidgetStore.snapshot(this), force = true)
        }
    }
}

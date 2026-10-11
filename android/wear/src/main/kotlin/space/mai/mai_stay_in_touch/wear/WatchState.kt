package space.mai.mai_stay_in_touch.wear

import android.content.ComponentName
import android.content.Context
import android.net.Uri
import androidx.wear.tiles.TileService
import androidx.wear.watchface.complications.datasource.ComplicationDataSourceUpdateRequester
import com.google.android.gms.wearable.CapabilityClient
import com.google.android.gms.wearable.DataItem
import com.google.android.gms.wearable.DataMapItem
import com.google.android.gms.wearable.Wearable
import org.json.JSONObject
import java.time.LocalDate
import java.time.format.TextStyle
import java.util.Locale

/** Ein Vorschlag vom Telefon. */
class WatchPick(
    val day: LocalDate,
    val name: String,
    val detail: String,
    val status: String,
) {
    val open get() = status == "open"
    val declined get() = status == "declined"
}

/**
 * Stand vom Telefon (siehe `WearSync` in der Telefon-App), nur lokal in
 * SharedPreferences. Format `v` 1; Unbekanntes wird ignoriert.
 */
class WatchState(
    private val stored: WatchPick?,
    private val upcoming: List<WatchPick>,
) {
    /**
     * Heutiger Vorschlag — selbst bestimmt, damit es nach Mitternacht ohne
     * Telefon stimmt: Ist der gespeicherte Tag vorbei, gilt die Vorschau.
     */
    fun today(now: LocalDate = LocalDate.now()): WatchPick? =
        stored?.takeIf { it.day == now } ?: upcoming.firstOrNull { it.day == now }

    fun next(now: LocalDate = LocalDate.now()): List<WatchPick> = upcoming.filter { it.day.isAfter(now) }

    /** Noch niemand eingeordnet. */
    val empty get() = stored == null && upcoming.isEmpty()

    fun status(context: Context, pick: WatchPick): String? = when {
        pick.open -> null
        pick.declined -> context.getString(R.string.watch_declined)
        else -> context.getString(R.string.watch_done)
    }

    companion object {
        fun dayLabel(context: Context, day: LocalDate, now: LocalDate = LocalDate.now()): String = when (day) {
            now -> context.getString(R.string.watch_today)
            now.plusDays(1) -> context.getString(R.string.watch_tomorrow)
            else -> day.dayOfWeek.getDisplayName(TextStyle.SHORT, Locale.getDefault())
        }

        private fun pick(j: JSONObject?): WatchPick? {
            if (j == null) return null
            val day = try {
                LocalDate.parse(j.optString("day"))
            } catch (_: Exception) {
                return null
            }
            val name = j.optString("name").takeIf { it.isNotEmpty() } ?: return null
            return WatchPick(day, name, j.optString("detail"), j.optString("status", "open").ifEmpty { "open" })
        }

        fun parse(raw: String?): WatchState? {
            if (raw == null) return null
            return try {
                val j = JSONObject(raw)
                val list = j.optJSONArray("upcoming")
                val upcoming = ArrayList<WatchPick>()
                if (list != null) {
                    for (i in 0 until list.length()) pick(list.optJSONObject(i))?.let { upcoming.add(it) }
                }
                WatchState(pick(j.optJSONObject("today")), upcoming)
            } catch (_: Exception) {
                null
            }
        }
    }
}

object WatchStore {
    const val PATH_NEXT = "/mai-stay-in-touch/next"
    const val PATH_REQUEST = "/mai-stay-in-touch/request"
    private const val KEY_JSON = "json"
    private const val CAPABILITY_PHONE = "mai_stay_in_touch_phone"

    private const val PREFS = "mai_stay_in_touch_watch"
    private const val KEY_STATE = "state"
    private const val KEY_ASKED = "asked"

    /** Höchstens so oft beim Telefon nachfragen (ms). */
    private const val ASK_INTERVAL = 15 * 60 * 1000L

    private fun prefs(context: Context) =
        context.applicationContext.getSharedPreferences(PREFS, Context.MODE_PRIVATE)

    fun state(context: Context): WatchState? = WatchState.parse(prefs(context).getString(KEY_STATE, null))

    /** Neuer Stand vom Telefon (`null`: gelöscht). Zeichnet Kachel und Komplikation neu. */
    fun save(context: Context, json: String?) {
        prefs(context).edit().apply {
            if (json == null) remove(KEY_STATE) else putString(KEY_STATE, json)
        }.apply()
        refreshAll(context)
    }

    fun refreshAll(context: Context) {
        val app = context.applicationContext
        try {
            TileService.getUpdater(app).requestUpdate(TodayTileService::class.java)
        } catch (_: Exception) {
        }
        try {
            ComplicationDataSourceUpdateRequester
                .create(app, ComponentName(app, TodayComplicationService::class.java))
                .requestUpdateAll()
        } catch (_: Exception) {
        }
    }

    /**
     * Noch kein Stand (z. B. Uhr-App frisch installiert): zuerst die
     * vorhandenen Daten der Datenschicht lesen, sonst das Telefon fragen.
     */
    fun ensure(context: Context) {
        if (state(context) != null) return
        val app = context.applicationContext
        val prefs = prefs(app)
        val now = System.currentTimeMillis()
        if (now - prefs.getLong(KEY_ASKED, 0L) < ASK_INTERVAL) return
        prefs.edit().putLong(KEY_ASKED, now).apply()
        try {
            Wearable.getDataClient(app)
                .getDataItems(Uri.parse("wear://*$PATH_NEXT"))
                .addOnSuccessListener { items ->
                    var json: String? = null
                    for (item in items) {
                        json = jsonOf(item) ?: json
                    }
                    items.release()
                    if (json != null) save(app, json) else askPhone(app)
                }
                .addOnFailureListener { askPhone(app) }
        } catch (_: Exception) {
        }
    }

    private fun askPhone(context: Context) {
        try {
            Wearable.getCapabilityClient(context)
                .getCapability(CAPABILITY_PHONE, CapabilityClient.FILTER_REACHABLE)
                .addOnSuccessListener { info ->
                    val messages = Wearable.getMessageClient(context)
                    for (node in info.nodes) messages.sendMessage(node.id, PATH_REQUEST, ByteArray(0))
                }
        } catch (_: Exception) {
        }
    }

    fun jsonOf(item: DataItem): String? =
        DataMapItem.fromDataItem(item).dataMap.getString(KEY_JSON)
}

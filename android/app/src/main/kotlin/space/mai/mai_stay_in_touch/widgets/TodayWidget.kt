package space.mai.mai_stay_in_touch.widgets

import android.app.AlarmManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.util.SizeF
import android.view.View
import android.widget.RemoteViews
import org.json.JSONObject
import space.mai.mai_stay_in_touch.MainActivity
import space.mai.mai_stay_in_touch.R
import java.io.File
import java.time.LocalDate
import java.time.ZoneId

/**
 * Widget „Heute anrufen“. Größe frei wählbar; ab Android 12 liefert das
 * Widget mehrere Layouts, der Launcher wählt beim Skalieren selbst das
 * passende. Darunter wird bei jeder Größenänderung neu gezeichnet.
 */
class TodayWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray) {
        for (id in ids) TodayWidget.draw(context, manager, id)
        TodayWidget.scheduleMidnight(context)
    }

    override fun onAppWidgetOptionsChanged(
        context: Context,
        manager: AppWidgetManager,
        id: Int,
        newOptions: Bundle,
    ) {
        TodayWidget.draw(context, manager, id)
    }

    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            TodayWidget.ACTION_REFRESH -> TodayWidget.refreshAll(context)
            TodayWidget.ACTION_LATER -> TodayWidget.later(context, intent.data)
            else -> super.onReceive(context, intent)
        }
    }
}

/** Ein Vorschlag aus dem Stand der App. */
private class Entry(
    val day: LocalDate,
    val id: String,
    val name: String,
    val detail: String,
    val phone: Boolean,
    val whatsapp: Boolean,
    val status: String,
)

/** Anzeigedaten, aus dem Stand der App aufbereitet. */
private class Model(
    val title: String,
    val today: Entry?,
    val message: String,
    val upcomingTitle: String,
    val upcoming: List<Pair<String, String>>,
    val labels: JSONObject,
)

object TodayWidget {
    const val SCHEME = "mairuf-widget"
    const val ACTION_REFRESH = "space.mai.mai_stay_in_touch.widget.REFRESH"
    const val ACTION_LATER = "space.mai.mai_stay_in_touch.widget.LATER"
    private const val LINK_OPEN = "$SCHEME://open"

    /** Warteschlange der App (wie `lib/services/pending_actions.dart`). */
    private const val QUEUE_FILE = "pending_actions.jsonl"

    /** Größenstufen (dp). Gewählt wird die größte, die passt. */
    private enum class Size(val width: Float, val height: Float) {
        /** Eine Zeile hoch oder eine Spalte breit: Name. */
        TINY(40f, 40f),

        /** Breite Zeile: dazu „Anrufen“. */
        STRIP(180f, 40f),

        /** Ab etwa 2×2: alle drei Knöpfe. */
        CARD(110f, 110f),

        /** Ab etwa 3×3: dazu die nächsten Vorschläge. */
        LIST(180f, 220f),
    }

    fun refreshAll(context: Context) {
        val manager = AppWidgetManager.getInstance(context)
        val ids = manager.getAppWidgetIds(ComponentName(context, TodayWidgetProvider::class.java))
        for (id in ids) draw(context, manager, id)
        scheduleMidnight(context)
    }

    fun draw(context: Context, manager: AppWidgetManager, id: Int) {
        val model = model(context)
        val views = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            RemoteViews(Size.entries.associate { size -> SizeF(size.width, size.height) to views(context, model, size) })
        } else {
            val options = manager.getAppWidgetOptions(id)
            // Hochformat: kleinste Breite, größte Höhe.
            val w = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH).toFloat()
            val h = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MAX_HEIGHT).toFloat()
            views(context, model, pick(w, h))
        }
        manager.updateAppWidget(id, views)
    }

    /** Wie das System ab Android 12: größte Stufe, die passt, sonst die kleinste. */
    private fun pick(width: Float, height: Float): Size {
        if (width <= 0f || height <= 0f) return Size.CARD
        return Size.entries
            .filter { it.width <= width && it.height <= height }
            .maxByOrNull { it.width * it.height }
            ?: Size.TINY
    }

    private fun entry(json: JSONObject?): Entry? {
        if (json == null) return null
        val day = try {
            LocalDate.parse(json.optString("day"))
        } catch (_: Exception) {
            return null
        }
        val id = json.optString("id").takeIf { it.isNotEmpty() } ?: return null
        return Entry(
            day = day,
            id = id,
            name = json.optString("name"),
            detail = json.optString("detail"),
            phone = json.optBoolean("phone"),
            whatsapp = json.optBoolean("whatsapp"),
            status = json.optString("status", "open").ifEmpty { "open" },
        )
    }

    private fun model(context: Context): Model {
        val setup = context.getString(R.string.widget_setup)
        val title = context.getString(R.string.widget_label)
        val snap = WidgetStore.snapshot(context)
            ?: return Model(title, null, setup, "", emptyList(), JSONObject())
        val labels = snap.optJSONObject("labels") ?: JSONObject()
        fun label(key: String, fallback: String) = labels.optString(key, fallback).ifEmpty { fallback }

        val now = LocalDate.now()
        val upcoming = ArrayList<Entry>()
        val list = snap.optJSONArray("upcoming")
        if (list != null) {
            for (i in 0 until list.length()) entry(list.optJSONObject(i))?.let { upcoming.add(it) }
        }
        // Heute selbst bestimmen, damit es nach Mitternacht ohne App stimmt:
        // Ist der gespeicherte Tag vorbei, gilt der Vorschlag aus der Vorschau.
        val stored = entry(snap.optJSONObject("today"))
        val today = stored?.takeIf { it.day == now }
            ?: upcoming.firstOrNull { it.day == now }
        val rows = upcoming
            .filter { it.day.isAfter(now) }
            .map { dayLabel(it.day, now, labels) to it.name }
        val anyone = stored != null || upcoming.isNotEmpty()
        return Model(
            title = label("title", title),
            today = today,
            message = if (anyone) label("free", "") else label("empty", setup),
            upcomingTitle = label("upcoming", ""),
            upcoming = rows,
            labels = labels,
        )
    }

    /** „Morgen“ oder Wochentag. */
    private fun dayLabel(date: LocalDate, today: LocalDate, labels: JSONObject): String =
        when (date) {
            today -> labels.optString("today")
            today.plusDays(1) -> labels.optString("tomorrow")
            else -> labels.optJSONArray("weekdays")?.optString(date.dayOfWeek.value - 1) ?: ""
        }

    private fun views(context: Context, model: Model, size: Size): RemoteViews =
        when (size) {
            Size.TINY -> strip(context, model, compact = true)
            Size.STRIP -> strip(context, model, compact = false)
            Size.CARD -> card(context, model, list = false)
            Size.LIST -> card(context, model, list = true)
        }

    private fun statusText(model: Model, entry: Entry): String? = when (entry.status) {
        "open" -> null
        "declined" -> "☾ " + model.labels.optString("declined")
        else -> "✓ " + model.labels.optString("done")
    }

    private fun strip(context: Context, model: Model, compact: Boolean): RemoteViews {
        val v = RemoteViews(context.packageName, R.layout.widget_strip)
        val entry = model.today
        v.setTextViewText(R.id.widget_title, model.title)
        val status = entry?.let { statusText(model, it) }
        v.setTextViewText(
            R.id.widget_line,
            when {
                entry == null -> model.message
                status != null -> "${entry.name} · $status"
                else -> entry.name
            },
        )
        v.setOnClickPendingIntent(android.R.id.background, open(context, LINK_OPEN))
        v.setOnClickPendingIntent(R.id.widget_header, open(context, LINK_OPEN))
        val canCall = !compact && entry != null && entry.status == "open" && entry.phone
        v.setViewVisibility(R.id.widget_call, if (canCall) View.VISIBLE else View.GONE)
        if (canCall) v.setOnClickPendingIntent(R.id.widget_call, open(context, link("call", entry!!)))
        return v
    }

    private fun card(context: Context, model: Model, list: Boolean): RemoteViews {
        val v = RemoteViews(context.packageName, R.layout.widget_card)
        val entry = model.today
        v.setTextViewText(R.id.widget_title, model.title)
        v.setOnClickPendingIntent(android.R.id.background, open(context, LINK_OPEN))
        v.setOnClickPendingIntent(R.id.widget_header, open(context, LINK_OPEN))
        v.setTextViewText(R.id.widget_name, entry?.name ?: model.message)
        v.setViewVisibility(R.id.widget_detail, if (entry == null) View.GONE else View.VISIBLE)
        v.setTextViewText(R.id.widget_detail, entry?.detail ?: "")

        val status = entry?.let { statusText(model, it) }
        if (entry != null && status == null) {
            v.setViewVisibility(R.id.widget_actions, View.VISIBLE)
            v.setViewVisibility(R.id.widget_call, if (entry.phone) View.VISIBLE else View.GONE)
            v.setOnClickPendingIntent(R.id.widget_call, open(context, link("call", entry)))
            v.setViewVisibility(R.id.widget_whatsapp, if (entry.whatsapp) View.VISIBLE else View.GONE)
            v.setOnClickPendingIntent(R.id.widget_whatsapp, open(context, link("whatsapp", entry)))
            v.setOnClickPendingIntent(R.id.widget_later, later(context, entry))
        } else {
            v.setViewVisibility(R.id.widget_actions, View.GONE)
        }
        v.setViewVisibility(R.id.widget_status, if (status == null) View.GONE else View.VISIBLE)
        v.setTextViewText(R.id.widget_status, status ?: "")

        v.removeAllViews(R.id.widget_rows)
        val rows = if (list) model.upcoming else emptyList()
        v.setViewVisibility(R.id.widget_upcoming_title, if (rows.isEmpty()) View.GONE else View.VISIBLE)
        v.setTextViewText(R.id.widget_upcoming_title, model.upcomingTitle)
        for ((day, name) in rows) {
            val row = RemoteViews(context.packageName, R.layout.widget_row)
            row.setTextViewText(R.id.row_day, day)
            row.setTextViewText(R.id.row_name, name)
            v.addView(R.id.widget_rows, row)
        }
        return v
    }

    private fun link(action: String, entry: Entry) =
        "$SCHEME://$action?d=${entry.day}&c=${Uri.encode(entry.id)}"

    /** Öffnet die App (bzw. Anrufen/WhatsApp) über den Kanal mai/widgets. */
    private fun open(context: Context, link: String): PendingIntent {
        val intent = Intent(context, MainActivity::class.java)
            .setAction(Intent.ACTION_VIEW)
            .setData(Uri.parse(link))
            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
        return PendingIntent.getActivity(
            context,
            link.hashCode(),
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
    }

    /** „Heute nicht“ ohne die App zu öffnen. */
    private fun later(context: Context, entry: Entry): PendingIntent {
        val link = link("later", entry)
        val intent = Intent(context, TodayWidgetProvider::class.java)
            .setAction(ACTION_LATER)
            .setData(Uri.parse(link))
        return PendingIntent.getBroadcast(
            context,
            link.hashCode(),
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
    }

    /**
     * „Heute nicht“ aus dem Widget: in die Warteschlange der App schreiben
     * (übernimmt sie beim nächsten Öffnen, auch während sie läuft) und den
     * Stand im Widget sofort als abgelehnt zeigen.
     */
    fun later(context: Context, data: Uri?) {
        val day = data?.getQueryParameter("d") ?: return
        val id = data.getQueryParameter("c") ?: return
        try {
            val line = JSONObject()
                .put("d", day)
                .put("c", id)
                .put("a", "later")
                .put("ts", System.currentTimeMillis())
            File(context.filesDir, QUEUE_FILE).appendText("$line\n")
        } catch (_: Exception) {
            return
        }
        WidgetStore.markStatus(context, day, id, "declined")
        refreshAll(context)
        WearSync.publish(context, WidgetStore.snapshot(context))
    }

    /**
     * Kurz nach Mitternacht neu zeichnen („heute“ wechselt). Ungenauer
     * Wecker: braucht keine Berechtigung und weckt das Gerät nicht.
     */
    fun scheduleMidnight(context: Context) {
        val manager = AppWidgetManager.getInstance(context)
        val any = manager
            .getAppWidgetIds(ComponentName(context, TodayWidgetProvider::class.java))
            .isNotEmpty()
        val alarms = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(context, TodayWidgetProvider::class.java).setAction(ACTION_REFRESH)
        val pending = PendingIntent.getBroadcast(
            context,
            1,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        if (!any) {
            alarms.cancel(pending)
            return
        }
        val next = LocalDate.now().plusDays(1)
            .atStartOfDay(ZoneId.systemDefault())
            .toInstant()
            .toEpochMilli() + 60_000L
        alarms.set(AlarmManager.RTC, next, pending)
    }
}

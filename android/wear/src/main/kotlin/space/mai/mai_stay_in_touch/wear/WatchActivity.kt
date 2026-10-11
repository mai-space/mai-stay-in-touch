package space.mai.mai_stay_in_touch.wear

import android.app.Activity
import android.graphics.Typeface
import android.os.Bundle
import android.util.TypedValue
import android.view.Gravity
import android.widget.LinearLayout
import android.widget.ScrollView
import android.widget.TextView

/**
 * Übersicht auf der Uhr (Ziel von Kachel und Komplikation): heutiger
 * Vorschlag und die nächsten Tage. Angerufen wird über das Telefon.
 */
class WatchActivity : Activity() {
    private lateinit var column: LinearLayout

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Runde Displays: großzügiger Rand, Inhalt mittig.
        val pad = (resources.displayMetrics.widthPixels * 0.12f).toInt()
        column = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER_HORIZONTAL
            setPadding(pad, pad, pad, pad)
        }
        setContentView(
            ScrollView(this).apply {
                isFillViewport = true
                addView(column)
            },
        )
    }

    override fun onResume() {
        super.onResume()
        WatchStore.ensure(this)
        render()
    }

    private fun render() {
        column.removeAllViews()
        val state = WatchStore.state(this)
        line(getString(R.string.watch_today_title), 14f, COLOR_PRIMARY)
        if (state == null) {
            line(getString(R.string.watch_setup), 15f, COLOR_ON_SURFACE)
            return
        }
        val pick = state.today()
        if (pick == null) {
            line(getString(if (state.empty) R.string.watch_empty else R.string.watch_free), 15f, COLOR_ON_SURFACE)
        } else {
            line(pick.name, 20f, COLOR_ON_SURFACE, bold = true)
            val status = state.status(this, pick)
            if (status != null) {
                line(status, 15f, COLOR_PRIMARY)
            } else {
                if (pick.detail.isNotEmpty()) line(pick.detail, 14f, COLOR_VARIANT)
                line(getString(R.string.watch_call_on_phone), 12f, COLOR_VARIANT)
            }
        }
        val next = state.next()
        if (next.isNotEmpty()) {
            line(getString(R.string.watch_upcoming), 13f, COLOR_PRIMARY, top = 12)
            for (p in next) line("${WatchState.dayLabel(this, p.day)}: ${p.name}", 14f, COLOR_ON_SURFACE)
        }
    }

    private fun line(value: String, size: Float, color: Int, bold: Boolean = false, top: Int = 4) {
        column.addView(
            TextView(this).apply {
                text = value
                gravity = Gravity.CENTER_HORIZONTAL
                setTextColor(color)
                setTextSize(TypedValue.COMPLEX_UNIT_SP, size)
                if (bold) setTypeface(typeface, Typeface.BOLD)
                setPadding(0, top, 0, 4)
            },
        )
    }

    private companion object {
        const val COLOR_PRIMARY = 0xFF94D5B5.toInt()
        const val COLOR_ON_SURFACE = 0xFFDEE4DF.toInt()
        const val COLOR_VARIANT = 0xFFBFC9C2.toInt()
    }
}

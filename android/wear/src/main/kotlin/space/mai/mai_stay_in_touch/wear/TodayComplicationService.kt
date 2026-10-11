package space.mai.mai_stay_in_touch.wear

import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.graphics.drawable.Icon
import androidx.wear.watchface.complications.data.ComplicationData
import androidx.wear.watchface.complications.data.ComplicationText
import androidx.wear.watchface.complications.data.ComplicationType
import androidx.wear.watchface.complications.data.LongTextComplicationData
import androidx.wear.watchface.complications.data.MonochromaticImage
import androidx.wear.watchface.complications.data.PlainComplicationText
import androidx.wear.watchface.complications.data.ShortTextComplicationData
import androidx.wear.watchface.complications.datasource.ComplicationDataSourceService
import androidx.wear.watchface.complications.datasource.ComplicationRequest
import java.time.LocalDate

/**
 * Komplikation fürs Zifferblatt:
 * - kurz: Vorname (bzw. Initialen) des heutigen Vorschlags, „✓“ wenn erledigt
 * - lang: Name und letzter Kontakt
 */
class TodayComplicationService : ComplicationDataSourceService() {
    override fun onComplicationRequest(
        request: ComplicationRequest,
        listener: ComplicationDataSourceService.ComplicationRequestListener,
    ) {
        WatchStore.ensure(this)
        listener.onComplicationData(data(this, request.complicationType, WatchStore.state(this)))
    }

    override fun getPreviewData(type: ComplicationType): ComplicationData? =
        data(
            this,
            type,
            WatchState(
                WatchPick(
                    LocalDate.now(),
                    getString(R.string.watch_preview_name),
                    getString(R.string.watch_preview_detail),
                    "open",
                ),
                emptyList(),
            ),
            preview = true,
        )

    private fun data(
        context: Context,
        type: ComplicationType,
        state: WatchState?,
        preview: Boolean = false,
    ): ComplicationData? {
        val pick = state?.today()
        val title = context.getString(R.string.watch_today_title)
        val name = when {
            pick != null -> pick.name
            state == null -> context.getString(R.string.watch_setup_short)
            else -> context.getString(R.string.watch_free)
        }
        val status = if (state != null && pick != null) state.status(context, pick) else null
        val short = when {
            pick == null -> context.getString(R.string.watch_none)
            status != null -> "✓"
            else -> pick.name.substringBefore(' ').take(7)
        }
        val description = plain("$title: $name")
        val icon = MonochromaticImage.Builder(Icon.createWithResource(context, R.drawable.ic_call)).build()
        val tap = if (preview) null else open(context)
        return when (type) {
            ComplicationType.SHORT_TEXT -> ShortTextComplicationData.Builder(plain(short), description)
                .setMonochromaticImage(icon)
                .setTapAction(tap)
                .build()
            ComplicationType.LONG_TEXT -> LongTextComplicationData.Builder(plain(name), description)
                .setTitle(plain(status ?: pick?.detail?.takeIf { it.isNotEmpty() } ?: title))
                .setMonochromaticImage(icon)
                .setTapAction(tap)
                .build()
            else -> null
        }
    }

    private fun plain(text: String): ComplicationText = PlainComplicationText.Builder(text).build()

    private fun open(context: Context): PendingIntent =
        PendingIntent.getActivity(
            context,
            0,
            Intent(context, WatchActivity::class.java).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
}

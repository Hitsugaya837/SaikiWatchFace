// SaikiWatchFaceView.mc
// Watch face view with time-based theme switching
// Connect IQ 9.2.0 | Monkey C | Forerunner 265
//
// Four themes based on time of day:
//   05:00 - 10:59  →  Morning (清晨睡醒)
//   11:00 - 13:59  →  Noon    (正午用餐)
//   14:00 - 17:59  →  Afternoon (下午学习/工作)
//   18:00 - 04:59  →  Night   (夜间休憩)
//
// All 4 theme bitmaps are preloaded in initialize() via WatchUi.loadResource()
// (SDK-supported lifecycle phase), then indexed in onUpdate().

import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.WatchUi;

class SaikiWatchFaceView extends WatchUi.WatchFace {

    // Preloaded background bitmaps indexed by period.
    // Index: 0=Morning, 1=Noon, 2=Afternoon, 3=Night
    var mThemes as Array;

    // Always-on (sleep) mode flag
    var mIsSleepMode = false;

    function initialize() {
        WatchFace.initialize();

        // Preload ALL 4 theme bitmaps here — loadResource must be called from
        // a valid lifecycle phase (initialize/onShow), not from onUpdate.
        mThemes = [
            WatchUi.loadResource(Rez.Drawables.theme_morning) as BitmapResource,  // 0
            WatchUi.loadResource(Rez.Drawables.theme_noon) as BitmapResource,    // 1
            WatchUi.loadResource(Rez.Drawables.theme_afternoon) as BitmapResource,// 2
            WatchUi.loadResource(Rez.Drawables.theme_night) as BitmapResource     // 3
        ];
    }

    // --- Layout ---
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.WatchFaceLayout(dc));
    }

    // --- Time period logic ---

    // Returns: 0=Morning, 1=Noon, 2=Afternoon, 3=Night
    function getTimePeriod(hour as Number) as Number {
        if (hour >= 5 && hour < 11) {
            return 0;   // 清晨睡醒  05:00–10:59
        } else if (hour >= 11 && hour < 14) {
            return 1;   // 正午用餐  11:00–13:59
        } else if (hour >= 14 && hour < 18) {
            return 2;   // 下午学习/工作  14:00–17:59
        } else {
            return 3;   // 夜间休憩  18:00–04:59
        }
    }

    // --- Main render ---

    function onUpdate(dc as Dc) as Void {
        var clockTime = System.getClockTime();
        var period = getTimePeriod(clockTime.hour);

        // Build display strings
        var timeStr = clockTime.hour.format("%02d") + ":" + clockTime.min.format("%02d");

        var info = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        var dateStr = info.day_of_week + " " + info.day + "/" + info.month;

        if (mIsSleepMode) {
            // ---- Always-on (low-power) mode ----
            // Black background to save battery on AMOLED
            dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
            dc.fillRectangle(0, 0, dc.getWidth(), dc.getHeight());

            // Time only, dim gray
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                dc.getWidth() / 2,
                dc.getHeight() / 2 - 10,
                Graphics.FONT_LARGE,
                timeStr,
                Graphics.TEXT_JUSTIFY_CENTER
            );
        } else {
            // ---- Active (full) mode ----

            // Clear the screen first
            dc.clear();

            // Draw the theme background (416×416, full screen)
            dc.drawBitmap(0, 0, mThemes[period]);

            // Draw time on top of the background
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                dc.getWidth() / 2,
                dc.getHeight() / 2 - 12,
                Graphics.FONT_LARGE,
                timeStr,
                Graphics.TEXT_JUSTIFY_CENTER
            );

            // Draw date below the time
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                dc.getWidth() / 2,
                dc.getHeight() / 2 + 48,
                Graphics.FONT_SMALL,
                dateStr,
                Graphics.TEXT_JUSTIFY_CENTER
            );
        }
    }

    // --- Always-on mode handlers ---

    function onEnterSleepMode() as Void {
        mIsSleepMode = true;
    }

    function onExitSleepMode() as Void {
        mIsSleepMode = false;
    }
}

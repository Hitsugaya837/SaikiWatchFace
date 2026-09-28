// SaikiWatchFaceApp.mc
// Application entry point for Saiki Watch Face
// Connect IQ 9.2.0 | Monkey C | Forerunner 265

import Toybox.Application;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class SaikiWatchFaceApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    // Called when the app starts
    function onStart(state as Dictionary?) as Void {
    }

    // Called when the app exits
    function onStop(state as Dictionary?) as Void {
    }

    // Return the initial view — our watch face
    function getInitialView() as [Views] or [Views, InputDelegates] {
        return [ new SaikiWatchFaceView() ];
    }
}

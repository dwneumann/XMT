package XMT.android;

import android.content.Context;
import android.content.IntentFilter;

public final class Intents {
    public static final String XHIST_INTENT = "io.rightmesh.intent.XHIST";
    private static IntentReceiver intentReceiver = new IntentReceiver();

    public static void registerIntentReceiver(Context applicationContext) {
        applicationContext.registerReceiver(
            intentReceiver,
            new IntentFilter(XHIST_INTENT)
        );
    }

    public static void unregisterIntentReceiver(Context applicationContext) {
        applicationContext.unregisterReceiver(intentReceiver);
    }
}
package XMT.android;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.util.Log;

import XMT.Xhist;

public class IntentReceiver extends BroadcastReceiver {

    public static final String XHIST_INTENT = "io.rightmesh.intent.XHIST";

    @Override
    public void onReceive(Context context, Intent intent) {
        Log.i("IR", "Received the intent");

        Xhist.write();
    }
}

package XMT;

import sun.misc.Signal;

public final class Signals {
    public static void registerListener() {
        System.out.println("registerListener()");
        Signal signal = new Signal("USR2");
        Signal.handle(signal, (receivedSignal) -> {
            System.out.println("receivedSignal");
            if (signal.toString().trim().equals("SIGUSR2")) {
                System.out.println("received SIGUSR2");
                Xhist.write();
                System.out.println("xhist wrote");
            }
        });
    }
}
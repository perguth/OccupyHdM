package occupyhdm.app;

import java.util.concurrent.Callable;

public abstract class Callback implements Callable<Void> {
    String result;

    void setResult (String string) {
        result = string;
    }

    public abstract Void call();
}

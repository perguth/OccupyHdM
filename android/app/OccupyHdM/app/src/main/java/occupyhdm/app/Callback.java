package occupyhdm.app;

import java.util.concurrent.Callable;

public abstract class Callback<T> implements Callable<Void> {
    T result;

    void setResult (T result) {
        this.result = result;
    }

    public abstract Void call();
}

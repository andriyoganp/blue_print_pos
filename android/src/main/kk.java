public class AndroidPlatformViewFactory extends PlatformViewFactory {
    public AndroidPlatformViewFactory() {
        super(StandardMessageCodec.INSTANCE);
    }

    @NonNull
    @Override
    public PlatformView create(Context context, int viewId, @Nullable Object args) {
        return new FLNativeView(context);
    }
}

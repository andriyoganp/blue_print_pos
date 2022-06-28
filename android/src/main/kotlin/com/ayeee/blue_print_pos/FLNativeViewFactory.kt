package com.ayeee.blue_print_pos

import android.content.Context
import android.view.View
import android.webkit.WebView
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

 class FLNativeViewFactory : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(p0: Context?, p1: Int, p2: Any?): PlatformView {
        val creationParams = p2 as Map<String?, Any?>?
        val context = p0 as Context
        return FLNativeView(context, p1, creationParams)
    }
}


internal class FLNativeView(context: Context, id: Int, creationParams: Map<String?, Any?>?) : PlatformView {
    private val webView: WebView by lazy { WebView(context)}
    private val arguments: Map<String?, Any?>? by lazy {creationParams}

    override fun getView(): View {
        return webView
    }

    override fun dispose() {}

    init {
        context?.let { ct ->
        var width = (arguments!!["width"]!! as Number).toInt()
        var height = (arguments!!["height"]!! as Number).toInt()
        var content = arguments!!["content"] as String
        webView.layout(0, 0, width, height)
        webView.loadDataWithBaseURL(null, content, "text/HTML", "UTF-8", null)
        webView.setInitialScale(1)
        webView.settings.javaScriptEnabled = true
        webView.settings.useWideViewPort = true
        webView.settings.javaScriptCanOpenWindowsAutomatically = true
        webView.settings.loadWithOverviewMode = true
        }

    }

}

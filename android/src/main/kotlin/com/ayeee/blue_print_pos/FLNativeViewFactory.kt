package com.ayeee.blue_print_pos

import android.content.Context
import android.view.View
import android.webkit.WebView
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class FLNativeViewFactory : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        val creationParams = args as Map<String?, Any?>?
        return FLNativeView(context, viewId, creationParams)
    }
}


internal class FLNativeView(context: Context, id: Int, creationParams: Map<String?, Any?>?) : PlatformView {
    private val webView: WebView = WebView(context)
    private var arguments: Map<String?, Any?>? = creationParams

    override fun getView(): View {
        return webView
    }

    override fun dispose() {}

    init {
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

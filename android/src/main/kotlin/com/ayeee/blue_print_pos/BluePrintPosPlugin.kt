package com.ayeee.blue_print_pos

import android.app.Activity
import android.content.Context
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.view.WindowInsets
import android.webkit.WebView
import android.webkit.WebViewClient
import androidx.annotation.NonNull
import com.ayeee.blue_print_pos.extension.toBitmap
import com.ayeee.blue_print_pos.extension.toByteArray
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** BluePrintPosPlugin */
class BluePrintPosPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private lateinit var activity: Activity
    private lateinit var context: Context
    private lateinit var webView: WebView

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        val viewID = "webview-view-type"
        flutterPluginBinding.platformViewRegistry.registerViewFactory(viewID, FLNativeViewFactory())

        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "blue_print_pos")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        val arguments = call.arguments as Map<*, *>
        val content = arguments["content"] as String
        val duration = arguments["duration"] as Double?

        if (call.method == "contentToImage") {
            webView = WebView(this.context)
            val dWidth: Int
            val dHeight: Int
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                val windowMetrics = activity.windowManager.currentWindowMetrics
                val insets = windowMetrics.windowInsets.getInsetsIgnoringVisibility(WindowInsets.Type.systemBars())
                dWidth = windowMetrics.bounds.width() - insets.left - insets.right
                dHeight = windowMetrics.bounds.height() - insets.bottom - insets.top
            } else {
                dWidth = this.activity.window.windowManager.defaultDisplay.width
                dHeight = this.activity.window.windowManager.defaultDisplay.height
            }
            print("\ndwidth : $dWidth")
            print("\ndheight : $dHeight")
            webView.layout(0, 0, dWidth, dHeight)
            webView.loadDataWithBaseURL(null, content, "text/HTML", "UTF-8", null)
            webView.setInitialScale(1)
            webView.settings.javaScriptEnabled = true
            webView.settings.useWideViewPort = true
            webView.settings.javaScriptCanOpenWindowsAutomatically = true
            webView.settings.loadWithOverviewMode = true
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                print("\n=======> enabled scrolled <=========")
                WebView.enableSlowWholeDocumentDraw()
            }

            print("\n ///////////////// webview setted /////////////////")

            webView.webViewClient = object : WebViewClient() {
                override fun onPageFinished(view: WebView, url: String) {
                    super.onPageFinished(view, url)

                    Handler(Looper.getMainLooper()).postDelayed({
                        print("\nOS Version: ${Build.VERSION.SDK_INT}")
                        print("\n ================ webview completed ==============")
                        print("\n scroll delayed ${webView.scrollBarFadeDuration}")

                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
                            webView.evaluateJavascript("document.body.offsetWidth") { offsetWidth ->
                                webView.evaluateJavascript("document.body.offsetHeight") { offsetHeight ->
                                    print("\noffsetWidth : $offsetWidth")
                                    print("\noffsetHeight : $offsetHeight")
                                    val data = webView.toBitmap(
                                        offsetWidth!!.toDouble(),
                                        offsetHeight!!.toDouble()
                                    )
                                    if (data != null) {
                                        val bytes = data.toByteArray()
                                        result.success(bytes)
                                        println("\n Got snapshot")
                                    }
                                }
                            }
                        }
                    }, (duration ?: 0.0).toLong())
                }
            }
        } else {
            result.notImplemented()
        }
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        print("onAttachedToActivity")
        activity = binding.activity
        webView = WebView(activity.applicationContext)
        webView.minimumHeight = 1
        webView.minimumWidth = 1
    }

    override fun onDetachedFromActivityForConfigChanges() {
        // TODO: the Activity your plugin was attached to was destroyed to change configuration.
        // This call will be followed by onReattachedToActivityForConfigChanges().
        print("onDetachedFromActivityForConfigChanges")
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        // TODO: your plugin is now attached to a new Activity after a configuration change.
        print("onAttachedToActivity")
        onAttachedToActivity(binding)
    }

    override fun onDetachedFromActivity() {
        // TODO: your plugin is no longer associated with an Activity. Clean up references.
        print("onDetachedFromActivity")
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}

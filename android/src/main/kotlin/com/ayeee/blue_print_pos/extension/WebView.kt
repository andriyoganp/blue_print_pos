package com.ayeee.blue_print_pos.extension

import android.graphics.Bitmap
import android.graphics.Canvas
import android.view.View
import android.webkit.WebView
import kotlin.math.absoluteValue

fun WebView.toBitmap(offsetWidth: Double, offsetHeight: Double): Bitmap? {
    if (offsetHeight > 0 && offsetWidth > 0) {
        val width = (offsetWidth * this.resources.displayMetrics.density).absoluteValue.toInt()
        val height = (offsetHeight * this.resources.displayMetrics.density).absoluteValue.toInt()
        this.measure(View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED), View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED))
        val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        this.draw(canvas)
        return bitmap
    }
    return null
}
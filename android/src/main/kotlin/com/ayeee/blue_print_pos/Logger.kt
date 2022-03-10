package com.ayeee.blue_print_pos

import android.util.Log

object Logger {
    fun log(message: String) {
        if (BuildConfig.DEBUG) {
            Log.d("BluePrintPos", message)
        }
    }
}
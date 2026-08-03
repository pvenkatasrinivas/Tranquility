package com.tranquility.mobile

import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.EventChannel

object ForegroundAppStreamHandler : EventChannel.StreamHandler {

    private var sink: EventChannel.EventSink? = null
    private val mainHandler = Handler(Looper.getMainLooper())

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        sink = events
    }

    override fun onCancel(arguments: Any?) {
        sink = null
    }

    fun emit(packageName: String, appName: String, openCount: Int) {

        // ✅ IMPORTANT: skip if Flutter not active (fix lag)
        if (!AppState.isFlutterActive) return

        val data = mapOf(
            "packageName" to packageName,
            "appName" to appName,
            "openCount" to openCount
        )

        mainHandler.post {
            sink?.success(data)
        }
    }
}
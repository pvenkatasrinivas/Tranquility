package com.tranquility.mobile

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED) {
            val service = Intent(context, TranquilityForegroundService::class.java)
                .apply { action = TranquilityForegroundService.ACTION_START }
            context.startForegroundService(service)
        }
    }
}
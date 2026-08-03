package com.tranquility.mobile

import android.app.usage.UsageStatsManager
import android.content.Context
import java.util.Calendar

object UsageStatsHelper {

    fun getTodayUsageMinutes(context: Context, packageName: String): Int {

        val usm = context.getSystemService(Context.USAGE_STATS_SERVICE)
                as? UsageStatsManager ?: return 0

        val cal = Calendar.getInstance().apply {
            set(Calendar.HOUR_OF_DAY, 0)
            set(Calendar.MINUTE, 0)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
        }

        val startOfDay = cal.timeInMillis
        val now = System.currentTimeMillis()

        val stats = usm.queryUsageStats(
            UsageStatsManager.INTERVAL_DAILY,
            startOfDay,
            now
        ) ?: return 0

        // ✅ FIX: sum all entries instead of find()
        var totalTime = 0L

        for (stat in stats) {
            if (stat.packageName == packageName) {
                totalTime += stat.totalTimeInForeground
            }
        }

        return (totalTime / 60_000L).toInt()
    }
}
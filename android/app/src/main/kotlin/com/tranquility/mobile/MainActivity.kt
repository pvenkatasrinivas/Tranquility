package com.tranquility.mobile

import android.content.Intent
import android.provider.Settings
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    companion object {
        const val METHOD_CHANNEL = "com.tranquility.mobile/control"
        const val EVENT_CHANNEL  = "com.tranquility.mobile/foreground_app"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            EVENT_CHANNEL
        ).setStreamHandler(ForegroundAppStreamHandler)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            METHOD_CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {

                "startMonitoring" -> {
                    val i = Intent(this, TranquilityForegroundService::class.java)
                        .apply { action = TranquilityForegroundService.ACTION_START }
                    startForegroundService(i)
                    result.success(null)
                }

                "stopMonitoring" -> {
                    val i = Intent(this, TranquilityForegroundService::class.java)
                        .apply { action = TranquilityForegroundService.ACTION_STOP }
                    startService(i)
                    result.success(null)
                }

                "updateRestrictedApps" -> {
                    @Suppress("UNCHECKED_CAST")
                    val packages = call.argument<List<String>>("packages") ?: emptyList()
                    AppState.restrictedPackages = packages.toSet()
                    result.success(null)
                }

                "updateDelay" -> {
                    val delay = call.argument<Int>("delay") ?: 3
                    AppState.delaySeconds = delay
                    result.success(null)
                }

                // ✅ నువ్వు అడిగిన 2 కొత్త methods (existing block లో సరిగ్గా add చేశాను)
                "updateHardMode" -> {
                    val enabled = call.argument<Boolean>("enabled") ?: false
                    AppState.hardModeEnabled = enabled
                    result.success(null)
                }

                "updateGlobalOpenLimit" -> {
                    val limit = call.argument<Int>("limit") ?: 0
                    AppState.globalOpenLimit = limit
                    result.success(null)
                }

                "openAccessibilitySettings" -> {
                    startActivity(Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS))
                    result.success(null)
                }

                "openUsageAccessSettings" -> {
                    startActivity(Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS))
                    result.success(null)
                }

                "isAccessibilityEnabled" -> {
                    result.success(TranquilityAccessibilityService.isEnabled(this))
                }

                "getUsageMinutes" -> {
                    val pkg = call.argument<String>("package") ?: ""
                    val mins = UsageStatsHelper.getTodayUsageMinutes(this, pkg)
                    result.success(mins)
                }

                "getInstalledApps" -> {
                    result.success(getInstalledApps())
                }

                "getOpenCounts" -> {
                    result.success(AppState.getAllOpenCounts())
                }

                "goHome" -> {
                    val home = Intent(Intent.ACTION_MAIN).apply {
                        addCategory(Intent.CATEGORY_HOME)
                        flags = Intent.FLAG_ACTIVITY_NEW_TASK
                    }
                    startActivity(home)
                    result.success(null)
                }

                "continueToApp" -> {
                    moveTaskToBack(true)
                    result.success(null)
                }

                else -> result.notImplemented()
            }
        }
    }

    // ✅ when app already running
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
    }

    override fun onResume() {
        super.onResume()
        AppState.isFlutterActive = true
        forwardInterventionIntent(intent)
    }

    override fun onPause() {
        super.onPause()
        AppState.isFlutterActive = false
    }

    // ✅ ADD THIS (important fix)
    override fun onDestroy() {
        super.onDestroy()
        AppState.isFlutterActive = false
    }

    // ✅ FIXED METHOD (retry logic added, rest untouched)
    private fun forwardInterventionIntent(intent: Intent?) {
        val pkg   = intent?.getStringExtra("intervention_package") ?: return
        val name  = intent.getStringExtra("intervention_name") ?: pkg
        val count = intent.getIntExtra("intervention_count", 1)

        intent.removeExtra("intervention_package")
        intent.removeExtra("intervention_name")
        intent.removeExtra("intervention_count")

        val handler = Handler(Looper.getMainLooper())

        fun tryEmit(retry: Int) {
            if (retry > 10) return

            if (AppState.isFlutterActive) {
                ForegroundAppStreamHandler.emit(pkg, name, count)
            } else {
                handler.postDelayed({ tryEmit(retry + 1) }, 100)
            }
        }

        handler.postDelayed({ tryEmit(0) }, 200)

        AppState.clearPending()
    }

    private fun getInstalledApps(): List<Map<String, String>> {
        val pm = packageManager
        val mainIntent = Intent(Intent.ACTION_MAIN, null).apply {
            addCategory(Intent.CATEGORY_LAUNCHER)
        }
        return pm.queryIntentActivities(mainIntent, 0)
            .filter { it.activityInfo.packageName != packageName }
            .map {
                mapOf(
                    "packageName" to it.activityInfo.packageName,
                    "appName"     to it.loadLabel(pm).toString()
                )
            }
            .sortedBy { it["appName"] }
    }
}
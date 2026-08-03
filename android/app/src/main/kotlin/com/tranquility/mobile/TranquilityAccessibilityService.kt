package com.tranquility.mobile

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.AccessibilityServiceInfo
import android.content.Context
import android.content.Intent
import android.provider.Settings
import android.text.TextUtils
import android.view.accessibility.AccessibilityEvent
import kotlinx.coroutines.*

class TranquilityAccessibilityService : AccessibilityService() {

    private val scope = CoroutineScope(Dispatchers.Default + SupervisorJob())
    private var pendingJob: Job? = null

    override fun onServiceConnected() {
        serviceInfo = AccessibilityServiceInfo().apply {
            eventTypes = AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED
            feedbackType = AccessibilityServiceInfo.FEEDBACK_GENERIC
            flags = AccessibilityServiceInfo.FLAG_INCLUDE_NOT_IMPORTANT_VIEWS
            notificationTimeout = 100L
        }
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        event ?: return
        if (event.eventType != AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) return

        val pkg = event.packageName?.toString() ?: return
        if (pkg == packageName) return
        if (pkg == "android") return
        if (pkg == "com.android.launcher") return

        val restricted = AppState.restrictedPackages
        if (pkg !in restricted) return

        val now = System.currentTimeMillis()
        if (pkg == AppState.lastInterceptedPackage &&
            now - AppState.lastInterceptTime < 30_000L
        ) return

        pendingJob?.cancel()

        pendingJob = scope.launch {
            delay(AppState.delaySeconds * 1_000L)

            val currentCount = AppState.getOpenCount(pkg)

            // ✅ Hard Mode + Limit check
            if (AppState.hardModeEnabled && AppState.globalOpenLimit > 0) {
                if (currentCount >= AppState.globalOpenLimit) {
                    // ✅ Limit దాటింది — direct home screen, no intervention
                    val homeIntent = Intent(Intent.ACTION_MAIN).apply {
                        addCategory(Intent.CATEGORY_HOME)
                        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    }
                    startActivity(homeIntent)
                    return@launch
                }
            }

            // ✅ Normal flow — limit దాటలేదు
            val count = AppState.incrementOpenCount(pkg)
            AppState.lastInterceptedPackage = pkg
            AppState.lastInterceptTime = System.currentTimeMillis()

            val intent = packageManager
                .getLaunchIntentForPackage(packageName)
                ?.apply {
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    addFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT)
                    putExtra("intervention_package", pkg)
                    putExtra("intervention_count", count)
                    putExtra("intervention_blocked", false)
                }

            if (intent != null) {
                startActivity(intent)
            }
        }
    }

    override fun onInterrupt() {
        scope.cancel()
    }

    override fun onDestroy() {
        super.onDestroy()
        scope.cancel()
    }

    companion object {
        fun isEnabled(context: Context): Boolean {
            val enabledServices = Settings.Secure.getString(
                context.contentResolver,
                Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES
            ) ?: return false

            val colonSplitter = TextUtils.SimpleStringSplitter(':')
            colonSplitter.setString(enabledServices)

            val target =
                "${context.packageName}/${TranquilityAccessibilityService::class.java.name}"

            while (colonSplitter.hasNext()) {
                if (colonSplitter.next().equals(target, ignoreCase = true)) return true
            }
            return false
        }
    }
}
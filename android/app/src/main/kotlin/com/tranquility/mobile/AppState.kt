package com.tranquility.mobile

object AppState {

    @Volatile var restrictedPackages: Set<String> = emptySet()
    @Volatile var delaySeconds: Int = 3
    @Volatile var lastInterceptedPackage: String = ""
    @Volatile var lastInterceptTime: Long = 0L

    // ✅ Performance: track Flutter active state
    @Volatile var isFlutterActive: Boolean = false

    // ✅ NEW: Hard Mode + Global Open Limit
    @Volatile var hardModeEnabled: Boolean = false
    @Volatile var globalOpenLimit: Int = 0 // 0 = no limit

    private val openCounts = mutableMapOf<String, Int>()

    @Synchronized
    fun incrementOpenCount(pkg: String): Int {
        val count = (openCounts[pkg] ?: 0) + 1
        openCounts[pkg] = count
        return count
    }

    @Synchronized
    fun getOpenCount(pkg: String): Int {
        return openCounts[pkg] ?: 0
    }

    @Synchronized
    fun getAllOpenCounts(): Map<String, Int> {
        return openCounts.toMap()
    }

    fun setPending(pkg: String) {}
    fun clearPending() {}
}
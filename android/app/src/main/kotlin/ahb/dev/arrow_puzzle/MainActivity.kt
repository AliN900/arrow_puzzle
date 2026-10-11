package ahb.dev.arrow_puzzle

import android.os.Build
import android.os.Process
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val exitChannel = "ahb.dev.arrow_puzzle/exit"
    private val storeChannel = "store_detector"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // ── Exit / kill channel (Arrow Puzzle) ──
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, exitChannel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "killApp" -> {
                        result.success(null)
                        finishAffinity()
                        Process.killProcess(Process.myPid())
                    }
                    else -> result.notImplemented()
                }
            }

        // ── Store detector channel (Tasbeeh pattern) ──
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, storeChannel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getInstallerPackage" -> {
                        val installer = try {
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                                packageManager
                                    .getInstallSourceInfo(packageName)
                                    .installingPackageName
                            } else {
                                @Suppress("DEPRECATION")
                                packageManager.getInstallerPackageName(packageName)
                            }
                        } catch (e: Exception) {
                            null
                        }
                        result.success(installer ?: "unknown")
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
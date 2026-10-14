package ahb.dev.arrow_puzzle

import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.os.Process
import android.view.WindowManager
import androidx.annotation.NonNull
import androidx.core.view.WindowCompat
import androidx.core.view.WindowInsetsCompat
import androidx.core.view.WindowInsetsControllerCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val exitChannel = "ahb.dev.arrow_puzzle/exit"
    private val storeChannel = "store_detector"

    // Polls immersive mode every 500ms while the activity is resumed.
    // Needed on ColorOS (Oppo/OnePlus) where the bars can come back after
    // dialogs, keyboard, or notification interactions.
    private val immersiveHandler = Handler(Looper.getMainLooper())
    private val immersiveRunnable = object : Runnable {
        override fun run() {
            applyImmersiveMode()
            immersiveHandler.postDelayed(this, 500)
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Let the Flutter surface extend under the system bars.
        WindowCompat.setDecorFitsSystemWindows(window, false)
        window.addFlags(WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS)

        // Apply cutout mode programmatically — theme-based value in
        // styles.xml doesn't take effect on Android 10/11 because Flutter
        // swaps the activity theme AFTER the window is created.
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            val lp = window.attributes
            lp.layoutInDisplayCutoutMode =
                WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_ALWAYS
            window.attributes = lp
        }

        applyImmersiveMode()
    }

    override fun onResume() {
        super.onResume()
        immersiveHandler.post(immersiveRunnable)
    }

    override fun onPause() {
        super.onPause()
        immersiveHandler.removeCallbacks(immersiveRunnable)
    }

    override fun onWindowFocusChanged(hasFocus: Boolean) {
        super.onWindowFocusChanged(hasFocus)
        if (hasFocus) applyImmersiveMode()
    }

    private fun applyImmersiveMode() {
        WindowCompat.setDecorFitsSystemWindows(window, false)
        WindowInsetsControllerCompat(window, window.decorView).apply {
            hide(WindowInsetsCompat.Type.systemBars())
            hide(WindowInsetsCompat.Type.displayCutout())
            systemBarsBehavior =
                WindowInsetsControllerCompat.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE
        }
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

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
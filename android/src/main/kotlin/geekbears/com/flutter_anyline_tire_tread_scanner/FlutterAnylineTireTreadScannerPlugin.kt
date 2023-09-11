package geekbears.com.flutter_anyline_tire_tread_scanner

import android.app.Activity.RESULT_OK
import android.content.Intent
import geekbears.com.flutter_anyline_tire_tread_scanner.activities.ScannerActivity
import io.anyline.tiretread.sdk.AnylineTireTreadSdk
import io.anyline.tiretread.sdk.SdkInitializeFailedException
import io.anyline.tiretread.sdk.getTreadDepthReportResult
import io.anyline.tiretread.sdk.types.TreadDepthResult

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry

/** FlutterAnylineTireTreadScannerPlugin **/
class FlutterAnylineTireTreadScannerPlugin : FlutterPlugin, ActivityAware, MethodCallHandler,
    EventChannel.StreamHandler, PluginRegistry.ActivityResultListener {
    private val METHOD_CHANNEL_NAME: String = "geekbears.com/flutter_anyline_tire_tread_scanner"
    private val EVENT_CHANNEL_NAME: String =
        "geekbears.com/flutter_anyline_tire_tread_scanner/events"
    private val SCANNER_REQUEST_CODE = 100;

    private lateinit var methodChannel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private var activityPluginBinding: ActivityPluginBinding? = null
    private var eventSink: EventSink? = null

    /// FlutterPlugin

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel = MethodChannel(
            flutterPluginBinding.binaryMessenger,
            METHOD_CHANNEL_NAME
        )
        eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, EVENT_CHANNEL_NAME)
        methodChannel.setMethodCallHandler(this)
        eventChannel.setStreamHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
        eventSink = null
    }

    /// MethodCallHandler

    @Suppress("UNCHECKED_CAST")
    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "setup" -> {
                setup(call.arguments as String, result)
            }
            "open" -> {
                open(call.arguments as String, result)
            }
            "getTreadDepthResult" -> {
                getTreadDepthResult(call.arguments as HashMap<String, Any>, result)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    /// EventChannel.StreamHandler

    override fun onListen(arguments: Any?, events: EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    /// ActivityAware

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activityPluginBinding = binding
        binding.addActivityResultListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        this.onDetachedFromActivity()
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        this.onAttachedToActivity(binding)
    }

    override fun onDetachedFromActivity() {
        activityPluginBinding?.removeActivityResultListener(this)
        activityPluginBinding = null
    }

    /// PluginRegistry.ActivityResultListener

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        when (requestCode) {
            SCANNER_REQUEST_CODE -> {
                if (resultCode == RESULT_OK && data != null && data.extras != null && eventSink != null) {
                    val event: String = data.extras!!.getString("event")!!
                    val uuid: String? = data.extras!!.getString("uuid")
                    val error: String? = data.extras!!.getString("error")

                    val fData = hashMapOf<String, Any?>(
                        "event" to event,
                        "uuid" to uuid,
                        "error" to error,
                    )

                    eventSink!!.success(fData)
                    return true
                }
            }
        }

        return false
    }

    /// FlutterAnylineTireTreadScannerPlugin methods used through MethodChannel

    /**
     * This must be called before doing anything else with the AnylineTireTreadSdk.
     *
     * It only needs to be called once during your application life-cycle.
     */
    private fun setup(licenseKey: String, result: Result) {
        try {
            if (activityPluginBinding == null) {
                return result.error("FlutterAnylineTireTreadNotAttachedToActivity", "Plugin is not attached to main activity", null,)
            }

            AnylineTireTreadSdk.init(
                licenseKey,
                activityPluginBinding!!.activity,
            )

            return result.success(null)
        } catch (e: SdkInitializeFailedException) {
            return result.error("SdkInitializeFailedException", e.message, e.localizedMessage,)
        } catch (e: Exception) {
            return result.error("FlutterAnylineTireTreadSetupError", e.message, e.localizedMessage,)
        }
    }

    private fun open(measurementSystem: String, result: Result) {
        try {
            val intent = Intent(activityPluginBinding!!.activity.applicationContext, ScannerActivity::class.java)
            intent.addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
            intent.putExtra("measurementSystem", measurementSystem);
            activityPluginBinding!!.activity.startActivityForResult(intent, SCANNER_REQUEST_CODE)


            return result.success(null)
        } catch (e: Exception) {
            result.error("FlutterAnylineTireTreadOpenError", e.message, e.localizedMessage,)
        }
    }

    private fun getTreadDepthResult(arguments: HashMap<String, Any>, result: Result) {
        try {
            val uuid = arguments["uuid"].toString()
            val measurementSystem = arguments["measurementSystem"].toString()

            val measurementResult : TreadDepthResult? = AnylineTireTreadSdk
                .getTreadDepthReportResult(
                    uuid,
                    onGetTreadDepthReportResultFailed = { http, exception ->
                        // Handle failure
                        result.error("FlutterAnylineTireTreadGetTreadDepthReportResultFailed", exception.message, exception.localizedMessage)
                    }
                )

            if (measurementResult != null) {
                val data: HashMap<String, Any> = hashMapOf(
                    "uuid" to uuid,
                    "measurementResult" to hashMapOf(
                        "topTire" to if (measurementSystem == "imperial") measurementResult.global.valueInch else measurementResult.global.valueMm,
                        "leftTire" to if (measurementResult.regions[0].isAvailable) if (measurementSystem == "imperial") measurementResult.regions[0].valueInch else measurementResult.regions[0].valueMm else null,
                        "middleTire" to if (measurementResult.regions[1].isAvailable) if (measurementSystem == "imperial") measurementResult.regions[1].valueInch else measurementResult.regions[1].valueMm else null,
                        "rightTire" to if (measurementResult.regions[2].isAvailable) if (measurementSystem == "imperial") measurementResult.regions[2].valueInch else measurementResult.regions[2].valueMm else null,
                    )
                )

                // Return measurement result data
                return result.success(data)
            }

            return result.success(null)
        } catch (e: Exception) {
            return result.error("FlutterAnylineTireTreadGetTreadDepthReportResultFailed", e.message, e.localizedMessage,)
        }
    }
}
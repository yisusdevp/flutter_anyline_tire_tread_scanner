package geekbears.com.flutter_anyline_tire_tread_scanner.activities

import android.content.Intent
import android.content.pm.ActivityInfo
import android.content.res.ColorStateList
import android.graphics.drawable.GradientDrawable
import android.os.Bundle
import android.view.View
import android.widget.Button
import android.widget.ProgressBar
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import androidx.compose.ui.platform.ViewCompositionStrategy
import geekbears.com.flutter_anyline_tire_tread_scanner.R
import io.anyline.tiretread.sdk.scanner.DistanceStatus
import io.anyline.tiretread.sdk.scanner.MeasurementSystem
import io.anyline.tiretread.sdk.scanner.TireTreadScanView
import io.anyline.tiretread.sdk.scanner.TireTreadScanViewCallback
import io.anyline.tiretread.sdk.scanner.TireTreadScanner
import io.anyline.tiretread.sdk.utils.inchStringToTriple
import io.anyline.tiretread.sdk.utils.inchToFractionString
import java.util.Timer
import kotlin.concurrent.schedule


class ScannerActivity() : AppCompatActivity(), TireTreadScanViewCallback {

    private val maxScanDuration = 10
    private val scanTimer : Timer = Timer()
    private var abortButtonDrawable: GradientDrawable = GradientDrawable()
    private var scanButtonDrawable: GradientDrawable = GradientDrawable()
    private var isUploading: Boolean = false

    private lateinit var measurementSystem: MeasurementSystem
    private lateinit var tireTreadScanView: TireTreadScanView
    private lateinit var scanButton: Button
    private lateinit var abortButton: Button
    private lateinit var distanceTextView: TextView
    private lateinit var progressBar: ProgressBar

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        requestedOrientation = ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE;
        setContentView(R.layout.activity_flutter_anyline_tire_tread_scanner)

        measurementSystem =
            if (intent.extras!!.getString("measurementSystem") == "imperial") MeasurementSystem.Imperial else MeasurementSystem.Metric

        // TireTreadScanView
        tireTreadScanView = findViewById(R.id.tireTreadScanView)
        tireTreadScanView.scanViewCallback = this
        tireTreadScanView.setViewCompositionStrategy(
            ViewCompositionStrategy.DisposeOnLifecycleDestroyed(
                this
            )
        )


        // ScanButton
        scanButton = findViewById(R.id.btnScan)
        scanButtonDrawable.cornerRadii = floatArrayOf(36F, 36F, 0F, 36F, 36F, 0F, 36F, 36F)
        scanButtonDrawable.color = ColorStateList.valueOf(resources.getColor(R.color.gray))
        scanButton.background = scanButtonDrawable

        // AbortButton
        abortButton = findViewById(R.id.btnAbort)
        abortButtonDrawable.cornerRadii = floatArrayOf(0F, 36F, 36F, 36F, 36F, 36F, 36F, 0F)
        abortButtonDrawable.color = ColorStateList.valueOf(resources.getColor(R.color.blue))
        abortButton.background = abortButtonDrawable

        // DistanceView
        distanceTextView = findViewById(R.id.tvDistance)

        // ProgressBar
        progressBar = findViewById(R.id.pbProgress)

        scanButton.setOnClickListener(::onClickedBtnScan)
        abortButton.setOnClickListener(::onClickedBtnAbort)
    }

    /// TireTreadScanViewCallback
    override fun onScanStart(uuid: String?) {
        super.onScanStart(uuid)

        scanButton.text = "Stop"
        progressBar.visibility = View.VISIBLE
        progressBar.max = maxScanDuration
        progressBar.progress = 0

        scanTimer.schedule(1000, 1000) { progressBar.progress += 1 }
    }

    override fun onScanStop(uuid: String?) {
        super.onScanStop(uuid)

        scanButton.text = "Scan"
        scanTimer.cancel()
    }

    override fun onFocusFound(uuid: String?) {
        super.onFocusFound(uuid)

        scanButton.isEnabled = true
        scanButtonDrawable.color = ColorStateList.valueOf(resources.getColor(R.color.blue))
        scanButton.setTextColor(ColorStateList.valueOf(resources.getColor(R.color.white)))
    }

    override fun onDistanceChanged(
        uuid: String?,
        previousStatus: DistanceStatus,
        newStatus: DistanceStatus,
        previousDistance: Float,
        newDistance: Float
    ) {
        super.onDistanceChanged(uuid, previousStatus, newStatus, previousDistance, newDistance)

        if (isUploading) {
            return
        }

        val parsedDistance: String = if (measurementSystem == MeasurementSystem.Imperial) {
            "${inchStringToTriple(inchToFractionString(newDistance.toDouble())).first}"
        } else {
            "${(newDistance / 10).toInt()}"
        }

        when (newStatus) {
            DistanceStatus.CLOSE, DistanceStatus.TOO_CLOSE -> {
                distanceTextView.text = "Increase Distance: $parsedDistance"
                distanceTextView.setTextColor(ColorStateList.valueOf(resources.getColor(R.color.white)))
            }

            DistanceStatus.FAR, DistanceStatus.TOO_FAR -> {
                distanceTextView.text = "Decrease Distance: $parsedDistance"
                distanceTextView.setTextColor(ColorStateList.valueOf(resources.getColor(R.color.white)))
            }

            DistanceStatus.OK -> {
                distanceTextView.text = "Distance OK"
                distanceTextView.setTextColor(ColorStateList.valueOf(resources.getColor(R.color.green)))
            }

            else -> {
                distanceTextView.text = "Trying to set the focus point, please focus on the middle of the running surface"
                distanceTextView.setTextColor(ColorStateList.valueOf(resources.getColor(R.color.white)))
            }
        }
    }

    override fun onImageUploaded(uuid: String?, uploaded: Int, total: Int) {
        super.onImageUploaded(uuid, uploaded, total)

        if (scanButton.isEnabled) {
            scanButton.isEnabled = false
            scanButtonDrawable.color = ColorStateList.valueOf(resources.getColor(R.color.gray))
            scanButton.setTextColor(ColorStateList.valueOf(resources.getColor(R.color.silver)))
        }

        if (!isUploading) {
            isUploading = true
            distanceTextView.text = "Uploading, please do not move the camera"
            distanceTextView.setTextColor(ColorStateList.valueOf(resources.getColor(R.color.white)))
        }
    }

    override fun onUploadCompleted(uuid: String?) {
        super.onUploadCompleted(uuid)
        progressBar.visibility = View.GONE
        setActivityResultExtras(uuid, "upload-completed", null)

        finish()
    }

    override fun onUploadFailed(uuid: String?, exception: Exception) {
        super.onUploadFailed(uuid, exception)
        setActivityResultExtras(uuid, "upload-failed", exception)

        finish()
    }

    override fun onUploadAborted(uuid: String?) {
        super.onUploadAborted(uuid)
        setActivityResultExtras(uuid, "upload-aborted", null)

        finish()
    }

    override fun onScanAbort(uuid: String?) {
        super.onScanAbort(uuid)
        setActivityResultExtras(uuid, "scan-aborted", null)

        finish()
    }

    private fun onClickedBtnScan(view: View) {
        if (!TireTreadScanner.instance.isScanning) {
            // Start scanning
            TireTreadScanner.instance.startScanning()
        } else {
            // Stop scanning
            TireTreadScanner.instance.stopScanning()
        }
    }

    private fun onClickedBtnAbort(view: View) {
        TireTreadScanner.instance.abortScanning()

        finish()
    }

    private fun setActivityResultExtras(uuid: String?, event: String, exception: Exception?) {
        val resultIntent = Intent()
        resultIntent.putExtra("uuid", uuid)
        resultIntent.putExtra("event", event)
        resultIntent.putExtra("error", exception?.localizedMessage)
        setResult(RESULT_OK, resultIntent)
    }
}
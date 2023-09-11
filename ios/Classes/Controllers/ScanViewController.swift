import Foundation
import UIKit
import AnylineTireTreadSdk

class ScanViewController: UIViewController, ScannerViewControllerHolder {
    var dismissViewController: (() -> Void)?
    
    var scannerViewController: UIViewController?
    
    var measurementSystem: String = ""
    
    var onTreadScannerEvent: ((String, String?, KotlinException?) -> (Void))?
    
    private var scanTimer: Timer?
    private var progress: Float = 0
    private let totalTime = 10.0 // Total time for scanning
    private let interval = 0.1 // Time interval to update progressView
    private let scanProgress = ScanProgress()
    private let abortButton = AbortButton()
    private let scanButton = ScanButton()
    private let distanceStatusLabel = DistanceStatusLabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.setupTireTreadScanView()
        
        scanProgress.layer.frame = CGRect(x: 100, y: 10, width: self.view.bounds.size.width - 200, height: 10)
        scanProgress.isHidden = true
        
        abortButton.frame = CGRect(x: 0, y: 30, width: 160, height: 50)
        abortButton.addTarget(self, action: #selector(onAbort), for: .touchUpInside)
        
        scanButton.frame = CGRect(x: self.view.bounds.size.width - 160, y: 30, width: 160, height: 50)
        scanButton.addTarget(self, action: #selector(onScan), for: .touchUpInside)
        
        distanceStatusLabel.frame = CGRect(x: 0, y: self.view.bounds.size.height - 65, width: self.view.bounds.size.width, height: 65)
        
        self.view.addSubview(scanProgress)
        self.view.addSubview(abortButton)
        self.view.addSubview(scanButton)
        self.view.addSubview(distanceStatusLabel)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if #available(iOS 16.0, *) {
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            windowScene?.requestGeometryUpdate(.iOS(interfaceOrientations: .landscape))
        } else {
            UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
        }
    }

    override var shouldAutorotate: Bool {
            return false
        }

    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .landscapeRight
    }
    
    @objc func onAbort(sender: UIButton!) {
        TireTreadScanner.companion.instance.abortScanning()
        
        self.dismiss(animated: true)
    }
    
    @objc func onScan(sender: UIButton!) {
        if TireTreadScanner.companion.isInitialized {
            if (TireTreadScanner.companion.instance.isScanning) {
                stopScanning()
            } else {
                startScanning()
            }
        }
    }
    
    @objc func updateScanProgress() {
            // Update the progress
            progress += Float(interval / totalTime)
            scanProgress.progress = progress
            
            // Check if the scanning process is completed
            if progress >= 1.0 {
                // Stop the timer
                scanTimer?.invalidate()
                scanTimer = nil
            }
        }
    
    private func startScanning() {
        TireTreadScanner.companion.instance.startScanning()
        scanButton.setTitle("Stop", for: .normal)
    }
    
    private func stopScanning() {
        TireTreadScanner.companion.instance.stopScanning()
        scanButton.setTitle("Scan", for: .normal)
    }
}

private extension ScanViewController {
    private func setupTireTreadScanView() {

        let config = TireTreadScanViewConfig(
            measurementSystem: measurementSystem == "metric" ? .metric : .imperial,
            useDefaultUi: false,
            useDefaultHaptic: false
        )

        // creates a TireTreadScannerViewController. You can later refer to it here
        // as self.scannerViewController.
        TireTreadScanViewKt.TireTreadScanView(context: UIViewController(), config: config, callback: self) { [weak self] error in
            self?.dismiss(animated: true)
        }

        self.dismissViewController = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        addScanViewControllerAsChild()
    }

    private func addScanViewControllerAsChild() {
        guard let scannerViewController = scannerViewController else {
            return
        }
        addChild(scannerViewController)
        view.addSubview(scannerViewController.view)
        scannerViewController.didMove(toParent: self)
    }
}

extension ScanViewController: TireTreadScanViewCallback {
    
    func onScanStart(uuid: String?) {
        self.scanProgress.isHidden = false
        self.scanTimer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(updateScanProgress), userInfo: nil, repeats: true)
    }
    
    func onScanStop(uuid: String?) {
        self.scanProgress.isHidden = true
        self.scanProgress.progress = 0.0
        self.scanTimer?.invalidate()
    }
    
    func onImageUploaded(uuid: String?, uploaded: Int32, total: Int32) {
        if (scanButton.isEnabled) {
            scanButton.isEnabled = false
            scanButton.backgroundColor = UIColor(rgb: 0xE1E1E1)
            scanButton.setTitleColor(UIColor(rgb: 0xBFBFBF), for: .normal)
        }
        
        self.distanceStatusLabel.text = "Uploading your photo, please wait..."
    }

    func onScanAbort(uuid: String?) {
        self.onTreadScannerEvent!("scan-aborted", uuid, nil)
        self.dismiss(animated: true)
    }

    func onUploadAborted(uuid: String?) {
        self.onTreadScannerEvent!("upload-aborted", uuid, nil)
        self.dismiss(animated: true)
    }

    
    func onFocusFound(uuid: String?) {
        if (!self.scanButton.isEnabled) {
            self.scanButton.isEnabled = true
            self.scanButton.setTitleColor(UIColor.white, for: .normal)
            self.scanButton.backgroundColor = UIColor(rgb: 0x0BA9C6)
        }
    }
    
    func onUploadCompleted(uuid: String?) {
        self.onTreadScannerEvent!("upload-completed", uuid, nil)
        self.dismiss(animated: true)
    }
    
    func onUploadFailed(uuid: String?, exception: KotlinException) {
        self.onTreadScannerEvent!("upload-failed", uuid, exception)
        self.dismiss(animated: true)
    }
    
    /// Called when the distance has changed.
    ///
    /// - Parameters:
    ///   - uuid: The UUID associated with the distance change.
    ///   - previousStatus: The previous distance status.
    ///   - newStatus: The new distance status.
    ///   - previousDistance: The previous distance value.
    ///   - newDistance: The new distance value.
    ///
    /// Note: The distance values are provided in millimeters if the metric system is selected (`UserDefaultsManager.shared.imperialSystem = false`), and in inches if the imperial system is selected (`UserDefaultsManager.shared.imperialSystem = true`).
    func onDistanceChanged(uuid: String?, previousStatus: DistanceStatus, newStatus: DistanceStatus, previousDistance: Float, newDistance: Float) {
         if Int(newDistance) != Int(previousDistance) {
             let distance = measurementSystem != "metric" ? (newDistance * 2.54) : (newDistance / 10.0)
             DispatchQueue.main.async { [weak self] in
                 switch newStatus {
                 case DistanceStatus.ok:
                     self?.distanceStatusLabel.text = "Distance Ok: \(distance)"
                     self?.distanceStatusLabel.textColor = UIColor.green
                     break
                 case DistanceStatus.far, DistanceStatus.tooFar:
                     self?.distanceStatusLabel.text = "Increase Distance: \(distance)"
                     self?.distanceStatusLabel.textColor = UIColor.white
                     break
                 case DistanceStatus.close, DistanceStatus.tooClose:
                     self?.distanceStatusLabel.text = "Decrease Distance: \(distance)"
                     self?.distanceStatusLabel.textColor = UIColor.white
                     break
                 default:
                     self?.distanceStatusLabel.text = "Trying to set the focus point, please focus on the middle of the running surface"
                     self?.distanceStatusLabel.textColor = UIColor.white
                     break
                 }
             }
         }
    }
}

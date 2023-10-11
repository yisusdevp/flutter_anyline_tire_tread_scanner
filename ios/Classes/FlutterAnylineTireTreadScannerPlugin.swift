import Flutter
import UIKit
import AnylineTireTreadSdk
import AVFoundation

public class FlutterAnylineTireTreadScannerPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
    
    private var eventSink: FlutterEventSink?
    
    /// FlutterPlugin
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "geekbears.com/flutter_anyline_tire_tread_scanner",
            binaryMessenger: registrar.messenger()
        )
        
        let eventChannel = FlutterEventChannel(
            name: "geekbears.com/flutter_anyline_tire_tread_scanner/events",
            binaryMessenger: registrar.messenger()
        )
        
        let instance = FlutterAnylineTireTreadScannerPlugin()
        
        eventChannel.setStreamHandler(instance)
        registrar.addMethodCallDelegate(instance, channel: channel)
  }
  
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "setup":
            self.setup(licenseKey: call.arguments as! String, result: result)
            break
        case "open":
            self.open(measurementSystem: call.arguments as! String, result: result)
            break
        case "getTreadDepthResult":
            self.getTreadDepthResult(arguments: call.arguments as! Dictionary<String, Any?>, result: result)
        default:
            result(FlutterMethodNotImplemented)
    }
  }
    
    /// FlutterStreamHandler
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }

    /// FlutterAnylineTireTreadScannerPlugin methods used through MethodChannel
    private func setup(licenseKey: String, result: FlutterResult) -> Void {
   do {
      try AnylineTireTreadSdk.companion.doInit(
        licenseKey: licenseKey,
        context: UIApplication.shared.delegate?.window??.rootViewController
      )

      result(nil)
    } catch {
      result(
        FlutterError(
          code: "FlutterAnylineTireTreadSetupError",
          message: "\(error)",
          details: nil
        )
      )
    }
  }

    private func open(measurementSystem: String, result: FlutterResult) -> Void {
        let scanViewController = ScanViewController()
        scanViewController.modalPresentationStyle = .fullScreen
        scanViewController.measurementSystem = measurementSystem
        scanViewController.onTreadScannerEvent = { (event: String, uuid: String?, exception: KotlinException?) in
            if (self.eventSink != nil) {
                let data: [String : Any?] = [
                          "event": event,
                          "uuid": uuid,
                          "error": exception?.message,
                        ]
                
                self.eventSink!(data)
            }
        }

        if let flutterViewController = UIApplication.shared.delegate?.window??.rootViewController as? FlutterViewController {
            flutterViewController.present(scanViewController, animated: true)
        }
        
        result(nil)
  }
    
    private func getTreadDepthResult(arguments: Dictionary<String, Any?>, result: @escaping FlutterResult) -> Void {
        do {
            let uuid = arguments["uuid"] as! String
            let measurementSystem = arguments["measurementSystem"] as! String
            
            try AnylineTireTreadSdk.companion.getTreadDepthReportResult(
                measurementUuid: uuid,
                onGetTreadDepthReportResultSucceed: { [weak self] response in
                    response.body { resultDTO, error in
                        guard let self = self else { return }
                        guard let status = resultDTO?.measurement.status else {
                            result(
                              FlutterError(
                                code: "FlutterAnylineTireTreadGetTreadDepthReportResultFailed",
                                message: "\(error)",
                                details: nil
                              )
                            )
                            return
                        }

                        if (resultDTO?.result == nil) {
                          result(nil)
                          return
                        }

                        let measurementResult: TreadDepthResultDTO = resultDTO!.result!
                        
                        var topTireTreadValue: Float
                        var leftTireTreadValue: Float?
                        var middleTireTreadValue: Float?
                        var rightTireTreadValue: Float?
                        
                        topTireTreadValue = Float(measurementSystem == "imperial" ? measurementResult.global.valueInch : measurementResult.global.valueMm)

                        if measurementResult.regions[0].available {
                            leftTireTreadValue = Float(measurementSystem == "imperial" ?
                                measurementResult.regions[0].valueInch : measurementResult.regions[0].valueMm)
                        }

                        if measurementResult.regions[1].available {
                            middleTireTreadValue = Float(measurementSystem == "imperial" ?
                                measurementResult.regions[1].valueInch : measurementResult.regions[1].valueMm)
                        }

                        if measurementResult.regions[2].available {
                            rightTireTreadValue = Float(measurementSystem == "imperial" ?
                                measurementResult.regions[2].valueInch : measurementResult.regions[2].valueMm)
                        }
                        
                        let data: [String : Any?] = [
                                  "uuid": uuid,
                                  "measurementResult": [
                                    "topTire": topTireTreadValue,
                                    "leftTire": leftTireTreadValue,
                                    "middleTire": middleTireTreadValue,
                                    "rightTire": rightTireTreadValue,
                                  ],
                                ]
                        
                        result(data)
                    }
                },
                onGetTreadDepthReportResultFailed: { [weak self] response, exception in
                    result(
                      FlutterError(
                        code: "FlutterAnylineTireTreadGetTreadDepthReportResultFailed",
                        message: "\(exception)",
                        details: nil
                      )
                    )
                }
            )
        } catch {
            result(
              FlutterError(
                code: "FlutterAnylineTireTreadGetTreadDepthResultError",
                message: "\(error)",
                details: nil
              )
            )
        }
    }
}

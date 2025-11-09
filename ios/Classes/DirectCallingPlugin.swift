import Flutter
import UIKit

public class DirectCallingPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "direct_calling", binaryMessenger: registrar.messenger())
        let instance = DirectCallingPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "makeCall":
            guard let args = call.arguments as? [String: Any],
                  let phoneNumber = args["phoneNumber"] as? String else {
                result(FlutterError(code: "INVALID_NUMBER", message: "Phone number cannot be empty", details: nil))
                return
            }
            makePhoneCall(phoneNumber: phoneNumber, result: result)
            
        case "checkPermission":
            // On iOS, tel: URLs don't require special permissions
            // We check if the device can make phone calls
            result(canMakePhoneCalls())
            
        case "requestPermission":
            // On iOS, tel: URLs don't require special permissions
            // We just check if the device can make phone calls
            result(canMakePhoneCalls())
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func makePhoneCall(phoneNumber: String, result: @escaping FlutterResult) {
        // Clean phone number
        let cleanedNumber = cleanPhoneNumber(phoneNumber)
        
        if cleanedNumber.isEmpty {
            result(FlutterError(code: "INVALID_NUMBER", message: "Invalid phone number", details: nil))
            return
        }
        
        // Create tel: URL
        guard let phoneURL = URL(string: "tel:\(cleanedNumber)") else {
            result(FlutterError(code: "INVALID_NUMBER", message: "Invalid phone number format", details: nil))
            return
        }
        
        // Check if device can make phone calls
        guard UIApplication.shared.canOpenURL(phoneURL) else {
            result(FlutterError(code: "NOT_SUPPORTED", message: "Device cannot make phone calls", details: nil))
            return
        }
        
        // Open Phone app with the number
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(phoneURL, options: [:]) { success in
                if success {
                    result(true)
                } else {
                    result(FlutterError(code: "CALL_FAILED", message: "Failed to open Phone app", details: nil))
                }
            }
        } else {
            // Fallback for iOS 9 and earlier
            let opened = UIApplication.shared.openURL(phoneURL)
            if opened {
                result(true)
            } else {
                result(FlutterError(code: "CALL_FAILED", message: "Failed to open Phone app", details: nil))
            }
        }
    }
    
    private func canMakePhoneCalls() -> Bool {
        // Check if device can make phone calls by testing tel: URL scheme
        if let phoneURL = URL(string: "tel://") {
            return UIApplication.shared.canOpenURL(phoneURL)
        }
        return false
    }
    
    private func cleanPhoneNumber(_ phoneNumber: String) -> String {
        // Remove all characters except digits, +, and *
        let allowedCharacters = CharacterSet(charactersIn: "+*0123456789")
        return phoneNumber.unicodeScalars.filter { allowedCharacters.contains($0) }.map(String.init).joined()
    }
}


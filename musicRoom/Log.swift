//
//  Log.swift
//  musicRoom
//
//  Created by Marco BOOTH on 8/10/17.
//  Copyright © 2017 Marco BOOTH. All rights reserved.
//

import Foundation

class Log {
    static var platform = "iOS"
    static var version : String?
    static var device : String?
    static var defaultInfoCached: [String: String]?
    
    static func defaultInfo() -> [String: String] {
        if self.device == nil {
            var sysInfo = utsname()
            uname(&sysInfo)
            let machine = Mirror(reflecting: sysInfo.machine)
            let identifier = machine.children.reduce("") { identifier, element in
                guard let value = element.value as? Int8, value != 0 else { return identifier }
                return identifier + String(UnicodeScalar(UInt8(value)))
            }
            
            self.device = self.platformType(platform: identifier)
        }
        
        if self.version == nil {
            self.version = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        }
        
        return [
            "user_id": Auth.auth().currentUser?.uid ?? "unknown",
            "platform": self.platform,
            "version": self.version ?? "unknown",
            "device": self.device ?? "unknown"
        ]
    }

    static func event(_ name: String, parameters toAdd: [String: String]) {
        if self.defaultInfoCached == nil {
            self.defaultInfoCached = defaultInfo()
        }
        
        if var parameters = defaultInfoCached {
            for (key, value) in toAdd {
                parameters[key] = value
            }
            
            Analytics.logEvent(name, parameters: parameters)
        }
    }
    
    static func event(_ name: String) {
        self.event(name, parameters: [:])
    }

    static func platformType(platform : String) -> String {
        if platform.isEqual("iPhone1,1")  {
            return "iPhone 1G"
        }
        else if platform.isEqual("iPhone1,2"){
            return "iPhone 3G"
        }
        else if platform.isEqual("iPhone2,1"){
            return "iPhone 3GS"
        }
        else if platform.isEqual("iPhone3,1"){
            return "iPhone 4"
        }
        else if platform.isEqual("iPhone3,3"){
            return "Verizon iPhone 4"
        }
        else if platform.isEqual("iPhone4,1"){
            return "iPhone 4S"
        }
        else if platform.isEqual("iPhone5,1"){
            return "iPhone 5 (GSM)"
        }
        else if platform.isEqual("iPhone5,2"){
            return "iPhone 5 (GSM+CDMA)"
        }
        else if platform.isEqual("iPhone5,3"){
            return "iPhone 5c (GSM)"
        }
        else if platform.isEqual("iPhone5,4"){
            return "iPhone 5c (GSM+CDMA)"
        }
        else if platform.isEqual("iPhone6,1"){
            return "iPhone 5s (GSM)"
        }
        else if platform.isEqual("iPhone6,2"){
            return "iPhone 5s (GSM+CDMA)"
        }
        else if platform.isEqual("iPhone7,2"){
            return "iPhone 6"
        }
        else if platform.isEqual("iPhone7,1"){
            return "iPhone 6 Plus"
        }
        else if platform.isEqual("iPhone8,1"){
            return "iPhone 6s"
        }
        else if platform.isEqual("iPhone8,2"){
            return "iPhone 6s Plus"
        }
        else if platform.isEqual("iPhone8,4"){
            return "iPhone SE"
        }
        else if platform.isEqual("iPhone9,1"){
            return "iPhone 7"
        }
        else if platform.isEqual("iPhone9,2"){
            return "iPhone 7 Plus"
        }
        else if platform.isEqual("iPhone9,3"){
            return "iPhone 7"
        }
        else if platform.isEqual("iPhone9,4"){
            return "iPhone 7 Plus"
        }
        else if platform.isEqual("iPod1,1"){
            return "iPod Touch 1G"
        }
        else if platform.isEqual("iPod2,1"){
            return "iPod Touch 2G"
        }
        else if platform.isEqual("iPod3,1"){
            return "iPod Touch 3G"
        }
        else if platform.isEqual("iPod4,1"){
            return "iPod Touch 4G"
        }
        else if platform.isEqual("iPod5,1"){
            return "iPod Touch 5G"
        }
        else if platform.isEqual("iPad1,1"){
            return "iPad"
        }
        else if platform.isEqual("iPad2,1"){
            return "iPad 2 (WiFi)"
        }
        else if platform.isEqual("iPad2,2"){
            return "iPad 2 (GSM)"
        }
        else if platform.isEqual("iPad2,3"){
            return "iPad 2 (CDMA)"
        }
        else if platform.isEqual("iPad2,4"){
            return "iPad 2 (WiFi)"
        }
        else if platform.isEqual("iPad2,5"){
            return "iPad Mini (WiFi)"
        }
        else if platform.isEqual("iPad2,6"){
            return "iPad Mini (GSM)"
        }
        else if platform.isEqual("iPad2,7"){
            return "iPad Mini (GSM+CDMA)"
        }
        else if platform.isEqual("iPad3,1"){
            return "iPad 3 (WiFi)"
        }
        else if platform.isEqual("iPad3,2"){
            return "iPad 3 (GSM+CDMA)"
        }
        else if platform.isEqual("iPad3,3"){
            return "iPad 3 (GSM)"
        }
        else if platform.isEqual("iPad3,4"){
            return "iPad 4 (WiFi)"
        }
        else if platform.isEqual("iPad3,5"){
            return "iPad 4 (GSM)"
        }
        else if platform.isEqual("iPad3,6"){
            return "iPad 4 (GSM+CDMA)"
        }
        else if platform.isEqual("iPad4,1"){
            return "iPad Air (WiFi)"
        }
        else if platform.isEqual("iPad4,2"){
            return "iPad Air (Cellular)"
        }
        else if platform.isEqual("iPad4,3"){
            return "iPad Air"
        }
        else if platform.isEqual("iPad4,4"){
            return "iPad Mini 2G (WiFi)"
        }
        else if platform.isEqual("iPad4,5"){
            return "iPad Mini 2G (Cellular)"
        }
        else if platform.isEqual("iPad4,6"){
            return "iPad Mini 2G";
        }
        else if platform.isEqual("iPad4,7"){
            return "iPad Mini 3 (WiFi)"
        }
        else if platform.isEqual("iPad4,8"){
            return "iPad Mini 3 (Cellular)"
        }
        else if platform.isEqual("iPad4,9"){
            return "iPad Mini 3 (China)"
        }
        else if platform.isEqual("iPad5,3"){
            return "iPad Air 2 (WiFi)"
        }
        else if platform.isEqual("iPad5,4"){
            return "iPad Air 2 (Cellular)"
        }
        else if platform.isEqual("AppleTV2,1"){
            return "Apple TV 2G"
        }
        else if platform.isEqual("AppleTV3,1"){
            return "Apple TV 3"
        }
        else if platform.isEqual("AppleTV3,2"){
            return "Apple TV 3 (2013)"
        }
        else if platform.isEqual("i386"){
            return "Simulator"
        }
        else if platform.isEqual("x86_64"){
            return "Simulator"
        }
        return platform
    }
}

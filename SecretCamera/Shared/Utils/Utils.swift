//
//  Utils.swift
//  rhombus
//
//  Created by Hung on 3/11/17.
//  Copyright © 2017 originallyUS. All rights reserved.
//

import Foundation
import CoreTelephony

class Utils {
    static func matches(regex: String, in text: String) -> [String] {
        
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let nsString = text as NSString
            let results = regex.matches(in: text, range: NSRange(location: 0, length: nsString.length))
            return results.map { nsString.substring(with: $0.range)}
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    
    static func checkConnection() -> Bool {
        return Reachability.isConnectedToNetwork()
    }
    
    static func checkValidWith(regex: String, in text: String) -> Bool {
        let predicate = NSPredicate(format:"SELF MATCHES %@", regex)
        return predicate.evaluate(with: text)
    }
    
    static func getPathFileDocuments() -> URL {
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let dataPath = documentsDirectory.appendingPathComponent("MP3Files")
        if FileManager.default.fileExists(atPath: dataPath.path) == false {
            do {
                try FileManager.default.createDirectory(atPath: dataPath.absoluteString, withIntermediateDirectories: true, attributes: nil)
            } catch let error as NSError {
                print("Error creating directory: \(error.localizedDescription)")
            }
        }
        return dataPath
    }
    
    
    static func getFileURL(url: String) -> URL? {
        let documentPath = getPathFileDocuments()
        let filePath = (documentPath.path as NSString).appendingPathComponent(Utils.getFileNameFromURL(url: url))
        guard let fileURL = URL(string: "file://\(filePath)") else {
            return nil
        }
        
        return fileURL
    }
    
    static func getFileURLLocal(fileName: String) -> URL? {
        let documentPath = getPathFileDocuments()
        let filePath = (documentPath.path as NSString).appendingPathComponent(fileName)
        
        guard let fileURL = URL(string: "file://\(filePath)") else {
            return nil
        }
        
        return fileURL
    }
    
    static func getFileNameFromURL(url: String) -> String {
        let urlComponent = url as NSString
        
        //url should be of type URL
        let audioFileName = String(urlComponent.lastPathComponent)
        
        //        //path extension will consist of the type of file it is, m4a or mp4
        //        let pathExtension = audioFileName.pathExtension
        
        return audioFileName!
    }
    
    static func checkFileExist(fileName: String = "", urlString: String) -> Bool {
        let documentPath = getPathFileDocuments()
        var filePath = ""
        if fileName == "" {
            filePath = (documentPath.path as NSString).appendingPathComponent(Utils.getFileNameFromURL(url: urlString))
        }
        else {
            filePath = (documentPath.path as NSString).appendingPathComponent(fileName)
        }
        return FileManager.default.fileExists(atPath: filePath)
    }
    
    static func getUUIDDevice() -> NSString {
        if let uuID = getItemKeychain(identifier: "uuid", accessGroup: nil) {
            return (uuID as! NSString)
        } else {
            let cfuuid = CFUUIDCreate(nil)
            let uuid = CFUUIDCreateString(nil, cfuuid)
            if uuid != nil {
                saveItemKeychain(identifier: "uuid", accessGroup: nil, value: uuid!)
            }
            return (uuid != nil) ? (uuid! as NSString) : ""
            
        }
    }
    
    // MARK: Store
    // MARK: KeyChain
    static func getItemKeychain(identifier: String, accessGroup: String?) -> AnyObject? {
        let keychainItemWrapper = KeychainItemWrapper(identifier: identifier, accessGroup: accessGroup)
        return keychainItemWrapper[identifier]
    }
    
    static func saveItemKeychain(identifier: String, accessGroup: String?, value: AnyObject) {
        let keychainItemWrapper = KeychainItemWrapper(identifier: identifier, accessGroup: accessGroup)
        return keychainItemWrapper[identifier] = value
    }
    
    static func resetItemKeychain(identifier: String, accessGroup: String?) {
        let keychainItemWrapper = KeychainItemWrapper(identifier: identifier, accessGroup: accessGroup)
        keychainItemWrapper.resetKeychain()
    }
    
    // MARK: UserDefault
    static func getItemUserDefault(identifier: String) -> Any? {
        if let data = UserDefaults.standard.object(forKey: identifier) as? Data {
            return NSKeyedUnarchiver.unarchiveObject(with: data)
        }
        return nil
    }
    static func saveItemUserDefault(identifier: String, value: Any?) {
        if let value = value {
            let archiver = NSKeyedArchiver.archivedData(withRootObject: value)
            UserDefaults.standard.set(archiver, forKey: identifier)
        }
    }
    static func removeItemUserDefault(identifier: String) {
        UserDefaults.standard.removeObject(forKey: identifier)
    }
    
    static func getPhoneCode() -> String {
        let networkInfo = CTTelephonyNetworkInfo()
        let carrier = networkInfo.subscriberCellularProvider
        
        if let iso = carrier?.isoCountryCode {
            return self.getCountryPhoneCode(iso.uppercased())
        } else {
            return ""
        }
    }
    
    static func getCountryPhoneCode (_ country : String) -> String
    {
        var countryDictionary  = ["AF":"93",
                                  "AL":"355",
                                  "DZ":"213",
                                  "AS":"1",
                                  "AD":"376",
                                  "AO":"244",
                                  "AI":"1",
                                  "AG":"1",
                                  "AR":"54",
                                  "AM":"374",
                                  "AW":"297",
                                  "AU":"61",
                                  "AT":"43",
                                  "AZ":"994",
                                  "BS":"1",
                                  "BH":"973",
                                  "BD":"880",
                                  "BB":"1",
                                  "BY":"375",
                                  "BE":"32",
                                  "BZ":"501",
                                  "BJ":"229",
                                  "BM":"1",
                                  "BT":"975",
                                  "BA":"387",
                                  "BW":"267",
                                  "BR":"55",
                                  "IO":"246",
                                  "BG":"359",
                                  "BF":"226",
                                  "BI":"257",
                                  "KH":"855",
                                  "CM":"237",
                                  "CA":"1",
                                  "CV":"238",
                                  "KY":"345",
                                  "CF":"236",
                                  "TD":"235",
                                  "CL":"56",
                                  "CN":"86",
                                  "CX":"61",
                                  "CO":"57",
                                  "KM":"269",
                                  "CG":"242",
                                  "CK":"682",
                                  "CR":"506",
                                  "HR":"385",
                                  "CU":"53",
                                  "CY":"537",
                                  "CZ":"420",
                                  "DK":"45",
                                  "DJ":"253",
                                  "DM":"1",
                                  "DO":"1",
                                  "EC":"593",
                                  "EG":"20",
                                  "SV":"503",
                                  "GQ":"240",
                                  "ER":"291",
                                  "EE":"372",
                                  "ET":"251",
                                  "FO":"298",
                                  "FJ":"679",
                                  "FI":"358",
                                  "FR":"33",
                                  "GF":"594",
                                  "PF":"689",
                                  "GA":"241",
                                  "GM":"220",
                                  "GE":"995",
                                  "DE":"49",
                                  "GH":"233",
                                  "GI":"350",
                                  "GR":"30",
                                  "GL":"299",
                                  "GD":"1",
                                  "GP":"590",
                                  "GU":"1",
                                  "GT":"502",
                                  "GN":"224",
                                  "GW":"245",
                                  "GY":"595",
                                  "HT":"509",
                                  "HN":"504",
                                  "HU":"36",
                                  "IS":"354",
                                  "IN":"91",
                                  "ID":"62",
                                  "IQ":"964",
                                  "IE":"353",
                                  "IL":"972",
                                  "IT":"39",
                                  "JM":"1",
                                  "JP":"81",
                                  "JO":"962",
                                  "KZ":"77",
                                  "KE":"254",
                                  "KI":"686",
                                  "KW":"965",
                                  "KG":"996",
                                  "LV":"371",
                                  "LB":"961",
                                  "LS":"266",
                                  "LR":"231",
                                  "LI":"423",
                                  "LT":"370",
                                  "LU":"352",
                                  "MG":"261",
                                  "MW":"265",
                                  "MY":"60",
                                  "MV":"960",
                                  "ML":"223",
                                  "MT":"356",
                                  "MH":"692",
                                  "MQ":"596",
                                  "MR":"222",
                                  "MU":"230",
                                  "YT":"262",
                                  "MX":"52",
                                  "MC":"377",
                                  "MN":"976",
                                  "ME":"382",
                                  "MS":"1",
                                  "MA":"212",
                                  "MM":"95",
                                  "NA":"264",
                                  "NR":"674",
                                  "NP":"977",
                                  "NL":"31",
                                  "AN":"599",
                                  "NC":"687",
                                  "NZ":"64",
                                  "NI":"505",
                                  "NE":"227",
                                  "NG":"234",
                                  "NU":"683",
                                  "NF":"672",
                                  "MP":"1",
                                  "NO":"47",
                                  "OM":"968",
                                  "PK":"92",
                                  "PW":"680",
                                  "PA":"507",
                                  "PG":"675",
                                  "PY":"595",
                                  "PE":"51",
                                  "PH":"63",
                                  "PL":"48",
                                  "PT":"351",
                                  "PR":"1",
                                  "QA":"974",
                                  "RO":"40",
                                  "RW":"250",
                                  "WS":"685",
                                  "SM":"378",
                                  "SA":"966",
                                  "SN":"221",
                                  "RS":"381",
                                  "SC":"248",
                                  "SL":"232",
                                  "SG":"65",
                                  "SK":"421",
                                  "SI":"386",
                                  "SB":"677",
                                  "ZA":"27",
                                  "GS":"500",
                                  "ES":"34",
                                  "LK":"94",
                                  "SD":"249",
                                  "SR":"597",
                                  "SZ":"268",
                                  "SE":"46",
                                  "CH":"41",
                                  "TJ":"992",
                                  "TH":"66",
                                  "TG":"228",
                                  "TK":"690",
                                  "TO":"676",
                                  "TT":"1",
                                  "TN":"216",
                                  "TR":"90",
                                  "TM":"993",
                                  "TC":"1",
                                  "TV":"688",
                                  "UG":"256",
                                  "UA":"380",
                                  "AE":"971",
                                  "GB":"44",
                                  "US":"1",
                                  "UY":"598",
                                  "UZ":"998",
                                  "VU":"678",
                                  "WF":"681",
                                  "YE":"967",
                                  "ZM":"260",
                                  "ZW":"263",
                                  "BO":"591",
                                  "BN":"673",
                                  "CC":"61",
                                  "CD":"243",
                                  "CI":"225",
                                  "FK":"500",
                                  "GG":"44",
                                  "VA":"379",
                                  "HK":"852",
                                  "IR":"98",
                                  "IM":"44",
                                  "JE":"44",
                                  "KP":"850",
                                  "KR":"82",
                                  "LA":"856",
                                  "LY":"218",
                                  "MO":"853",
                                  "MK":"389",
                                  "FM":"691",
                                  "MD":"373",
                                  "MZ":"258",
                                  "PS":"970",
                                  "PN":"872",
                                  "RE":"262",
                                  "RU":"7",
                                  "BL":"590",
                                  "SH":"290",
                                  "KN":"1",
                                  "LC":"1",
                                  "MF":"590",
                                  "PM":"508",
                                  "VC":"1",
                                  "ST":"239",
                                  "SO":"252",
                                  "SJ":"47",
                                  "SY":"963",
                                  "TW":"886",
                                  "TZ":"255",
                                  "TL":"670",
                                  "VE":"58",
                                  "VN":"84",
                                  "VG":"284",
                                  "VI":"340"]
        if countryDictionary[country] != nil {
            return countryDictionary[country]!
        }
            
        else {
            return ""
        }
    }
    
    
    static func randomNumber<T : SignedInteger>(inRange range: ClosedRange<T> = 1...6) -> T {
        let length = (range.upperBound - range.lowerBound + 1).toIntMax()
        let value = arc4random().toIntMax() % length + range.lowerBound.toIntMax()
        return T(value)
    }
    
    static func configureNumberPhone(text: String?) -> String {
        guard let phoneText = text else {
            return ""
        }
        let numbers = matches(regex: Rex.onlyNumber, in: phoneText)
        let numberPhone = numbers.reduce("", +)
        
        return numberPhone
    }
    
}

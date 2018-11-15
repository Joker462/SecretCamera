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
        
        return audioFileName
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
            UserDefaults.standard.synchronize()
        }
    }
    static func removeItemUserDefault(identifier: String) {
        UserDefaults.standard.removeObject(forKey: identifier)
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

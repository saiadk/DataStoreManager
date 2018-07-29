//
//  CBMKeychianWrapper.swift
//  DataStorageManager
//
//  Created by Mangaraju, Venkata Maruthu Sesha Sai [GCB-OT NE] on 7/28/18.
//  Copyright © 2018 Sai. All rights reserved.
//

import Foundation
import Security


let SecValueData: String! = kSecValueData as String
let SecClass: String! = kSecClass as String
let SecAttrService: String! = kSecAttrService as String
let SecAttrAccessGroup: String! = kSecAttrAccessGroup as String
let SecAttrGeneric: String! = kSecAttrGeneric as String
let SecAttrAccount: String! = kSecAttrAccount as String
let SecReturnData: String! = kSecReturnData as String
let SecMatchLimit: String! = kSecMatchLimit as String
let SecAttrAccessible: String! = kSecAttrAccessible as String
let SecClassGenericPwd: String! = kSecClassGenericPassword as String
let SecClassInternetPwd: String! = kSecClassInternetPassword as String
let SecClassCertificate: String! = kSecClassCertificate as String
let SecClassKey: String! = kSecClassKey as String
let SecClassIdentity: String! = kSecClassIdentity as String
let SecReturnAttributes: String! = kSecReturnAttributes as String

public class KeychianWrapper {
    
    public static var keychainAccessGroup:String? = nil

    public static func setupSearchDirectoryForIdentifier(_ identifier:String)-> [String:Any] {
        
        var keychainQueryDictionary: [String:Any] = [SecClass:kSecClassGenericPassword]
        
        // Uniquely identify this keychain accessor
        keychainQueryDictionary[SecAttrService] = identifier
        
        // Set the keychain access group if defined
        keychainQueryDictionary[SecAttrAccessGroup] = keychainAccessGroup
        return keychainQueryDictionary
    }
    
    
    public static func searchKeychainCopyMatchingIdentifier(_ identifier:String)-> NSMutableDictionary? {
        
        var keychainQueryDictionary = self.setupSearchDirectoryForIdentifier(identifier)
        var result: AnyObject?
        
        // Limit search results to one
        keychainQueryDictionary[SecMatchLimit] = kSecMatchLimitOne
        
        // Specify we want Item attributes
        keychainQueryDictionary[SecReturnAttributes] = kCFBooleanTrue
        
        // Search
        let status = withUnsafeMutablePointer(to: &result) {
            SecItemCopyMatching(keychainQueryDictionary as CFDictionary, UnsafeMutablePointer($0))
        }
        return (status == noErr) ? (result as? NSMutableDictionary) : nil
        
    }
    
    public static func objectForIdentifier(_ identifier:String)-> Any? {
        
        var keychainObj:Any?
        if let valueData:NSMutableDictionary = self.searchKeychainCopyMatchingIdentifier(identifier) {
            if let data = valueData.object(forKey: SecAttrGeneric) as? Data {
                if let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as String? {
                    keychainObj =  string//NSString(data: valueData, encoding: NSUTF8StringEncoding) as? String ?? valueData
                }
                else {
                    keychainObj = data
                }
            }
            else if let string = valueData.object(forKey: SecAttrGeneric) as? String {
                keychainObj = string
            }
        }
        return keychainObj
        
    }
    
    
    public static func createKeychainItem(withValue value:Any, forIdentifier identifier:String, accessScope:KeyChainItemAccessScopeType)-> Bool {
        
        var keychainQueryDictionary = self.setupSearchDirectoryForIdentifier(identifier)
        
        var valueData: Data
        if let storeContent = value as? String
        {
            guard let data: Data = storeContent.data(using: String.Encoding.utf8) else {
                return false
            }
            valueData = data
        }
        else if let storeContent = value as? Data{
            valueData = storeContent
        }
        else
        {
            valueData = Data()
        }
        
        keychainQueryDictionary[SecAttrGeneric] = valueData
        
        // Protect the keychain entry so it's only valid when the device is unlocked.
        if accessScope != .none {
            keychainQueryDictionary[SecAttrAccessible] = accessScope.value()
        }
        
        // Add.
        let status:OSStatus = SecItemAdd(keychainQueryDictionary as CFDictionary, nil)
        
        // If the addition was successful, return. Otherwise, attempt to update existing key or quit (return NO).
        if (status == errSecSuccess) {
            return true
        } else if (status == errSecDuplicateItem){
            return self.updateKeychainItem(withValueData: valueData, forIdentifier: identifier)
        }
        return false
        
    }
    
    public static func updateKeychainItem(withValueData valueData:Data, forIdentifier identifier:String)-> Bool {
        let keyChainSearchDict = self.searchKeychainCopyMatchingIdentifier(identifier)
        
        guard let dictionary = keyChainSearchDict,var keychainQueryDictionary = NSDictionary(dictionary: dictionary) as? [String:AnyObject]
            else {
                return false
        }
        var status:OSStatus = -1
        keychainQueryDictionary[SecClass] = kSecClassGenericPassword
        let updateDictionary = [SecAttrGeneric: valueData]
        status = SecItemUpdate(keychainQueryDictionary as CFDictionary, updateDictionary as CFDictionary)
        return (status == errSecSuccess)
        
    }
    
    public static func deleteItemFromKeychainWithIdentifier(_ identifier:String) {
        
        let searchDictionary = self.setupSearchDirectoryForIdentifier(identifier)
        
        //Delete.
        SecItemDelete((searchDictionary as CFDictionary));
    }
    
    
    public static func resetAll(){
        
        let secItemClasses = [ SecClassGenericPwd, SecClassInternetPwd, SecClassCertificate, SecClassKey, SecClassIdentity]
        for secItemClass in secItemClasses {
            let keychainQueryDictionary: [String:Any] = [SecClass:secItemClass as Any]
            SecItemDelete(keychainQueryDictionary as CFDictionary);
        }
    }
    
}

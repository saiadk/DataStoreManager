//
//  Enums.swift
//  DataStoreManager
//
//  Created by Mangaraju, Venkata Maruthu Sesha Sai [GCB-OT NE] on 7/28/18.
//  Copyright © 2018 Sai. All rights reserved.
//

import Foundation

public enum DataItemScopeType: String{
    case session = "Session"
    case application = "Application"
}

public enum KeyChainItemAccessScopeType {
    
    @available(iOS 4.0, *)
    case whenUnlocked
    case afterFirstUnlock
    case always
    case whenUnlockedThisDeviceOnly
    case afterFirstUnlockThisDeviceOnly
    case alwaysThisDeviceOnly
    
    @available(iOS 8.0, *)
    case whenPasscodeSetThisDeviceOnly
    
    case none
    
    func value()-> CFString {
        
        switch self {
        case .whenUnlocked : return kSecAttrAccessibleWhenUnlocked
        case .afterFirstUnlock : return kSecAttrAccessibleAfterFirstUnlock
        case .always : return kSecAttrAccessibleAlways
        case .whenUnlockedThisDeviceOnly : return kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        case .afterFirstUnlockThisDeviceOnly : return kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        case .alwaysThisDeviceOnly : return kSecAttrAccessibleAlwaysThisDeviceOnly
        case .whenPasscodeSetThisDeviceOnly : return kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly
        case .none : return "" as CFString
        }
    }
}

public enum DataStoreType: String {
    
    case preferences
    case keychain
    case sharedStorage
    case inMemory
    case fileStorage
    case coredataStore
    
    //Computed Properties
    
    var model : Storable{
        switch self {
            case .preferences: return DataStoreManager.shared.userPreferencesDataStore
            case .keychain: return DataStoreManager.shared.keychainDataStore
            case .sharedStorage: return  DataStoreManager.shared.sharedDataStore
            case .inMemory: return  DataStoreManager.shared.inMemoryDataStore
            case .fileStorage: return DataStoreManager.shared.filesDataStore
            case .coredataStore: return DataStoreManager.shared.coreDataStore
        }
    }
}

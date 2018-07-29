//
//  DataStoreManager.swift
//  DataStorageManager
//
//  Created by Mangaraju, Venkata Maruthu Sesha Sai [GCB-OT NE] on 7/28/18.
//  Copyright © 2018 Sai. All rights reserved.
//

import UIKit
import WatchConnectivity

public struct DataStoreManager {
    
    lazy var userPreferencesDataStore:Storable = PreferencesDataStore()
    lazy var keychainDataStore:Storable = KeychainDataStore()
    lazy var sharedDataStore:Storable = SharedDataStore()
    lazy var inMemoryDataStore:Storable = InMemoryDataStore()
    lazy var filesDataStore:Storable = FilesDataStore()
    lazy var coreDataStore:Storable = CoreDataStore()

    /**
    Returns the singleton instance of the DataStoreManager
    
    :returns: singleton instance of DataStoreManager
    */
    public static var shared = DataStoreManager()
    
    
    /**
    ****************************    Data accessors    ****************************
    */
    
    @discardableResult public func storeDataItem(_ dataItem:DataItem, forKey key:String, storeType:DataStoreType)->Bool {
        /**
        *  dispatch_barrier_async() will wait for all previously scheduled getDataItem’s dispatch_sync and the storeDataItem's dispatch_barrier_async() operations to finish before executing itself.
        */
        return storeType.model.storeDataItem(dataItem, forKey: key)
    }
    

    public func getDataItem(forKey key:String, storeType:DataStoreType)->Any? {
        return storeType.model.getDataItem(forKey: key)
    }
    
    
    public func resetDataItems(withKeys keys:[String], storeType:DataStoreType){
        return storeType.model.resetDataItems(withKeys: keys)
    }

    
    public func resetAll(storeType:DataStoreType){
        return storeType.model.resetAll()
    }
 
    public func clearSessionScopeContents(){
        DataStoreManager.shared.inMemoryDataStore.clearSessionScopeContents()
    }

    
}


/**
****************************    Data accessor utils for value types    ****************************
*/

extension DataStoreManager {
    
    /**
    Converts a give struct type value to NSData to store in NSUserDefaults
    
    :param: content, contentType
    */
    
    public func getDataFromValueType<T>(contentValueType:T.Type, content:T) -> NSData{
        var content = content
        let dataPacket = NSData(bytes: &content, length: MemoryLayout<T>.size)
        #if DEBUG
            Log.debug( "getDataFromValueType", message: "\(dataPacket)")
        #endif
        return dataPacket
    }
    
    public func getValueTypeFromData<T>(contentValueType:T.Type, content:NSData)-> T?{
        
        var returnValue:T? = nil
        if content.length == MemoryLayout<T>.size {
            returnValue = UnsafeRawPointer(content.bytes).load(fromByteOffset: 0, as: contentValueType)
        } else {
            #if DEBUG
                Log.debug( "getValueTypeFromData", message: "Error: data size is incorrect")
            #endif
        }
        return returnValue
    }
    
}

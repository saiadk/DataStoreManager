//
//  KeychainDataStore.swift
//  DataStorageManager
//
//  Created by Mangaraju, Venkata Maruthu Sesha Sai [GCB-OT NE] on 7/28/18.
//  Copyright © 2018 Sai. All rights reserved.
//

import UIKit

struct KeychainDataStore: Storable {
    
//    private let dataContainer = KeychainAccess.self
    private let dataContainer = KeychianWrapper.self
    private let accessGroup:String? = nil
    private let DataQueue:DispatchQueue = DispatchQueue(label: "KeyChainDataQueue", attributes: DispatchQueue.Attributes.concurrent)

    @discardableResult func storeDataItem(_ dataItem:DataItem, forKey key:String) -> Bool{
        var isStored: Bool = false
        DataQueue.sync(flags: .barrier, execute: {
            isStored = self.dataContainer.createKeychainItem(withValue: dataItem.content, forIdentifier: key, accessScope:dataItem.keychianAccessScope)
        })
        return isStored
    }
    
    func getDataItem(forKey key:String) -> Any?{
        var objectToReturn:Any?
        DataQueue.sync(execute: { () -> Void in
            objectToReturn = self.dataContainer.objectForIdentifier(key)
        })
        return objectToReturn
    }
    
    func resetDataItems(withKeys keys:[String]){
        DataQueue.sync(flags: .barrier, execute: {
            for itemKey in keys {
                self.dataContainer.deleteItemFromKeychainWithIdentifier(itemKey)
            }
        })
    }
    
    func resetAll(){
      //Need to see how to remove all items in keychain
        DataQueue.sync(flags: .barrier, execute: {
            self.dataContainer.resetAll()
        })
    }
    
}

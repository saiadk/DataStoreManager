//
//  InMemoryDataStore.swift
//  DataStorageManager
//
//  Created by Mangaraju, Venkata Maruthu Sesha Sai [GCB-OT NE] on 7/28/18.
//  Copyright © 2018 Sai. All rights reserved.
//

import UIKit

class InMemoryDataStore: Storable {
    
    private var dataContainer = [String:DataItem]()
    private let DataQueue:DispatchQueue = DispatchQueue(label: "InMemoryDataQueue", attributes: DispatchQueue.Attributes.concurrent)
    
    
    @discardableResult func storeDataItem(_ dataItem:DataItem, forKey key:String) -> Bool{
        var isStored: Bool = false
        DataQueue.sync(flags: .barrier, execute: {
            self.dataContainer.updateValue(dataItem, forKey: key)
            isStored = true
        })
        return isStored
    }
    
    func getDataItem(forKey key:String) -> Any?{
        var objectToReturn:Any?
        DataQueue.sync(execute: { () -> Void in
            if let value = self.dataContainer[key]?.content {
                objectToReturn = value
            }
        })
        return objectToReturn
    }
    
    func resetDataItems(withKeys keys:[String]){
        DataQueue.sync(flags: .barrier, execute: {
            for key in keys {
                self.dataContainer.removeValue(forKey: key)
            }
        })
    }
    
    func resetAll(){
        DataQueue.sync(flags: .barrier, execute: {
            self.dataContainer.removeAll()
        })
    }
    
    //Clear session specific data items
    func clearSessionScopeContents(){
        let keysToRemove = self.dataContainer.keys.filter {
            if let dc = self.dataContainer[$0]{
                return dc.scope == .session
            }
            return false
        }
        //let keysToRemove = self.dataContainer.keys.filter { self.dataContainer[$0]!.scope == .Session}
        for keyToRemove in keysToRemove {
            self.dataContainer.removeValue(forKey: keyToRemove)
        }
    }
    
}

//
//  PreferencesDataStore.swift
//  DataStorageManager
//
//  Created by Mangaraju, Venkata Maruthu Sesha Sai [GCB-OT NE] on 7/28/18.
//  Copyright © 2018 Sai. All rights reserved.
//

import UIKit

struct PreferencesDataStore : Storable {
    
    private let dataContainer = UserDefaults.standard
    private let DataQueue:DispatchQueue = DispatchQueue(label: "PreferencesDataQueue", attributes: DispatchQueue.Attributes.concurrent)


    @discardableResult func storeDataItem(_ dataItem:DataItem, forKey key:String) -> Bool{
        DataQueue.sync(flags: .barrier, execute: {
            self.dataContainer.set(dataItem.content, forKey: key)
            self.dataContainer.synchronize()
        })
        return true
    }
    
    func getDataItem(forKey key:String) -> Any?{
        var content:Any?
        DataQueue.sync(execute: { () -> Void in
            content = self.dataContainer.object(forKey: key)
        })
        return content
    }
    
    func resetDataItems(withKeys keys:[String]){
        DataQueue.sync(flags: .barrier, execute: {
            for key in keys {
                self.dataContainer.removeObject(forKey: key)
            }
        })
    }
    
    func resetAll(){
        DataQueue.sync(flags: .barrier, execute: {
            if let domainName = Bundle.main.bundleIdentifier{
                UserDefaults.standard.removePersistentDomain(forName: domainName)
            }
        })
        
    }
}

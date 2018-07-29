//
//  SharedStorageDataModel.swift
//  DataStorageManager
//
//  Created by Mangaraju, Venkata Maruthu Sesha Sai [GCB-OT NE] on 7/28/18.
//  Copyright © 2018 Sai. All rights reserved.
//

import UIKit

struct SharedDataStore: Storable {
    
    //Stored Properties
    private let DataQueue:DispatchQueue = DispatchQueue(label: "SharedDataQueue", attributes: DispatchQueue.Attributes.concurrent)

    var dataContainerURL: URL {
        
        var availableCacheFolder = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.test")
        
        #if (arch(i386) || arch(x86_64))
            if (availableCacheFolder == nil) {
                do{
                    availableCacheFolder = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                }catch _ {
                    #if DEBUG
                    Log.debug( "dataContainerURL", message: "Documents directory access failed")
                    #endif
                }
            }
        #endif
        
        #if DEBUG
            return availableCacheFolder ?? URL(string: "")!
        #else
            return availableCacheFolder!
        #endif

    }
    
    
    //Initializers
    
    init(){
        //Create required directories in Documents
        self.checkAndCreateDataContainer()
    }
    
    
    //Data accessors

    @discardableResult func storeDataItem(_ dataItem:DataItem, forKey key:String) -> Bool{
        var isStored: Bool = true
        DataQueue.sync(flags: .barrier, execute: {
            let archivedObjectData = NSKeyedArchiver.archivedData(withRootObject: dataItem.content )
            let objArchiveURL = self.URLForKey(key)
            do {
                try archivedObjectData.write(to: objArchiveURL, options: NSData.WritingOptions.completeFileProtectionUntilFirstUserAuthentication)
                try (objArchiveURL as NSURL).setResourceValue(true, forKey:URLResourceKey.isExcludedFromBackupKey) // NSURLFileProtectionComplete
            } catch _{
                isStored = false
            }
        })
        
        return isStored
    }
    
    
    func getDataItem(forKey key:String) -> Any?{
        
        var unarchivedObject : Any?
        var objectData : Data?
        DataQueue.sync(execute: { () -> Void in
            if let objData = try? Data(contentsOf: self.URLForKey(key)) {
                
                objectData = objData
                guard let objectArchivedData = objectData else {
                    return
                }
                unarchivedObject = NSKeyedUnarchiver.unarchiveObject(with: objectArchivedData)
            }
        })
        return unarchivedObject
    }
    
    
    func resetDataItems(withKeys keys:[String]){
        DataQueue.sync(flags: .barrier, execute: {
            for objectKey in keys {
                let filePath = self.URLForKey(objectKey).path
                self.removeDataItem(withKey: filePath)
            }
        })
    }
    
    
    func resetAll(){
        DataQueue.sync(flags: .barrier, execute: {
            let sharedStorageTypePath = self.dataContainerURL.path
            self.removeAllFiles(atPath: sharedStorageTypePath)
        })
    }
    
    
    //Helper methods
    private func URLForKey( _ key: String) -> URL {
        let fileName = (key as NSString).appendingPathExtension("archive")
        return dataContainerURL.appendingPathComponent(fileName!)
    }
    
    //Remove DataItem with given key
    func removeDataItem(withKey objectKey:String){
        DataQueue.sync(execute: { () -> Void in
            let itemPath = self.URLForKey(objectKey).path
            self.removeFile(atPath:itemPath)
        })
    }
}

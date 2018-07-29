//
//  StorableProtocol.swift
//  DataStoreManager
//
//  Created by Mangaraju, Venkata Maruthu Sesha Sai [GCB-OT NE] on 7/28/18.
//  Copyright © 2018 Sai. All rights reserved.
//

import Foundation

public struct DataItem {
    var scope:DataItemScopeType
    var content:Any
    var keychianAccessScope:KeyChainItemAccessScopeType
    
    public init(scope:DataItemScopeType = .session, content:Any, keychianAccessScope:KeyChainItemAccessScopeType = .none){
        self.scope = scope
        self.content = content
        self.keychianAccessScope = keychianAccessScope
    }
    
}

protocol Storable{
    
    @discardableResult func storeDataItem(_ dataItem:DataItem, forKey key:String) -> Bool
    func getDataItem(forKey key:String) -> Any?
    func resetDataItems(withKeys keys:[String])
    func resetAll()
    func clearSessionScopeContents()
}

extension Storable {
    
    func removeFile(atPath itemPath:String){
        do {
            try FileManager.default.removeItem(atPath: itemPath)
        } catch _ {
            #if DEBUG
                Log.debug( "",message:"Error in deleting file")
            #endif
        }
    }
    
    //Remove all files in
    func removeAllFiles(atPath folderPath:String){
        while let itemPath = FileManager.default.enumerator(atPath: folderPath)?.nextObject() as? String {
            self.removeFile(atPath:folderPath + "/" + itemPath)
        }
    }
    
    //Applicable for File, SharedStorage Mangers
    func checkAndCreateDataContainer(withName containerName: String="") {
        
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let documentsDirectory = paths[0] as String
        let containerPath = URL(string: documentsDirectory)?.appendingPathComponent(containerName).absoluteString //VKG check
        if containerPath != nil {
            if (!FileManager.default.fileExists(atPath: containerPath!)) {
                
                do {
                    try FileManager.default.createDirectory(atPath: containerPath!, withIntermediateDirectories: false, attributes: nil)
                } catch _ {
                    #if DEBUG
                        Log.debug( "checkAndCreateDataContainer", message:"Failed to create container")
                    #endif
                }
            }
        }
    }
    
    func clearSessionScopeContents(){
        //Common implementation
    }
}

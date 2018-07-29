//
//  FilesDataStore.swift
//  DataStorageManager
//
//  Created by Mangaraju, Venkata Maruthu Sesha Sai [GCB-OT NE] on 7/28/18.
//  Copyright © 2018 Sai. All rights reserved.
//

import UIKit

class FilesDataStore: Storable {
    
    private let fileStoreName = "FileStorage"
    private let dataContainer = FileManager.default
    private let DataQueue:DispatchQueue = DispatchQueue(label: "FileStorageDataQueue", attributes: DispatchQueue.Attributes.concurrent)

    var dataContainerURL:URL? {
        do{
            let documentsDirectoryURL = try dataContainer.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            return documentsDirectoryURL.appendingPathComponent(fileStoreName)
        }catch _ {
            #if DEBUG
            Log.debug( "dataContainerURL", message: "Documents directory access failed")
            #endif
        }
        return nil
    }
    
    var dataContainerPath: String? {
        return dataContainerURL?.path
    }
    
    init(){
        
        //Create required directories in Documents
        self.checkAndCreateDataContainer(withName: fileStoreName)
    }

    
    
    @discardableResult func storeDataItem(_ dataItem:DataItem, forKey key:String) -> Bool{
        
        var status:Bool = false
        DataQueue.sync(flags: .barrier, execute: {
            if let fileContent = dataItem.content as? Data {
                if let filePath = self.fileURL(forFileName: key)?.path {
                    //if !self.dataContainer.fileExistsAtPath(filePath){
                        status = (try? fileContent.write(to: URL(fileURLWithPath: filePath), options: [.atomic])) != nil
                    //}else{
                    #if DEBUG
                    Log.debug( "storeDataItem", message: "File already exist at path: \(filePath)")
                    #endif
                    //}
                }
            }
        
        })
        return status
    }
    
    func getDataItem(forKey key:String) -> Any?{
        
        var fileContent:Data?
        DataQueue.sync(execute: { () -> Void in
            if let filePath = self.fileURL(forFileName: key)?.path {
                fileContent = self.dataContainer.contents(atPath: filePath)
            }
        })
        return fileContent
    }
    
    
    func resetDataItems(withKeys keys:[String]){
        
        DataQueue.sync(flags: .barrier, execute: {
            for objectKey in keys {
                if let filePath = self.fileURL(forFileName: objectKey)?.path {
                    self.removeFile(atPath: filePath)
                }
            }
        })
    }
    
    func resetAll(){
        
        DataQueue.sync(flags: .barrier, execute: {
            if let filesDirectoryPath = self.dataContainerPath {
                self.removeAllFiles(atPath: filesDirectoryPath)
            }
        })
    }
    
    //Helper methods
    private func fileURL(forFileName fileName: String) -> URL? {
        return dataContainerURL?.appendingPathComponent(fileName)
    }

    private func fileNameComponents(_ fileName:String)-> (fileName:String, fileExtension:String){
        let fileComponents = fileName.components(separatedBy: ".")
        return (fileName:fileComponents[0], fileExtension:fileComponents[1])
    }
}

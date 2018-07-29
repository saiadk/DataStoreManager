//
//  CoreDataStore.swift
//  DataStoreManager
//
//  Created by Mangaraju, Venkata Maruthu Sesha Sai [GCB-OT NE] on 7/28/18.
//  Copyright © 2018 Sai. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStore:NSObject, Storable {
    
    lazy var containerName = "DataStoreManager"
    lazy var entityName = "CoreDataItem"

    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        
         let managedObjectModel: NSManagedObjectModel = {
            let modelURL = Bundle(identifier: "com.sai.DataStoreManager")!.url(forResource: "DataStoreManager", withExtension: "momd")!
            return NSManagedObjectModel(contentsOf: modelURL)!
        }()
        
        //let container = NSPersistentContainer(name: containerName)
        let container = NSPersistentContainer(name: "DataStoreManager", managedObjectModel: managedObjectModel)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    @objc func saveContext () {
        let context = persistentContainer.viewContext
        context.performAndWait{
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    // Replace this implementation with code to handle the error appropriately.
                    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    let nserror = error as NSError
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
            }
        }
    }

    // MARK: - Initializer
    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(saveContext), name: Notification.Name.UIApplicationWillTerminate, object: nil)
    }
    
    func storeDataItem(_ dataItem: DataItem, forKey key: String) -> Bool {
        
        let coreDataItem = NSEntityDescription.insertNewObject(forEntityName: entityName, into: self.persistentContainer.viewContext) as! CoreDataItem
        coreDataItem.content = DataStoreManager.shared.getDataFromValueType(contentValueType: DataItem.self, content: dataItem) as Data
        coreDataItem.itemID = key
        coreDataItem.isSessionScope = (dataItem.scope == .session)
        return false
    }
    
    func getDataItem(forKey key: String) -> Any? {
     
        let dataItemFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        dataItemFetchRequest.predicate = NSPredicate(format: "itemID == %@", key)
        do {
            if let fetchedDataItems = try self.persistentContainer.viewContext.fetch(dataItemFetchRequest) as? [CoreDataItem],
               let dataItem = fetchedDataItems.first, fetchedDataItems.count == 1{
                if let dataItemContent = dataItem.content{
                    return DataStoreManager.shared.getValueTypeFromData(contentValueType: DataItem.self, content: dataItemContent as NSData)?.content
                }
            }
        } catch {
            fatalError("Failed to fetch employees: \(error)")
        }
        return nil
    }
    
    func resetDataItems(withKeys keys: [String]) {
        let deleteFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        deleteFetchRequest.predicate = NSPredicate(format: "itemID IN %@", keys)
        do {
            try self.persistentContainer.viewContext.fetch(deleteFetchRequest)
        } catch {
            fatalError("Failed to fetch employees: \(error)")
        }
    }
    
    func resetAll() {
        let deleteFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        do {
            try self.persistentContainer.viewContext.fetch(deleteFetchRequest)
        } catch {
            fatalError("Failed to fetch employees: \(error)")
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

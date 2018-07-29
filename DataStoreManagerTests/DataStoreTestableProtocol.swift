//
//  DataStoreTestable.swift
//  DataStoreManagerTests
//
//  Created by Mangaraju, Venkata Maruthu Sesha Sai [GCB-OT NE] on 7/29/18.
//  Copyright © 2018 Sai. All rights reserved.
//

import XCTest
@testable import DataStoreManager

protocol DataStoreTestable {
    
    var storeType:DataStoreType{ get }
    
    //Generic function to test different value types
    func validateStoring<T:Equatable>(value:T, key:String) -> Void
}

extension DataStoreTestable{
    //Defining the requirement to add this capability to different store type test cases without repeating the same code in multiple places.
    func validateStoring<T:Equatable>(value:T, key:String) -> Void {
        let storageManager = DataStoreManager.shared
        let dataItem = DataItem(content: value)
        _ = storageManager.storeDataItem(dataItem, forKey: key, storeType: storeType)
        if let fetchedValue = storageManager.getDataItem(forKey: key, storeType: storeType) as? T{
            XCTAssert(value == fetchedValue)
        }else{
            XCTAssert(false)
        }
    }
}

//Helper function to test storing & retrieving custom value types for a given storyType
func testCustomValueType(storeType:DataStoreType) {
    
    //Helper custom value type
    struct CustomValueType{
        let a = 1
        let b = "2"
        let c = 3.0
        let d = true
    }
    
    let storageManager = DataStoreManager.shared
    let key = "customValueTypeItem"
    let testData = CustomValueType()
    let data = storageManager.getDataFromValueType(contentValueType: CustomValueType.self, content: testData)
    
    let stringDataItem = DataItem(content: data)
    _ = storageManager.storeDataItem(stringDataItem, forKey: key, storeType: storeType)
    if let fetchedData = storageManager.getDataItem(forKey: key, storeType: storeType) as? NSData{
        XCTAssert(data == fetchedData, #function)
    }else{
        XCTAssert(false)
    }
}


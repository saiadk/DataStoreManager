//
//  InMemoryDataStoreTests.swift
//  DataStoreManagerTests
//
//  Created by Mangaraju, Venkata Maruthu Sesha Sai [GCB-OT NE] on 7/28/18.
//  Copyright © 2018 Sai. All rights reserved.
//

import XCTest
@testable import DataStoreManager

class InMemoryDataStoreTests: XCTestCase, DataStoreTestable {
    
    var storeType:DataStoreType = .inMemory
    let storageManager = DataStoreManager.shared
    
    func testWithStringType(){
        validateStoring(value: "This is a test string", key: "stringDataItem")
    }

    func testWithIntType(){
        validateStoring(value: 12345, key: "intDataItem")
    }

    func testFloat(){
        validateStoring(value: 123.456, key: "floatDataItem")
    }

    func testWithBoolType(){
        validateStoring(value: true, key: "boolDataItem")
    }

    func testWithDataType() {
        validateStoring(value: Data(), key: "dataItemType")
    }

    func testWithCustomValueType() {
        testCustomValueType(storeType: self.storeType)
    }
    
}

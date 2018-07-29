//
//  FileDataStoreTests.swift
//  DataStoreManagerTests
//
//  Created by Mangaraju, Venkata Maruthu Sesha Sai [GCB-OT NE] on 7/29/18.
//  Copyright © 2018 Sai. All rights reserved.
//

import XCTest
@testable import DataStoreManager

class FileDataStoreTests: XCTestCase, DataStoreTestable {
    
    var storeType:DataStoreType = .fileStorage
    
    func testWithDataType() {
        validateStoring(value: Data(), key: "dataItemType")
    }
    
    func testWithCustomValueType() {
        testCustomValueType(storeType: self.storeType)
    }

}


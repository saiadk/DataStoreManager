//
//  PreferencesDataStoreTests.swift
//  DataStoreManagerTests
//
//  Created by Mangaraju, Venkata Maruthu Sesha Sai [GCB-OT NE] on 7/29/18.
//  Copyright © 2018 Sai. All rights reserved.
//

import XCTest
@testable import DataStoreManager

class PreferencesDataStoreTests: InMemoryDataStoreTests {
    
    override func setUp() {
        super.setUp()
        storeType = .preferences
    }
    
}

//
//  ViewController.swift
//  DataStoreManagerConsumer
//
//  Created by Mangaraju, Venkata Maruthu Sesha Sai [GCB-OT NE] on 7/29/18.
//  Copyright © 2018 Sai. All rights reserved.
//

import UIKit
import DataStoreManager

//MARK: - Global types
extension DataStoreType {
    static var count:Int { return 6 }
    static var allCases:[DataStoreType]{
        return [.preferences, .keychain, .inMemory, .coredataStore, .fileStorage, .sharedStorage]
    }
    var pickerTitle:String{
        switch self {
            case .preferences:        return "UserDefaults Store"
            case .keychain:           return "Keyhain Store"
            case .inMemory:           return "In-Memory Dictionary"
            case .coredataStore:      return "CoreData Store"
            case .fileStorage:        return "File Store"
            case .sharedStorage:      return "Shared Storage"
        }
    }
    
    var testData:Any {
        switch self {
            case .preferences:        return "Preferences test string"
            case .keychain:           return "Keychain test string"
            case .inMemory:           return "In-memory test string"
            case .coredataStore:      return "CoreData test string"
            case .fileStorage:        return UIImage()
            case .sharedStorage:      return UIImage()
        }
    }
    
}

class ViewController: UIViewController {
    
    //MARK: - Stored properties
    @IBOutlet weak var datastoresPicker: UIPickerView!
    var selectedStoreIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.datastoresPicker.selectedRow(inComponent: selectedStoreIndex)
    }
    @IBAction func validateSelectedStore(_ sender: Any) {
        
        //Store sample data
        let testKey = DataStoreType.allCases[selectedStoreIndex].rawValue
        let testData = DataStoreType.allCases[selectedStoreIndex].testData
        let testDataItem = DataItem(content: testData)
        let testStoreType = DataStoreType.allCases[selectedStoreIndex]
        DataStoreManager.shared.storeDataItem(testDataItem, forKey: testKey, storeType: testStoreType)
        
        //Retrieve & compare stored data
        if let _ = DataStoreManager.shared.getDataItem(forKey: testKey, storeType: testStoreType){
            let alert = UIAlertController(title: DataStoreType.allCases[selectedStoreIndex].pickerTitle, message: "Successfully stored & retrieved \"\(testData)\" value !!!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)

        }
    }
    
}

//MARK: - PikcerView Delegate & DataSource functions
extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return DataStoreType.count
    }
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?{
        return DataStoreType.allCases[row].pickerTitle
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedStoreIndex = row
    }

}


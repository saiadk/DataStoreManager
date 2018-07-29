//
//  Log.swift
//  DataStorageManager
//
//  Created by Mangaraju, Venkata Maruthu Sesha Sai [GCB-OT NE] on 7/28/18.
//  Copyright © 2018 Sai. All rights reserved.
//


 class Log
{
    #if DEBUG
    class func debug(_ methodName:String, message:String)
    {
        print(methodName, message)
    }
    #endif
}

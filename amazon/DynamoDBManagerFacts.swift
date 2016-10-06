//
//  DynamoDBManagerFacts.swift
//  amazon
//
//  Created by O'Brien, Patrick (Synchrony Financial) on 8/11/16.
//  Copyright © 2016 O'Brien, Patrick (Synchrony Financial). All rights reserved.
//

import Foundation
import AWSDynamoDB

class Info : AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    var tableName = "isInfo"
    
    var header : String = ""
    var details : String = ""
    
    
    class func dynamoDBTableName() -> String {
        return "isInfoTable"
    }
    
    class func hashKeyAttribute() -> String {
        return "header"
    }
    
    class func rangeKeyAttribute() -> String {
        return "details"
    }
}
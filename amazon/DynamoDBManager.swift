//
//  DynamoDBManager.swift
//  amazon
//
//  Created by O'Brien, Patrick (Synchrony Financial) on 7/18/16.
//  Copyright © 2016 O'Brien, Patrick (Synchrony Financial). All rights reserved.
//

import Foundation
import AWSDynamoDB

class Event : AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    var tableName = "isEvents"
    
    var event: String = ""
    var startDate: Double = 0
    var endDate : Double = 0
    var leader : String = ""
    var details : String = ""
    var coOwner : String = ""
    var topic : String = ""
    
    class func dynamoDBTableName() -> String {
        return "ISEventsDatabase"
    }
    
    class func hashKeyAttribute() -> String {
        return "event"
    }
    
    class func rangeKeyAttribute() -> String {
        return "startDate"
    }
}

class Info : AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    var tableName = "isInfo"
    
    var header : String = ""
    var details : String = ""
    
    
    class func dynamoDBTableName() -> String {
        return "isInfo"
    }
    
    class func hashKeyAttribute() -> String {
        return "header"
    }
    
    class func rangeKeyAttribute() -> String {
        return "details"
    }
}

class Reminder {
    var title = ""
    var body = ""
    var fireDate = NSDate()
}

class myEvent: NSObject, NSCoding {
    var event: String
    var startDate: Double
    var endDate : Double
    var leader : String
    var details : String
    var coOwner: String
    var topic: String
    var eventDate : NSDate
    
    init?(event: String, startDate: Double, endDate: Double, leader: String, details: String, coOwner: String, topic: String, eventDate: NSDate) {
        self.event = event
        self.startDate = startDate
        self.endDate = endDate
        self.leader = leader
        self.details = details
        self.coOwner = coOwner
        self.topic = topic
        self.eventDate = eventDate
        
        super.init()
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(event, forKey: "event")
        aCoder.encodeObject(startDate, forKey: "startDate")
        aCoder.encodeObject(endDate, forKey: "endDate")
        aCoder.encodeObject(leader, forKey: "leader")
        aCoder.encodeObject(details, forKey: "details")
        aCoder.encodeObject(coOwner, forKey: "coOwner")
        aCoder.encodeObject(topic, forKey: "topic")
        aCoder.encodeObject(eventDate, forKey: "eventDate")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let event = aDecoder.decodeObjectForKey("event") as! String
        let startDate = aDecoder.decodeObjectForKey("startDate") as! Double
        let endDate = aDecoder.decodeObjectForKey("endDate") as! Double
        let leader = aDecoder.decodeObjectForKey("leader") as! String
        let details = aDecoder.decodeObjectForKey("details") as! String
        let coOwner  = aDecoder.decodeObjectForKey("coOwner") as! String
        let topic = aDecoder.decodeObjectForKey("topic") as! String
        let eventDate  = aDecoder.decodeObjectForKey("eventDate") as! NSDate
        
        self.init(event: event, startDate: startDate, endDate: endDate, leader: leader, details: details, coOwner: coOwner, topic: topic, eventDate: eventDate)
    }
    
}


class amazonDb {
    
    func deleteRow(toRemove: Event) {
        
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        dynamoDBObjectMapper.remove(toRemove).continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: { (task:AWSTask!) -> AnyObject! in
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            
            if ((task.error) != nil) {
                print("Error: \(task.error)")
                
            }
            return nil
        })
    }
    
    func saveRow(toAdd: Event, view: UIViewController) {
        dynamoDBObjectMapper.save(toAdd) .continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: { (task:AWSTask!) -> AnyObject! in
            if ((task.error) != nil) {
                let title = "Error!"
                let body = "There was an error adding this event. The event was not saved successfully"
                self.presentAlert(title, body: body, view: view)
            }
            if ((task.exception) != nil) {
                let exception = task.exception as? String
                print("Request \n Failed \n Exception is: \n" + exception!)
            }
            if ((task.result) != nil) {
                let title = "Saved!"
                let body = "Your event was saved successfully"
                self.presentAlert(title, body: body, view: view)
            }
            return nil
        })
    }
    
    func scanDb(expression: AWSDynamoDBScanExpression, view: UIViewController, type: String) {
        
        dynamoDBObjectMapper.scan(Event.self, expression: expression) .continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: { (task:AWSTask!) -> AnyObject! in
            
            var output = AWSDynamoDBPaginatedOutput()
            
            if ((task.error) != nil) {
                print("Request \n Failed \n Error is: \n")
                print(task.error)
            }
            if ((task.exception) != nil) {
                var exception = task.exception as! String
                print("Request \n Failed \n Exception is: \n" + exception)
            }
            if ((task.result) != nil) {
                //do something
                print ("The \n Request \n Received \n a Result \n")
                print(task.result)
                
                output = task.result as! AWSDynamoDBPaginatedOutput
                
                //parse response.
                if view.isKindOfClass(HomepageViewController) {
                    var homepageInstance = HomepageViewController()
                    if type == "upcoming" {
                        homepageInstance.parseUpcoming(task)
                    } else {
                        homepageInstance.parseUpcoming(task)
                    }
                } else {
                    //nothing for now
                }
                
                print(output.items)
                
            }
            return nil
        })
        
    }
    
    func presentAlert(title: String, body: String, view: UIViewController) {
        let alert = UIAlertController(title: title, message: body, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Done", style: .Default, handler: nil))
        view.presentViewController(alert, animated: true, completion: nil)
    }
    
    func addNewEvent(event: myEvent) {
        let defaults = NSUserDefaults()
        let myKey = "myEvents"
        var myReminder = [myEvent]()
        myReminder.append(event)
        let dictAsData = NSKeyedArchiver.archivedDataWithRootObject(myReminder)
        defaults.setObject(dictAsData, forKey: myKey)
    }
    
    func unpackAndResaveEvent(event: myEvent) {
        let defaults = NSUserDefaults()
        let myKey = "myEvents"
        var myReminder = [myEvent]()
        var oldInfo = defaults.objectForKey(myKey) as! NSData
        var oldInfoUnkeyed = NSKeyedUnarchiver.unarchiveObjectWithData(oldInfo) as! NSArray
        
        for entry in oldInfoUnkeyed {
            var newInfo = entry as! myEvent
            myReminder.append(newInfo)
        }
        myReminder.append(event)
        let dictAsData = NSKeyedArchiver.archivedDataWithRootObject(myReminder)
        defaults.setObject(dictAsData, forKey: myKey)
    }
    
    func unpackAndClean() -> Bool {
        //returns true if it has values
        let defaults = NSUserDefaults()
        let myKey = "myEvents"
        var myReminder = [myEvent]()
        var cleanDict : myEvent
        var oldInfo = defaults.objectForKey(myKey) as! NSData
        var oldInfoUnkeyed = NSKeyedUnarchiver.unarchiveObjectWithData(oldInfo) as! NSArray
        
        for entry in oldInfoUnkeyed {
            var newInfo = entry as! myEvent
            if newInfo.startDate < getCurrentUnixTime() {
                //do nothing
            } else {
            myReminder.append(newInfo)
            }
        }
        if myReminder.isEmpty {
            defaults.removeObjectForKey(myKey)
            return false
        } else {
            let dictAsData = NSKeyedArchiver.archivedDataWithRootObject(myReminder)
            defaults.setObject(dictAsData, forKey: myKey)
            return true
        }
        
    }
    
    func getCurrentUnixTime() -> Double {
        let timeInterval = NSDate().timeIntervalSince1970
        
        return timeInterval
    }
    
    func getWeekFromNowUnixTime(startDate: NSDate) -> Double {
        let dateComponents = NSDateComponents()
        dateComponents.day = 8
        
        var theCalendar = NSCalendar.currentCalendar()
        var nextDate = theCalendar.dateByAddingComponents(dateComponents, toDate: startDate, options: .MatchFirst)
        
        var unixFuture = nextDate?.timeIntervalSince1970
        
        return unixFuture!
    }
    
    func unixToDateFormat(unixTime: Double) -> String {
        let date = NSDate(timeIntervalSince1970: unixTime)
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMM dd, YYYY h:mm"
        
        let dateString = dateFormatter.stringFromDate(date)
        
        return dateString
    }
    
    func unixToTimeFirstDateFormat(unixTime: Double) -> String {
        let date = NSDate(timeIntervalSince1970: unixTime)
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "h:mm a MMM dd, YYYY"
        
        let dateString = dateFormatter.stringFromDate(date)
        
        return dateString
    }
    
    func dateToUnix(date: NSDate) -> Double {
        let unix = date.timeIntervalSince1970
        return unix
    }
    
    func dateStringToUnix(date: String) -> Double {
        let dateFormatter = NSDateFormatter()
        let dateOf = dateFormatter.dateFromString(date)
        let unixDate = dateOf?.timeIntervalSince1970
        return unixDate!
    }
    
    func dateToDateString(date: NSDate) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMM dd, YYYY"
        let dateString = dateFormatter.stringFromDate(date)
    
        return dateString
    }
    
    func unixToNSDate(unix: Double) -> NSDate {
        let date = NSDate.init(timeIntervalSince1970: unix)
        return date
    }

    func convertEventToMyEvent(event: Event, date: NSDate) -> myEvent {
        var newEvent = myEvent(event: event.event, startDate: event.startDate, endDate: event.endDate, leader: event.leader, details: event.details, coOwner: event.coOwner, topic: event.topic, eventDate: date)
        
        print(newEvent)
        return newEvent!
    }
    
}






//
//  XLFormViewController.swift
//  amazon
//
//  Created by O'Brien, Patrick (Synchrony Financial) on 10/6/16.
//  Copyright © 2016 O'Brien, Patrick (Synchrony Financial). All rights reserved.
//

import UIKit
import XLForm
import AWSDynamoDB

class xlAddNewViewController: XLFormViewController {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initializeForm()
    }
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.initializeForm()
    }
    
    func initializeForm() {
        let form : XLFormDescriptor
        var section : XLFormSectionDescriptor
        var row : XLFormRowDescriptor
        
        form = XLFormDescriptor()
        //form.assignFirstResponderOnShow = true
        
        // info title
        section = XLFormSectionDescriptor.formSectionWithTitle("Please fill in information below")
        form.addFormSection(section)
        
        // Selector Action Sheet
        row = XLFormRowDescriptor(tag :"event", rowType:XLFormRowDescriptorTypeSelectorActionSheet, title:"Event")
        row.selectorOptions = ["Hackathon", "Volunteer Event", "Bolt Session", "IS Tour", "Bagel Monday"]
        row.cellConfig.setObject(UIFont(name: "Avenir Next", size: 17)!, forKey: "textLabel.font")
        row.cellConfig.setObject(UIFont(name: "Avenir Next", size: 17)!, forKey: "detailTextLabel.font")
        row.value = "Hackathon"
        section.addFormRow(row)
        
        //Starts
        row = XLFormRowDescriptor(tag: "starts", rowType: XLFormRowDescriptorTypeDateTimeInline, title: "Starts")
        row.value = NSDate()
        row.cellConfig.setObject(UIFont(name: "Avenir Next", size: 17)!, forKey: "textLabel.font")
        row.cellConfig.setObject(UIFont(name: "Avenir Next", size: 17)!, forKey: "detailTextLabel.font")
        row.required = true
        section.addFormRow(row)
        
        // Ends
        row = XLFormRowDescriptor(tag: "ends", rowType: XLFormRowDescriptorTypeDateTimeInline, title: "Ends")
        row.value = NSDate()
        row.cellConfig.setObject(UIFont(name: "Avenir Next", size: 17)!, forKey: "textLabel.font")
        row.cellConfig.setObject(UIFont(name: "Avenir Next", size: 17)!, forKey: "detailTextLabel.font")
        row.required = true
        section.addFormRow(row)
        
        //owner
        row = XLFormRowDescriptor(tag: "owner", rowType: XLFormRowDescriptorTypeText)
        row.cellConfigAtConfigure["textField.placeholder"] = "Owner"
        row.cellConfig["textLabel.font"] = UIFont(name: "Avenir Next", size: 17)
        row.cellConfig["detailTextLabel.font"] = UIFont(name: "Avenir Next", size: 17)
        row.required = false
        section.addFormRow(row)
        
        //coowner
        row = XLFormRowDescriptor(tag: "coOwner", rowType: XLFormRowDescriptorTypeText)
        row.cellConfigAtConfigure["textField.placeholder"] = "Co-owner"
        row.cellConfig.setObject(UIFont(name: "Avenir Next", size: 17)!, forKey: "textLabel.font")
        row.cellConfig.setObject(UIFont(name: "Avenir Next", size: 17)!, forKey: "detailTextLabel.font")
        row.required = false
        section.addFormRow(row)
        
       
        //topic
        row = XLFormRowDescriptor(tag: "topic", rowType: XLFormRowDescriptorTypeText)
        row.cellConfigAtConfigure["textField.placeholder"] = "Topic"
        row.cellConfig.setObject(UIFont(name: "Avenir Next", size: 17)!, forKey: "textLabel.font")
        row.cellConfig.setObject(UIFont(name: "Avenir Next", size: 17)!, forKey: "detailTextLabel.font")
        row.required = false
        section.addFormRow(row)
        
        // TextView
        row = XLFormRowDescriptor(tag: "details", rowType: XLFormRowDescriptorTypeTextView)
        row.cellConfigAtConfigure["textView.placeholder"] = "Details"
        row.cellConfig.setObject(UIFont(name: "Avenir Next", size: 17)!, forKey: "textLabel.font")
        row.cellConfig.setObject(UIFont(name: "Avenir Next", size: 17)!, forKey: "detailTextLabel.font")
        row.required = true
        section.addFormRow(row)
        
        self.form = form
        
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: "savePressed:")
        
        self.title = "ADD NEW EVENT"
    }
    
    func cancelPressed(button: UIBarButtonItem) {
        performSegueWithIdentifier("unwindToDetailFromEdit", sender: self)
    }
    
    func savePressed(button: UIBarButtonItem) {
        let datInstance = XLFormViewController()
        var dictionary = formValues() as! NSDictionary
        validateInputs()
        
    }
    
    func validateInputs() {
        let validationErrors = self.formValidationErrors() as! [NSError]
        
        if validationErrors.count > 0 {
            //show validation alert
            amazonDb().presentAlert("Validation Error", body: "All input fields are required, except co-owner and topic", view: self)
        } else {
            //save event to amazon
            setScan()
        }
    }
    
    func setScan() {
        var newEvent = Event()
        var dictionary = formValues() as! NSDictionary
        //setting known completed fields
        let eventString = dictionary["event"] as! String
        newEvent.event = eventString
        
        let startDate = dictionary["starts"] as! NSDate
        newEvent.startDate = amazonDb().dateToUnix(startDate)
        let endDate = dictionary["ends"] as! NSDate
        newEvent.endDate = amazonDb().dateToUnix(endDate)
        
        let owner = dictionary["owner"]
        if let y = owner as? String {
            newEvent.leader = dictionary["owner"] as! String
        } else {
            newEvent.leader = "none"
        }
        
        let detailsString = dictionary["details"] as! String
        newEvent.details = detailsString
        
        let coowner = dictionary["coOwner"]
        if let y = coowner as? String {
            newEvent.coOwner = dictionary["coOwner"] as! String
        } else {
            newEvent.coOwner = "none"
        }
        
        let topic = dictionary["topic"]
        if let y = topic as? String {
            newEvent.topic = dictionary["topic"] as! String
        } else {
            newEvent.topic = "none"
        }
        
        //     saveObject(newEvent)
        
    }
    
    func saveObject (event : Event) {
        
        dynamoDBObjectMapper.save(event) .continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: { (task:AWSTask!) -> AnyObject! in
            if ((task.error) != nil) {
                
                let errorAlert = UIAlertController(title: "Error!", message: "There was an error adding this event. The event was not saved successfully", preferredStyle: .Alert)
                errorAlert.addAction(UIAlertAction(title: "Done", style: .Default, handler: nil))
                self.presentViewController(errorAlert, animated: true, completion: nil)
                
            }
            if ((task.exception) != nil) {
                let exception = task.exception as? String
                print("Request \n Failed \n Exception is: \n" + exception!)
            }
            if ((task.result) != nil) {
                
                //send an alert to user to show that the information was saved successfully
                let alert = UIAlertController(title: "Success!", message: "Your event has been saved successfully", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "Done", style: .Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                
            }
            return nil
        })
        
    
        
        performSegueWithIdentifier("unwindToDetailFromEdit", sender: self)
    }
    
    
}


//
//  EditEventViewController.swift
//  amazon
//
//  Created by O'Brien, Patrick (Synchrony Financial) on 8/30/16.
//  Copyright © 2016 O'Brien, Patrick (Synchrony Financial). All rights reserved.
//

import UIKit
import AWSDynamoDB

class EditEventViewController: UIViewController {

    var oldEvent = Event()
    
    var updateEvent = Event()
    
    let dynamo = amazonDb()
    
    
    //textFields
    
    @IBOutlet weak var eventField: UITextField!
    
    @IBOutlet weak var strDateField: UITextField!
    
    @IBOutlet weak var strTimeField: UITextField!
    
    @IBOutlet weak var endDateField: UITextField!
    
    @IBOutlet weak var endTimeField: UITextField!
    
    @IBOutlet weak var ownerField: UITextField!
    
    @IBOutlet weak var coownerField: UITextField!
    
    @IBOutlet weak var detailField: UITextView!
    
    //Button
    @IBOutlet weak var btnSubmit: UIButton!
    
    //label for unknown which shifts to topic / host / guest
    @IBOutlet weak var lblUnknown: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        setLabels()
        
        self.title = "Edit Event"
        
        btnSubmit.addTarget(self, action: #selector(EditEventViewController.setSave), forControlEvents: .TouchUpInside)
        
        // Do any additional setup after loading the view.
        
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setLabels() {
        eventField.text = oldEvent.event
        strDateField.text = dynamo.unixToDateFormat(oldEvent.startDate)
        endDateField.text = dynamo.unixToDateFormat(oldEvent.endDate)
        ownerField.text = oldEvent.leader
        detailField.text = oldEvent.details
        
        if oldEvent.coOwner.isEmpty {
            oldEvent.coOwner = ""
        } else {
            coownerField.text = oldEvent.coOwner
        }
    }
    
    func validateFields(){
        //check the fields for some text. if no text then display a validation error message. Otherwise send the information through for saving
        
        if eventField.text == "" || strDateField.text == "" || strTimeField.text == "" || endDateField.text == "" || endTimeField.text == "" || ownerField.text == "" || detailField.text == "" {
            
            //display validation error
            let dynamo = amazonDb()
            dynamo.presentAlert("Validation Error", body: "Please make sure you have filled in all input fields", view: self)
            
        } else {
            setSave()
        }
    
        
        
    }
    
    func setSave() {
        let amazon = amazonDb()
        let startString = strDateField.text
        let endString = endDateField.text
        
        updateEvent.event = eventField.text!
        updateEvent.startDate = amazon.dateStringToUnix(startString!)
        updateEvent.endDate = amazon.dateStringToUnix(endString!)
        updateEvent.leader = ownerField.text!
        updateEvent.details = detailField.text!

        if coownerField.text?.characters.count != 0 {
            updateEvent.coOwner = coownerField.text!
        } else {
            updateEvent.coOwner = " "
        }
        
        saveObject(updateEvent)
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
                
                //clear all textfields
                self.eventField.text = ""
                self.strDateField.text = ""
                self.strTimeField.text = ""
                self.endDateField.text = ""
                self.endTimeField.text = ""
                self.ownerField.text = ""
                
            }
            return nil
        })
        
        //determine whether or not a record needs to be deleted
        if updateEvent.event != oldEvent.event || updateEvent.startDate != oldEvent.startDate {
            //delete old row with start time from old event and event title from old event
            
            deleteRow()
        }
    }
    
    func deleteRow() {
        
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        dynamoDBObjectMapper.remove(oldEvent).continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: { (task:AWSTask!) -> AnyObject! in
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            
            if ((task.error) != nil) {
                print("Error: \(task.error)")
                
                let alertController = UIAlertController(title: "Failed to delete a row.", message: task.error!.description, preferredStyle: UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: { (action:UIAlertAction) -> Void in
                })
                alertController.addAction(okAction)
                self.presentViewController(alertController, animated: true, completion: nil)
                
                
            }
            return nil
        })
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

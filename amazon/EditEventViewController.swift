//
//  EditEventViewController.swift
//  amazon
//
//  Created by O'Brien, Patrick (Synchrony Financial) on 8/30/16.
//  Copyright © 2016 O'Brien, Patrick (Synchrony Financial). All rights reserved.
//

import UIKit
import AWSDynamoDB

class EditEventViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {

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
    
    @IBOutlet weak var detailField: UITextField!
    
    @IBOutlet weak var unknownField: UITextField!
    
    //constraints
    @IBOutlet weak var topicHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var topiclblHeightConstraint: NSLayoutConstraint!
    
    //scrollview
    @IBOutlet weak var scrollView: UIScrollView!
    
    //Button
    @IBOutlet weak var btnSubmit: UIButton!
    
    //label for unknown which shifts to topic / host / guest
    @IBOutlet weak var lblUnknown: UILabel!
    
    var activeField: UITextField?
    var activeTextView: UITextView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerForKeyboardNotifications()
        
        self.eventField.delegate = self
        self.strDateField.delegate = self
        self.strTimeField.delegate = self
        self.endDateField.delegate = self
        self.endTimeField.delegate = self
        self.ownerField.delegate = self
        self.coownerField.delegate = self
        self.unknownField.delegate = self
        self.detailField.delegate = self

        setLabels()
        
        self.title = "Edit Event"
        
        btnSubmit.addTarget(self, action: #selector(EditEventViewController.setSave), forControlEvents: .TouchUpInside)
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setLabels() {
        //button style
        btnSubmit.layer.cornerRadius = 10
        
        
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
        
        let title = eventField.text!
        switch title {
        case "Hackathon":
            lblUnknown.text = "Topic"
        case "Bolt Session":
            lblUnknown.text = "Topic"
        case "IS Tour":
            lblUnknown.text = "Guest"
        case "Bagel Monday":
            topicHeightConstraint.constant = 0
            topiclblHeightConstraint.constant = 0
        case "Volunteering Event":
            lblUnknown.text = "Partner"
        default:
            break
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
        if coownerField.text == "" {
            updateEvent.coOwner = "none"
        } else {
            updateEvent.coOwner = coownerField.text!
        }
        if unknownField.text == "" {
            updateEvent.topic = "none"
        } else {
            updateEvent.topic = unknownField.text!
        }

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
    
    func registerForKeyboardNotifications()
    {
        //Adding notifies on keyboard appearing
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWasShown:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillBeHidden:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    
    func deregisterFromKeyboardNotifications()
    {
        //Removing notifies on keyboard appearing
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWasShown(notification: NSNotification)
    {
        //Need to calculate keyboard exact size due to Apple suggestions
        self.scrollView.scrollEnabled = true
        var info : NSDictionary = notification.userInfo!
        var keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue().size
        var contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize!.height, 0.0)
        
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        
        var aRect : CGRect = self.view.frame
        aRect.size.height -= keyboardSize!.height
        
        if let activeFieldPresent = activeField
        {
            if (!CGRectContainsPoint(aRect, activeField!.frame.origin))
            {
                self.scrollView.scrollRectToVisible(activeField!.frame, animated: true)
            }
        }
        
    }
    
    
    func keyboardWillBeHidden(notification: NSNotification)
    {
        //Once keyboard disappears, restore original positions
        var info : NSDictionary = notification.userInfo!
        var keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue().size
        var contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -keyboardSize!.height, 0.0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        self.view.endEditing(true)
        self.scrollView.scrollEnabled = false
        
    }
    
    func textFieldDidBeginEditing(textField: UITextField!)
    {
        activeField = textField
    }
    
    func textFieldDidEndEditing(textField: UITextField!)
    {
        activeField = nil
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        activeTextView = nil
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        activeTextView = textView
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool // called when 'return' key pressed. return false to ignore.
    {
        textField.resignFirstResponder()
        return true
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

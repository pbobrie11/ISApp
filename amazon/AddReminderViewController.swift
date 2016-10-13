//
//  AddReminderViewController.swift
//  amazon
//
//  Created by O'Brien, Patrick (Synchrony Financial) on 8/31/16.
//  Copyright © 2016 O'Brien, Patrick (Synchrony Financial). All rights reserved.
//

import UIKit

class AddReminderViewController: UIViewController {


    var event = Event()
    
    @IBOutlet weak var eventField: UITextField!
    
    @IBOutlet weak var lblAlarmDate: UILabel!
    
    @IBOutlet weak var notesTextView: UITextView!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var btnSet: UIButton!
    
    //lineviews
    @IBOutlet weak var topLineView: UIView!
    @IBOutlet weak var bottomLineView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.tintColor = UIColor.charcoalGray()
        notesTextView.layer.borderColor = UIColor.steelGray().CGColor
        notesTextView.layer.borderWidth = 1
        notesTextView.layer.cornerRadius = 3
        topLineView.backgroundColor = UIColor.synchronyGold()
        bottomLineView.backgroundColor = UIColor.synchronyGold()
        
        let defaults = NSUserDefaults()
        
        let amazon = amazonDb()
        let date = amazon.getCurrentUnixTime()
        let dateString = amazon.unixToDateFormat(date)

        eventField.text = event.event
        lblAlarmDate.text = dateString
        
        datePicker.addTarget(self, action: #selector(AddReminderViewController.didFinishDatePicking), forControlEvents: .ValueChanged)
        btnSet.addTarget(self, action: #selector(AddReminderViewController.setAlertBody), forControlEvents: .TouchUpInside)
        
        // make that button look dope
        btnSet.backgroundColor = UIColor.synchronyGreen()
        btnSet.titleLabel?.textColor = UIColor.blackColor()
        btnSet.layer.cornerRadius = 10
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func didFinishDatePicking () {
        var dateFormatter = NSDateFormatter()
        
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        
        var strDate = dateFormatter.stringFromDate(datePicker.date)
        
        lblAlarmDate.text = strDate
    }
    
    func setAlertBody() {
        var newReminder = Reminder()
        newReminder.title = eventField.text!
        newReminder.body = notesTextView.text!
        newReminder.fireDate = datePicker.date
        
        setReminder(newReminder)
    }
    
    func setReminder(reminder: Reminder) {
        
        //schedule notification
        let notification = UILocalNotification()
        notification.alertTitle = reminder.title
        notification.alertBody = reminder.body
        notification.fireDate = reminder.fireDate
        notification.soundName = UILocalNotificationDefaultSoundName
        
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        
        //add to NSDefaults
        var defaults = NSUserDefaults()
        
        //dateString
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .MediumStyle
        var dateString = dateFormatter.stringFromDate(reminder.fireDate)
        let eventType = "reminder"
        let myKey = "myEvents"
        let dynamo = amazonDb()
        let date = datePicker.date
        
        //gets date of
        let dateAsString = amazonDb().unixToDateFormat(event.startDate)
        print(dateAsString)
        print(event.event)
        
        let eventStartInDateFormat = amazonDb().unixToNSDate(event.startDate)
        
        //set reminder to be added
        let newReminder = amazonDb().convertEventToMyEvent(event, date: eventStartInDateFormat)
        
        var existingDict = defaults.objectForKey(myKey)
        
        //check for existing array in defaults containing any reminders created in the past
        if existingDict != nil {
          //unpack and repack array for reminders and favorites
            dynamo.unpackAndResaveEvent(newReminder)
            print(existingDict)
        } else {
            dynamo.addNewEvent(newReminder)
        }
        
        presentAlert("Success!", body: "Reminder set and event added to favorites", view: self)
    }

    func presentAlert(title: String, body: String, view: UIViewController) {
        let alert = UIAlertController(title: title, message: body, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Done", style: .Default, handler: presentHome))
        view.presentViewController(alert, animated: true, completion: nil)
    }
    
    func presentHome(alert: UIAlertAction!){
        performSegueWithIdentifier("showHome", sender: nil)
    }

}

//
//  pullObjectViewController.swift
//  amazon
//
//  Created by O'Brien, Patrick (Synchrony Financial) on 7/21/16.
//  Copyright © 2016 O'Brien, Patrick (Synchrony Financial). All rights reserved.
//

import UIKit
import AWSDynamoDB

class pullObjectViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextViewDelegate, UITextFieldDelegate {
    
    var event = [Event]()
    
    //spinner and view
    var spinner = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
    var loadingView : UIView = UIView()
    
    //pickerview to handle event types
    @IBOutlet weak var eventPickerView: UIPickerView!
    var pickerData = ["", "Hackathon", "Bagel Monday", "Bolt Session", "IS Tour", "Volunteer Event"]
    
    @IBOutlet weak var eventTypePickerView: UIPickerView!
    var eventTypeData = ["", "Event", "Date", "Owner"]
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    
    //lbl
    @IBOutlet weak var lblEventTitle: UILabel!
    @IBOutlet weak var lblStartDate: UILabel!
    @IBOutlet weak var lblOwner: UILabel!
    @IBOutlet weak var lblEventType: UILabel!
    
    //text fields
    @IBOutlet weak var startField: UITextField!
    @IBOutlet weak var ownerField: UITextField!
    @IBOutlet weak var eventField: UITextField!
    @IBOutlet weak var eventTypeField: UITextField!
    
    //submit / scan button
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var setDateBtn: UIButton!
   
    //UIView
    @IBOutlet weak var topLineView: UIView!
    @IBOutlet weak var bottomLineView: UIView!
    
    
    //pickerView - not needed for testing but will need to include a picker for event type for pk in scan / query
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationItem.setHidesBackButton(true, animated: true)
        
        //set view color
        topLineView.backgroundColor = UIColor.synchronyGold()
        bottomLineView.backgroundColor = UIColor.synchronyGold()
        
        eventTypePickerView.hidden = true
        eventPickerView.hidden = true
        datePicker.hidden = true
        setDateBtn.hidden = true
        
        //set tag for pickers
        eventPickerView.tag = 1
        eventTypePickerView.tag = 2
        
        //setting delegate and data source for picker
        eventPickerView.delegate = self
        eventPickerView.dataSource = self
        eventTypePickerView.delegate = self
        eventTypePickerView.dataSource = self
        startField.delegate = self
        ownerField.delegate = self
        eventField.delegate = self
        eventTypeField.delegate = self

        //add action to sub button to handle checking which field will be used to sort
        submitBtn.backgroundColor = UIColor.synchronyGreen()
        submitBtn.titleLabel?.textColor = UIColor.whiteColor()
        submitBtn.layer.cornerRadius = 10
        submitBtn.addTarget(self, action: "setScan", forControlEvents: .TouchUpInside)
        
        //startField.addTarget(self, action: "datePickerChanged:", forControlEvents: .ValueChanged)
        setDateBtn.addTarget(self, action: "datePickerChanged", forControlEvents: .TouchUpInside)
        setDateBtn.backgroundColor = UIColor.synchronyGreen()
        setDateBtn.titleLabel?.textColor = UIColor.whiteColor()
        setDateBtn.layer.cornerRadius = 10
    
       // eventTypeField.addTarget(self, action: #selector(pullObjectViewController.showCorrectObjects(_:)), forControlEvents: .EditingChanged)
        
        //hide all fields and labels until event type has been chosen
        hideAllOptionObjects()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        navigationController?.navigationItem.setHidesBackButton(true, animated: true)
    }
    
    func hideAllOptionObjects() {
        //hide all fields
        startField.hidden = true
        ownerField.hidden = true
        eventField.hidden = true
        
        //hide all labels
        lblEventTitle.hidden = true
        lblStartDate.hidden = true
        lblOwner.hidden = true
        
        bottomLineView.hidden = true
        setDateBtn.hidden = true
    }
    
    func textFieldShouldBeginEditing(textField: UITextField!) -> Bool {
        // if text field is eventType. keep everything hidden and show event type picker
        if textField == eventTypeField {
            hideAllOptionObjects()
            datePicker.hidden = true
            showEventTypePicker()
            return false
        } else if textField == eventField {
            showEventPicker()
            return false
        } else if textField == startField {
            datePicker.hidden = false
            return false
        }else {
            return true
        }
    }
    
    func showEventTypePicker() {
        eventTypePickerView.hidden = false
    }
    
    func showEventPicker() {
        eventPickerView.hidden = false
    }
    
    func showCorrectObjects() {
        if eventTypeField.text == "Event" {
            eventField.hidden = false
            lblEventTitle.hidden = false
            startField.hidden = true
            lblStartDate.hidden = true
            ownerField.hidden = true
            lblOwner.hidden = true
            eventTypePickerView.hidden = true
            eventPickerView.hidden = true
            bottomLineView.hidden = false
            datePicker.hidden = true
            setDateBtn.hidden = true
        } else if eventTypeField.text == "Date" {
            startField.hidden = false
            lblStartDate.hidden = false
            eventField.hidden = true
            lblEventTitle.hidden = true
            ownerField.hidden = true
            lblOwner.hidden = true
            eventTypePickerView.hidden = true
            eventPickerView.hidden = true
            bottomLineView.hidden = false
            datePicker.hidden = false
            setDateBtn.hidden = false
        } else if eventTypeField.text == "Owner" {
            eventField.hidden = true
            lblEventTitle.hidden = true
            ownerField.hidden = false
            lblOwner.hidden = false
            startField.hidden = true
            lblStartDate.hidden = true
            eventTypePickerView.hidden = true
            eventPickerView.hidden = true
            bottomLineView.hidden = false
            datePicker.hidden = true
            setDateBtn.hidden = true
        }
    }
    
    func hidePickers() {
        eventPickerView.hidden = true
        eventTypePickerView.hidden = true
    }
    
    func setScan () {
        
        event = []
        
        //set field by getting the value of the event type field
        if eventTypeField.text == "Date" && startField.text != "" {
            //take day and set btwn scan for day and 24 hours later
            setDateLimits()
        } else if eventTypeField.text == "Owner" && ownerField.text != "" {
            retrieveObject("Owner", key: ownerField.text!)
        } else if eventTypeField.text == "Event" && eventField.text != "" {
            retrieveObject("event", key: eventField.text!)
        } else {
            //display validation error message and do not allow to retrieve object
            amazonDb().presentAlert("Validation Error", body: "Please select a category to search by and provide a valid search term", view: self)
        }
        
    }
    
    
    func retrieveObject (field : String, key : String) {
        
        showActivityIndicator()
        
        let scanExpression = AWSDynamoDBScanExpression()
        scanExpression.limit = 10
        scanExpression.filterExpression = field + " = :sub"
        scanExpression.expressionAttributeValues = [":sub" : key]
        
        dynamoDBObjectMapper.scan(Event.self, expression: scanExpression) .continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: { (task:AWSTask!) -> AnyObject! in
            
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
                
                //parse response
                self.parseResponse(task)
                
                print(output.items)
                
            }
            return nil
        })
    }
    
    
    func retrieveUpcomingObject (start: Double, end: Double) {
        
        let scanExpression = AWSDynamoDBScanExpression()
        scanExpression.limit = 5
        scanExpression.filterExpression = "startDate between :start and :end"
        scanExpression.expressionAttributeValues = [":start" : start, ":end" : end]
        
        let dynamo = amazonDb()
        
        dynamoDBObjectMapper.scan(Event.self, expression: scanExpression) .continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: { (task:AWSTask!) -> AnyObject! in
            
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
                self.parseResponse(task)
                
            }
            return nil
        })
    }

    
    func parseResponse(output: AWSTask) {
        
        let tableRow = output.result as! AWSDynamoDBPaginatedOutput
        
        var response = tableRow.items
        
        for (items) in tableRow.items {
            var newEvent = items as! Event
            event.append(newEvent)
            
        }
        
        //var nextView = EventsTableViewController()
        
        //hide activity indicator
        hideActivityIndicator()
        
        if event.isEmpty {
            //error alert
            amazonDb().presentAlert("Error", body: "Did not receive any events matching the query", view: self)
        } else {
            //perform segue
            performSegueWithIdentifier("showEvents", sender: nil)
        }
    }

    func setDateLimits(){
        let date = datePicker.date
        let cal = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let midnightDate = cal.startOfDayForDate(date)
        let dayComponent = NSDateComponents()
        dayComponent.day = 1
        let theCalendar = NSCalendar.currentCalendar()
        let nextDate = theCalendar.dateByAddingComponents(dayComponent, toDate: midnightDate, options: .MatchFirst)
        
        let midnight = amazonDb().dateToUnix(midnightDate)
        let nextDay = amazonDb().dateToUnix(nextDate!)
        
        retrieveUpcomingObject(midnight, end: nextDay)
    }
    
    func showActivityIndicator() {
        dispatch_async(dispatch_get_main_queue()) {
            self.loadingView = UIView()
            self.loadingView.frame = CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0)
            self.loadingView.center = self.view.center
            self.loadingView.backgroundColor = UIColor.grayColor()
            self.loadingView.alpha = 0.7
            self.loadingView.clipsToBounds = true
            self.loadingView.layer.cornerRadius = 10
            
            self.spinner = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
            self.spinner.frame = CGRect(x: 0.0, y: 0.0, width: 80.0, height: 80.0)
            self.spinner.center = CGPoint(x:self.loadingView.bounds.size.width / 2, y:self.loadingView.bounds.size.height / 2)
            
            self.loadingView.addSubview(self.spinner)
            self.view.addSubview(self.loadingView)
            self.spinner.startAnimating()
        }
    }
    
    func hideActivityIndicator() {
        dispatch_async(dispatch_get_main_queue()) {
            self.spinner.stopAnimating()
            self.loadingView.removeFromSuperview()
        }
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
    var nextView = segue.destinationViewController as! UINavigationController
        let myView = nextView.topViewController as! EventsTableViewController
        
        
        myView.events = event

    }
    
    @IBAction func cancelViewEvents(segue: UIStoryboardSegue) {
        //nada
    }
    
    //MARK: PICKERVIEW SET-UP
    
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == eventPickerView {
            return pickerData.count
        } else if pickerView == eventTypePickerView {
            return eventTypeData.count
        } else {
            return 1
        }
    }
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if pickerView.tag == 1 {
            return pickerData[row]
        } else {
            return eventTypeData[row]
        }
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if pickerView.tag == 1 {
            eventField.text = pickerData[row]
            hidePickers()
        } else {
            eventTypeField.text = eventTypeData[row]
            showCorrectObjects()
            hidePickers()
        }
        
    }
    
    func datePickerChanged() {
        let dateFormatter = NSDateFormatter()
        let date = datePicker.date
        
        dateFormatter.dateFormat = "MMM dd yyyy"
        
        let dateString = dateFormatter.stringFromDate(date)
        startField.text = dateString
        print(dateString)
        
        datePicker.hidden = true
        setDateBtn.hidden = true
    }
    

}

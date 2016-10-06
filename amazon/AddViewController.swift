//
//  AddViewController.swift
//  amazon
//
//  Created by O'Brien, Patrick (Synchrony Financial) on 7/20/16.
//  Copyright © 2016 O'Brien, Patrick (Synchrony Financial). All rights reserved.
//

import UIKit
import AWSDynamoDB

class AddViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextViewDelegate, UITextFieldDelegate {
    
    var selectedField : UITextField?
    
    //picker view to handle inputs for the price of the book
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var eventPicker: UIPickerView!
    
    //text fields for inputs for saving the book
    @IBOutlet weak var eventField: UITextField!
    @IBOutlet weak var ownerField: UITextField!
    @IBOutlet weak var detailsField: UITextView!
    @IBOutlet weak var startDateField: UITextField!
    @IBOutlet weak var endDateField: UITextField!
    @IBOutlet weak var coownerField: UITextField!
    
    
    //labels
    @IBOutlet weak var lblEventTitle: UILabel!
    @IBOutlet weak var lblStartDate: UILabel!
    @IBOutlet weak var lblEndDate: UILabel!
    @IBOutlet weak var lblOwner: UILabel!
    @IBOutlet weak var lblDetails: UILabel!
    
    //btns
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var btnDone: UIButton!
    
    
    
    var eventPickerData = ["Hackathon", "Bagel Monday", "Bolt Session", "IS Tour", "Volunteering Event"]
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        eventField.delegate = self
        startDateField.delegate = self
        endDateField.delegate = self
        
        eventPicker.dataSource = self
        eventPicker.delegate = self
        btnDone.hidden = true
    
        eventPicker.hidden = true
        datePicker.hidden = true
        
      //  self.view.addSubview(eventPicker)
        
        //adding border to textView
        detailsField!.layer.borderWidth = 1
        detailsField.layer.borderColor = UIColor.lightGrayColor().CGColor
        
        btnSave.backgroundColor = UIColor.synchronyGreen()
        btnSave.addTarget(self, action: #selector(AddViewController.setEvent), forControlEvents: .TouchUpInside)
        
        btnDone.addTarget(self, action: #selector(AddViewController.datePickerValueChanged), forControlEvents: .TouchUpInside)
        ownerField.addTarget(self, action: #selector(AddViewController.hideAllPickerViews(_:)), forControlEvents: .AllEditingEvents)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldBeginEditing(textField: UITextField!) -> Bool {
        if textField == eventField {
            showEventPicker()
            return false
        } else if textField == startDateField {
            showDatePickerSetStart()
            return false
        } else if textField == endDateField {
            showDatePickerSetEnd()
            return false
        } else {
            return true
        }
    }
    
    func setEvent () {
        var newEvent = Event()
        
        if (eventField.text == "" || startDateField.text == "" || ownerField.text == "" || detailsField.text == "" || endDateField.text == "") {
            
            //validation alert is from the DynamoDBManager.swift class called amazondb using the alert function
            let amz = amazonDb()
            amz.presentAlert("Validation Error", body: "All fields must be completed (unless there is no co-owner).", view: self)
            
        } else {
        newEvent.event = eventField.text!
        newEvent.leader = ownerField.text!
        newEvent.details = detailsField.text!
            
//            var sepStartArray = startDateField.text?.componentsSeparatedByString(" ")
//            var startDate = "\(sepStartArray![0]) \(sepStartArray![1]) \(sepStartArray![2])"
//            var truncStart = String(startDate.characters.dropLast())
//            var startTime = "\(sepStartArray![3]) \(sepStartArray![4])"
//            
//            var sepEndArray = endDateField.text?.componentsSeparatedByString(" ")
//            var endDate = "\(sepEndArray![0]) \(sepEndArray![1]) \(sepEndArray![2])"
//            var truncEnd = String(endDate.characters.dropLast())
//            var endTime = "\(sepEndArray![3]) \(sepEndArray![4])"
           
        let dynamo = amazonDb()
            
        newEvent.startDate = dynamo.dateStringToUnix(startDateField.text!)
        newEvent.endDate = dynamo.dateStringToUnix(endDateField.text!)

            if coownerField.text == "" {
                newEvent.coOwner = "None"
            } else {
                newEvent.coOwner = coownerField.text!
            }
            
           var dynamoManager = amazonDb()
            dynamoManager.saveRow(newEvent, view: self)
        }
        clearFields()
    }
    
    func clearFields () {
        eventField.text = ""
        ownerField.text = ""
        detailsField.text = ""
        startDateField.text = ""
        endDateField.text = ""
        coownerField.text = ""
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    //MARK: Data Sources
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return eventPickerData.count
    }
    
    //MARK: Delegates
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return eventPickerData[row]
    }
    
    func showEventPicker() {
        eventPicker.hidden = false
        datePicker.hidden = true
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        eventField.text = eventPickerData[row]
        eventPicker.hidden = true
        self.eventPicker.endEditing(true)
    }
    
    
    func showDatePickerSetStart () {
        datePicker.hidden = false
        eventPicker.hidden = true
        btnDone.hidden = false
        
        selectedField = startDateField
    }
    
    func showDatePickerSetEnd () {
        datePicker.hidden = false
        eventPicker.hidden = true
        btnDone.hidden = false
        
        selectedField = endDateField
    }
    
    func datePickerValueChanged (){
        var dateFormatter = NSDateFormatter()
        
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        
        var strDate = dateFormatter.stringFromDate(datePicker.date)
        
        selectedField?.text = strDate
        
        datePicker.hidden = true
        btnDone.hidden = true
    }
    
    func hideAllPickerViews (sender: UITextField) {
        eventPicker.hidden = true
        datePicker.hidden = true
        btnDone.hidden = true
    }
    
    func hideAllPickerViewsNoSender() {
        eventPicker.hidden = true
        datePicker.hidden = true
        btnDone.hidden = true
        
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        hideAllPickerViewsNoSender()
    }
    

    
    
}

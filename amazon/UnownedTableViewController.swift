//
//  UnownedTableViewController.swift
//  amazon
//
//  Created by O'Brien, Patrick (Synchrony Financial) on 10/3/16.
//  Copyright © 2016 O'Brien, Patrick (Synchrony Financial). All rights reserved.
//

import UIKit

class UnownedTableViewController: UITableViewController {
    
    var unownedArray = [Event]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = 70
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return unownedArray.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "unownedTableViewCell"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! unownedTableViewCell
        
        let event = unownedArray[indexPath.row]
        
            cell.lblEventTitle.text = event.event
            var startString = event.startDate
            var dateString = amazonDb().unixToDateFormat(startString)
            var stringArr = dateString.componentsSeparatedByString(" ")
            var dateNum = stringArr[1].componentsSeparatedByString(",")
            var dateNumber = dateNum[0]
            cell.lblDay.text = dateNumber
            cell.lblMonth.text = stringArr[0].uppercaseString
            cell.btnSignUp.tag = indexPath.row
            cell.btnSignUp.addTarget(self, action: "signUpClicked:", forControlEvents: .TouchUpInside)
        
        return cell
    }
    
    func handleSegue() {
        
    }
    
    func signUpClicked (sender: UIButton) {
        let defaults = NSUserDefaults()
        var path = sender.tag
        var choiceEvent = unownedArray[path]
        if let name = defaults.objectForKey("username") {
            choiceEvent.leader = name as! String
            saveObject(choiceEvent)
        } else {
            askForName()
        }
    }
    
    func askForName() {
        let defaults = NSUserDefaults()
        let alertController = UIAlertController(title: "Please enter your name", message: "", preferredStyle: .Alert)
        alertController.addTextFieldWithConfigurationHandler { (textField: UITextField!) -> Void in
            textField.placeholder = "Enter Full Name"
        }
        alertController.addAction(UIAlertAction(title: "Done", style: .Default, handler: {
            alert -> Void in
            
            let nameTextField = alertController.textFields![0] as UITextField
            if let nameValue = nameTextField.text {
                defaults.setObject(nameValue, forKey: "username")
            }
        }))
        self.presentViewController(alertController, animated: true, completion: nil)
        alertController.view.tintColor = UIColor.synchronyGreen()
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
        //save first
        let defaults = NSUserDefaults()
        let dynamo = amazonDb()
        let myKey = "myEvents"
        
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

        
       //segue out
        performSegueWithIdentifier("segueToHomeTabController", sender: self)
    }
    
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

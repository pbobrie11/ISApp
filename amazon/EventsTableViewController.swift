//
//  EventsTableViewController.swift
//  amazon
//
//  Created by O'Brien, Patrick (Synchrony Financial) on 7/25/16.
//  Copyright © 2016 O'Brien, Patrick (Synchrony Financial). All rights reserved.
//

import UIKit

class EventsTableViewController: UITableViewController {

    var detailedView = UIView()
    
    var events = [Event]()
    
    var eventTitle : String = ""
    var startDate : String = ""
    var endDate : String = ""
    var owner : String = ""
    var details : String = ""
    
    //need a variable to handle the users choice of event to determine how the cells will be populated
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        navigationController?.navigationBar.tintColor = UIColor.charcoalGray()
        self.tableView.separatorColor = UIColor.steelGray()
        
        self.navigationItem.hidesBackButton = false
        
        //set EDIT functionality with navigation bar button on Right of nav bar
        navigationItem.rightBarButtonItem = editButtonItem()
    
        //sets the title by taking the search terms and making it plural
        if events.isEmpty {
            self.title = "No Events"
        } else {
            var event = events[0].event
            var eventString = event + "s"
            self.title = eventString
        }
        
        self.tableView.rowHeight = 70
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return events.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "EventTableViewCell"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! EventTableViewCell
        
        for specEvent in events {
            
                let event = events[indexPath.row]
            
                switch specEvent.event {
                    case "Hackathon":
                        if event.topic != "" {
                            cell.lblTitle.text = event.topic
                        } else {
                            cell.lblTitle.text = "Hackathon"
                        }
                    case "Bolt Session":
                        if event.topic != "" {
                            cell.lblTitle.text = event.topic
                        } else {
                            cell.lblTitle.text = "Bolt Session"
                        }
                    case "Bagel Monday":
                        if event.leader != "" || event.leader != "none" || event.leader != "None" {
                            cell.lblTitle.text = event.leader
                        } else {
                            cell.lblTitle.text = "No Owner"
                    }
                    case "Volunteer Event":
                        if event.leader != "" || event.leader != "none" || event.leader != "None" {
                            cell.lblTitle.text = event.leader
                        } else {
                            cell.lblTitle.text = "Volunteer Event"
                    }
                    case "IS Tour":
                        if event.topic != "" {
                            cell.lblTitle.text = event.topic
                        } else {
                            cell.lblTitle.text = "IS Tour"
                        }
                    default:
                        break
            }
            
            let dynamo = amazonDb()
            
            var startString = event.startDate
            var dateString = amazonDb().unixToDateFormat(startString)
            var stringArr = dateString.componentsSeparatedByString(" ")
            var dateNum = stringArr[1].componentsSeparatedByString(",")
            var dateNumber = dateNum[0]
            cell.lblNumber.text = dateNumber
            cell.lblMonth.text = stringArr[0].uppercaseString
        
        
        }

        // Configure the cell...

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
      //  performSegueWithIdentifier("showDetail", sender: indexPath)
        
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
   // override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject) {
        

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "backToSearch" {
            //clear both tables so that we don't get old data stored in the table
            events = []
            
            var vc = pullObjectViewController()
            vc.event.removeAll()
            print(vc.event)
            
        } else if segue.identifier == "showDetail" {
            var nextView = segue.destinationViewController as! UINavigationController
            let myView = nextView.topViewController as! DetailViewController
            
            print(sender)
            
            var path = 0
            
            if (sender is UITableViewCell) {
                let cell = sender as! UITableViewCell
                let index = self.tableView.indexPathForCell(cell)
                let row = index?.row
                path = row!
            } else if (sender is NSIndexPath) {
                path = (sender?.row)!
            }
            
            
            myView.detailEvent = events[path]
        }
    }
    @IBAction func unwindToEventsTable(segue: UIStoryboardSegue) {
        
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            //delete row from db
            //need to reimplement the delete method
            events.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            
        }
    }

}

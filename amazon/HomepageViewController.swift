//
//  HomepageViewController.swift
//  amazon
//
//  Created by O'Brien, Patrick (Synchrony Financial) on 8/29/16.
//  Copyright © 2016 O'Brien, Patrick (Synchrony Financial). All rights reserved.
//

import UIKit
import AWSDynamoDB

class HomepageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var eventsAndRemindersTableView: UITableView!
    @IBOutlet weak var upcomingTableView: UITableView!
    
    @IBOutlet weak var topLineView: UIView!
    @IBOutlet weak var bottomLineView: UIView!
    @IBOutlet weak var alertView: UIView!
    
    @IBOutlet weak var lblEventsAndReminders: UILabel!
    @IBOutlet weak var lblUpcomingEvents: UILabel!
    
    
    @IBOutlet weak var btnUser: UIButton!
    
    //constraints to set and alter based on device / whether there is an unowned event to sign up for
    @IBOutlet weak var myEventsHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var upcomingTableHeight: NSLayoutConstraint!
    @IBOutlet weak var unownedAlertViewHeight: NSLayoutConstraint!
    @IBOutlet weak var stackviewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var heightToAlertConstraint: NSLayoutConstraint!

    //@IBOutlet weak var exclamationImageHeight: NSLayoutConstraint!
    //@IBOutlet weak var lblAlertHeight: NSLayoutConstraint!
    
    
    //components within alert view
    //@IBOutlet weak var alertImageView: UIImageView!
    //@IBOutlet weak var lblAlert: UILabel!
    
    @IBOutlet var tapRecognizer: UITapGestureRecognizer!
    
    
    var nextEvents = [Event]()
    var myEventsAndReminders = [myEvent]()
    var unowned = [Event]()
    
    var hasLoaded : Bool = false
    let myKey = "myEvents"
    let defaults = NSUserDefaults()
    
    let halfScreen = (UIScreen.mainScreen().bounds.width) / 2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationItem.setHidesBackButton(true, animated: true)
        
        eventsAndRemindersTableView.allowsSelection = false
        upcomingTableView.allowsSelection = false
        
        alertView.backgroundColor = UIColor.clearColor()
        checkPhoneModel()
        setEventsAndReminders()
        checkTime()
        retrieveUnownedObjects()
    
        setStyle()
        
        //keep view hidden
        unownedAlertViewHeight.constant = 0
        stackviewHeightConstraint.constant = 0
        heightToAlertConstraint.constant = 7
        
        upcomingTableView.reloadData()
        eventsAndRemindersTableView.reloadData()
        
        tapRecognizer.addTarget(self, action: "segueToUnowned:")
        
       btnUser.addTarget(self, action: "askForName", forControlEvents: .TouchUpInside)
    
    }
    
    func checkPhoneModel() {
        //check device model
        let modelName = UIDevice.currentDevice().modelName
        
        //set height of table based on device --> if device is an iPhone 5 or 5s set tableview heights to 140 instead of 210
        let smalliPhones = ["iPhone 5", "iPhone 5c", "iPhone 5s", "iPhone 4s", "iPhone 4"]
        
        if smalliPhones.contains(modelName) {
            print("old iPhone")
            myEventsHeightConstraint.constant = 140
            upcomingTableHeight.constant = 140
        } else {
            myEventsHeightConstraint.constant = 210
            upcomingTableHeight.constant = 210
        }

    }
    
    func setStyle() {
        //outline for the alert for unowned events
       ////////////////////////////////// unownedAlertViewHeight.constant = 0
        alertView.layer.cornerRadius = 5
        alertView.layer.borderWidth = 1
        alertView.layer.borderColor = UIColor.synchronyGold().CGColor
        
        //label coloring
        lblEventsAndReminders.textColor = UIColor.charcoalGray()
        lblUpcomingEvents.textColor = UIColor.charcoalGray()
        
        //set divider color
        self.upcomingTableView.separatorColor = UIColor.steelGray()
        self.eventsAndRemindersTableView.separatorColor = UIColor.steelGray()
        self.eventsAndRemindersTableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        
        //  ------ set background of tables, delegates and data source -------- //
        
        //datasource
        upcomingTableView.dataSource = self
        eventsAndRemindersTableView.dataSource = self
        
        //delegates
        self.eventsAndRemindersTableView.delegate = self
        self.upcomingTableView.delegate = self
        
        //row heights
        self.eventsAndRemindersTableView.rowHeight = 70
        self.upcomingTableView.rowHeight = 70
        
        
        //setting lines above table
        topLineView.backgroundColor = UIColor.synchronyGreen()
        bottomLineView.backgroundColor = UIColor.synchronyGreen()
        
        //checkSetScroll checks to see if table arrays have more than 3 values, if they do then the table can scroll through the other values. otherwise, no dice: table is static.
        checkSetScroll()
    }
    
    func segueToUnowned(recognizer: UITapGestureRecognizer) {
        performSegueWithIdentifier("showUnowned", sender: self)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == upcomingTableView {
            if nextEvents.isEmpty {
                return 1
            } else {
             return nextEvents.count
            }
        } else if tableView == eventsAndRemindersTableView {
            return self.myEventsAndReminders.count
        } else {
            return 3
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        checkName()
        
        let amazon = amazonDb()
        
        if tableView == self.upcomingTableView {
            let cellIdentifier = "UpcomingTableViewCell"
            
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! UpcomingTableViewCell
            if nextEvents.isEmpty {
                setUpcoming()
            } else {
                //nothing needed i think
            }
            
            for specEvent in nextEvents {
                
                let event = nextEvents[indexPath.row]
                
                if event.event == "" && event.startDate == 0 {
                    cell.lblTitle.text = "No Upcoming"
                    cell.lblMonth.text = ""
                    cell.lblNumber.text = ""
                } else {
                    cell.lblTitle.text = event.event
                    var startString = event.startDate
                    var dateString = amazonDb().unixToDateFormat(startString)
                    var stringArr = dateString.componentsSeparatedByString(" ")
                    var dateNum = stringArr[1].componentsSeparatedByString(",")
                    var dateNumber = dateNum[0]
                    cell.lblNumber.text = dateNumber
                    cell.lblMonth.text = stringArr[0].uppercaseString
                }
        }
    
        return cell
        } else if tableView == eventsAndRemindersTableView  {
            let cellIdentifier = "myEventsTableViewCell"
            
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! myEventsTableViewCell
            
            for specEvent in myEventsAndReminders {
                
                let event = myEventsAndReminders[indexPath.row]
                
                cell.lblEventTitle.text = event.event
                
                let date = NSDate()
                let today = amazonDb().dateToUnix(date)
                if specEvent.startDate < today {
                    cell.lblDateNum.text = ""
                    cell.lblDateDay.text = ""
                } else {
                    var stringDate = amazonDb().unixToDateFormat(event.startDate)
                    var stringArr = stringDate.componentsSeparatedByString(" ")
                    var dateNum = stringArr[1].componentsSeparatedByString(",")
                    var dateNumber = dateNum[0]
                    cell.lblDateNum.text = dateNumber
                    cell.lblDateDay.text = stringArr[0].uppercaseString
                }
            }
            return cell
            
        } else {
            var genericCell = UITableViewCell()
            return genericCell
        }
        
    }
    
    func checkSetScroll() {
        //upcoming events
        if (upcomingTableView.contentSize.height < upcomingTableView.frame.size.height) {
            upcomingTableView.scrollEnabled = false
        } else {
           upcomingTableView.scrollEnabled = true
        }
        //events and reminders
        if (eventsAndRemindersTableView.contentSize.height < eventsAndRemindersTableView.frame.size.height) {
            eventsAndRemindersTableView.scrollEnabled = false
        } else {
            eventsAndRemindersTableView .scrollEnabled = true
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        setEventsAndReminders()
    }
    
    func setBlankEvents() {
        if myEventsAndReminders.isEmpty {
            let blankEvent = myEvent(event: "No Events", startDate: 0, endDate: 0, leader: "", details: "", coOwner: "", topic: "", eventDate: NSDate())
            myEventsAndReminders.append(blankEvent!)
        } else {
            //nothing
        }
    }
    
    func setEventsAndReminders() {
        if (defaults.objectForKey(myKey) == nil) {
            setBlankEvents()
        } else {
            myEventsAndReminders.removeAll()
            if amazonDb().unpackAndClean() {
                let defaults = NSUserDefaults()
                let myKey = "myEvents"
                var oldInfo = defaults.objectForKey(myKey) as! NSData
                var oldInfoUnkeyed = NSKeyedUnarchiver.unarchiveObjectWithData(oldInfo) as! NSArray
                
                for entry in oldInfoUnkeyed {
                    var newInfo = entry as! myEvent
                    myEventsAndReminders.append(newInfo)
                }
            } else {
                setBlankEvents()
            }

            }
                    eventsAndRemindersTableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func checkTime() {
        let amazon = amazonDb()
        let date = NSDate()
        let cal = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let midnightDate = cal.startOfDayForDate(date)
        
        let currentUnix = amazon.dateToUnix(midnightDate)
        let futureUnix = amazon.getWeekFromNowUnixTime(midnightDate)
        
        retrieveUpcomingObject(currentUnix, end: futureUnix)
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
                self.parseUpcoming(task)
                
            }
            return nil
        })
    }
    
    func retrieveUnownedObjects () {
        
        let scanExpression = AWSDynamoDBScanExpression()
        scanExpression.limit = 5
        scanExpression.filterExpression = "leader = :name"
        scanExpression.expressionAttributeValues = [":name" : "none"]
        
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
                self.parseUnowned(task)
                
            }
            return nil
        })
    }
    
    func parseUnowned(output: AWSTask) {
        let tableRow = output.result as! AWSDynamoDBPaginatedOutput
        
        var response = tableRow.items

            for (items) in tableRow.items {
                var newEvent = items as! Event
                unowned.append(newEvent)
            }
        
        if unowned.isEmpty {
            //keep view hidden
            unownedAlertViewHeight.constant = 0
            stackviewHeightConstraint.constant = 0
            heightToAlertConstraint.constant = 5
        } else {
            UIView.animateWithDuration(3, animations: {
                self.alertView.backgroundColor = UIColor.clearColor()
                self.unownedAlertViewHeight.constant = 60
                self.heightToAlertConstraint.constant = 5
                self.stackviewHeightConstraint.constant = 60
            })
        }
    }
    
    func parseUpcoming(output: AWSTask) {
        
        let tableRow = output.result as! AWSDynamoDBPaginatedOutput
        
        var response = tableRow.items
        
        nextEvents.removeAll()
        if response.isEmpty {
            //is there anything in nextEvents dict?
        } else {
            for (items) in tableRow.items {
                var newEvent = items as! Event
                nextEvents.append(newEvent)
            }
        }
        

        upcomingTableView.reloadData()
    }
    
    func setUpcoming() {
        if nextEvents.count == 0 {
            //set blank event for table
            var newEvent = Event()
            newEvent.event = ""
            newEvent.startDate = 0
            nextEvents.append(newEvent)
        }
    }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showUnowned" {
            //send unowned objects to unowned tableviewcontroller
            var next = segue.destinationViewController as! UINavigationController
            let nextView = next.topViewController as! UnownedTableViewController
            nextView.unownedArray = unowned
        }
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)
        navigationController?.navigationItem.setHidesBackButton(true, animated: true)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
    }
    
    func checkName() {
        if let name = defaults.objectForKey("username") {
            //do thing since the user has already signed in
        } else {
            askForName()
        }
    }
    
    func askForName() {
        let alertController = UIAlertController(title: "Please enter your name", message: "", preferredStyle: .Alert)
        alertController.addTextFieldWithConfigurationHandler { (textField: UITextField!) -> Void in
            textField.placeholder = "Enter Full Name"
        }
        alertController.addAction(UIAlertAction(title: "Done", style: .Default, handler: {
            alert -> Void in
            
            let nameTextField = alertController.textFields![0] as UITextField
            if let nameValue = nameTextField.text {
                self.defaults.setObject(nameValue, forKey: "username")
            }
        }))
        self.presentViewController(alertController, animated: true, completion: nil)
        alertController.view.tintColor = UIColor.synchronyGreen()
    }
    
}

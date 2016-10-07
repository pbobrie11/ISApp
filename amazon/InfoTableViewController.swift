//
//  InfoTableViewController.swift
//  amazon
//
//  Created by O'Brien, Patrick (Synchrony Financial) on 8/11/16.
//  Copyright © 2016 O'Brien, Patrick (Synchrony Financial). All rights reserved.
//

import UIKit
import AWSDynamoDB

class InfoTableViewController: UITableViewController {
    
    @IBOutlet weak var infoCell: InfoTableViewCell!
  
    
    var spinner = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
    var loadingView : UIView = UIView()
    
    var detailedView = UIView()
    
    var info = [Info]()
    
    //view to handle cell selection and display the header + answer / body
    var infoView = UIView()
    var headerLabel = UILabel()
    var bodyLabel = UILabel()
    var closeButton = UIButton()
    var transperentButton = UIButton()
    
    override func viewDidLoad() {
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 80
        
        super.viewDidLoad()
        
        setView()
        
        
        self.navigationItem.hidesBackButton = false
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "handleTap:"))
        
    }
    
    func setView() {
        infoView.hidden = true
        transperentButton.hidden = true
        
        //set transperent button to allow for closing of views on tap outside
        transperentButton.frame = tableView.bounds
        transperentButton.backgroundColor = UIColor.clearColor()
        //self.tableView.insertSubview(transperentButton, belowSubview: infoView)
        
        //infoView frame and adding as subview
        let findY = ((self.view.frame.size.height-400) / 2)
        
        infoView.frame = CGRect(x: 20, y: findY, width: self.view.frame.size.width-40, height: 200)
        self.navigationController?.view.insertSubview(infoView, belowSubview: (self.navigationController?.navigationBar)!)
        
        
        let labelWidth = infoView.frame.size.width-40
        
        //header label
        headerLabel.frame = CGRectMake(10,20,labelWidth,21)
        headerLabel.textAlignment = NSTextAlignment.Center
        headerLabel.text = "header"
        infoView.addSubview(headerLabel)
        
        //add body label
        bodyLabel.frame = CGRectMake(10,10,labelWidth,144)
        bodyLabel.textAlignment = NSTextAlignment.Center
        bodyLabel.text = "this is the body of the label it will hold all the awesome information from the db"
        bodyLabel.numberOfLines = 6
        
        infoView.addSubview(bodyLabel)
        
        //adding close button
        var xPos = (((infoView.frame.size.width)/2)-2.5)
        closeButton.frame = CGRectMake(xPos, 160, infoView.frame.size.width-40, 30)
        closeButton.titleLabel?.textAlignment = .Center
        closeButton.setTitle("CLOSE", forState: UIControlState.Normal)
        closeButton.addTarget(self, action: "dismissView", forControlEvents: .TouchUpInside)
        infoView.addSubview(closeButton)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            infoView.hidden = true
        }
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        infoView.hidden = true
    }
    
    func handleTap(sender: UITapGestureRecognizer) {
        if sender.state == .Ended {
            infoView.hidden = true
        }
        
        sender.cancelsTouchesInView = false
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
        return info.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "InfoTableViewCell"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! InfoTableViewCell
        
        let specInfo = info[indexPath.row]
        cell.lblHeader.text = specInfo.header
        cell.lblBody.text = specInfo.details
        
        
        // Configure the cell...
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        let row = indexPath.row
        var header = info[row].header
        var body = info[row].details
        
        //toggleView(header, body: body)
    }
    
    func toggleView(header: String, body: String) {
        if infoView.hidden == true {
            headerLabel.text = header
            bodyLabel.text = body
            infoView.hidden = false
            //transperentButton.hidden = false
        } else {
            infoView.hidden = true
            //transperentButton.hidden = true
        }
    }
    
    func dismissView() {
        if infoView.hidden == false {
            infoView.hidden = true
            print("dismiss")
        } else {
            //do nothing
            print("already dismissed")
        }
    }
    
    func retrieveObject () {
        
       // showActivityIndicator()
        
        let scanExpression = AWSDynamoDBScanExpression()
        scanExpression.limit = 5
        
        dynamoDBObjectMapper.scan(Info.self, expression: scanExpression) .continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: { (task:AWSTask!) -> AnyObject! in
            
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
                
                output = task.result as! AWSDynamoDBPaginatedOutput
                
                //parse response
                self.parseResponse(task)
                
                print(output.items)
                
            }
            return nil
        })

    }
    
    func parseResponse(output: AWSTask) {
        
        let tableRow = output.result as! AWSDynamoDBPaginatedOutput
        
        var response = tableRow.items
        
        for (items) in tableRow.items {
            var newInfo = items as! Info
            info.append(newInfo)
        }
        
        
        if info.isEmpty {
            self.title = "NO INFO"
        } else {
            self.title = "INNOVATION STATION INFORMATION"
        }
        
        //hide activity indicator
       self.tableView.reloadData()
        
        //set default for last date of successful db update
        //want to update every week
        var defaults = NSUserDefaults()
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        
        var dateStart = calendar.startOfDayForDate(date)

        defaults.setObject(dateStart, forKey: "lastInfoRequest")
        
        var dictAsData = NSKeyedArchiver.archivedDataWithRootObject(info)
        defaults.setObject(dictAsData, forKey: "info")
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
    
    func clearTable() {
        info.removeAll()
        tableView.reloadData()
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
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    // override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject) {
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "backToSearch" {
            //clear both tables so that we don't get old data stored in the table
            info = []
            
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
            
            
           // myView.detailEvent = info[path]
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
         clearTable()
        
        var calendar = NSCalendar.currentCalendar()
        var date = NSDate()
        let flags = NSCalendarUnit.Day
        var defaults = NSUserDefaults()
        if let lastPull = defaults.objectForKey("lastInfoRequest") as? NSDate {
            let components = calendar.components(flags, fromDate: lastPull, toDate: date, options: [])
            
            if components.day >= 8 {
                retrieveObject()
            } else {
                print(defaults.objectForKey("info"))
                
                print("line")
                var oldInfo = defaults.objectForKey("info") as! NSData
                var oldInfoUnkeyed = NSKeyedUnarchiver.unarchiveObjectWithData(oldInfo) as! NSArray
                
                for entry in oldInfoUnkeyed {
                    var newInfo = entry as! Info
                    info.append(newInfo)
                }
                
                print(info)
                //info.append(oldInfoUnkeyed)
            }
        } else {
             clearTable()
            retrieveObject()
        }
        
        self.tableView.reloadData()
    }
    
    @IBAction func unwindToEventsTable(segue: UIStoryboardSegue) {
        
    }

}

extension String {
    func heightWithConstrainedWidth(width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: CGFloat.max)
        let boundBox = self.boundingRectWithSize(constraintRect, options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        
        return boundBox.height
    }
}

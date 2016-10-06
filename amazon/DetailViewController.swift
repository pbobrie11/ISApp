//
//  DetailViewController.swift
//  amazon
//
//  Created by O'Brien, Patrick (Synchrony Financial) on 8/24/16.
//  Copyright © 2016 O'Brien, Patrick (Synchrony Financial). All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    var detailEvent = Event()
    let dynamo = amazonDb()

    
    @IBOutlet weak var owner: UILabel!
    
    @IBOutlet weak var startDate: UILabel!
    
    @IBOutlet weak var lblStartTime: UILabel!
    
    @IBOutlet weak var endDate: UILabel!
    
    @IBOutlet weak var lblEndTime: UILabel!
    
    @IBOutlet weak var lblDetail: UILabel!
    
    @IBOutlet weak var btnReminder: UIButton!
    
    @IBOutlet weak var lblTopicHost: UILabel!
    
    @IBOutlet weak var topLineView: UIView!
    @IBOutlet weak var bottomLineView: UIView!
    
    var reminderView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //navbar button color
        self.navigationController?.navigationBar.tintColor = UIColor.charcoalGray()
        
        topLineView.backgroundColor = UIColor.synchronyGreen()
        
        bottomLineView.backgroundColor = UIColor.synchronyGold()
        
        //setFakeEvent()
        
        setLabels()
        
        setStyle()
        
        btnReminder.backgroundColor = UIColor.synchronyGreen()
        btnReminder.titleLabel?.textColor = UIColor.blackColor()
        btnReminder.layer.cornerRadius = 10
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setFakeEvent() {
        var newEvent = Event()
        newEvent.event = "Hackathon"
        newEvent.startDate = 1474621200
        newEvent.endDate = 1475226000
        newEvent.leader = "Dan"
        newEvent.coOwner = "none"
        newEvent.details = "Alexa helping out SYF"
        newEvent.topic = "Amazon Echo"
        detailEvent = newEvent
    }
    
    func setLabels() {
        //set title by taking event title
        
//        if detailEvent.event == "Hackathon" {
//            lblTopic.text = "Topic"
//        } else if detailEvent.event == "Bolt Session" {
//            lblTopic.text = "Host"
//        } else if detailEvent.event == "IS Tour" {
//            lblTopic.text = "Guest"
//        } else if detailEvent.event == "Bagel Monday" {
//            //no idea
//            lblTopic.hidden = true
//            lblTopicHost.hidden = true
//        } else if detailEvent.event == "Volunteer Event" {
//            lblTopic.text = "Partner"
//        }
        
        if detailEvent.topic == "" || detailEvent.topic == "none" {
            lblTopicHost.text = "None"
        } else {
            lblTopicHost.text = detailEvent.topic
        }
        
        if detailEvent.event == "" || detailEvent.event == "none" {
            self.title = "None"
        } else {
            self.title = detailEvent.event
        }
        
        if detailEvent.leader == "" || detailEvent.leader == "none" {
            owner.text = "None"
        } else if detailEvent.leader != "" && detailEvent.coOwner == "none" {
            owner.text = detailEvent.leader
        } else {
            owner.text = detailEvent.leader + ", " + detailEvent.coOwner
        }
        
        if detailEvent.details == "" || detailEvent.details == "none" {
            lblDetail.text = "None"
        } else {
            lblDetail.text = detailEvent.details
        }
        
        
        //dates
        let startDateString = amazonDb().unixToTimeFirstDateFormat(detailEvent.startDate)
        let endDateString = amazonDb().unixToTimeFirstDateFormat(detailEvent.endDate)
        let startArray = startDateString.componentsSeparatedByString(" ")

        let startTime = startArray[0] + " " + startArray[1]
        let startDay = startArray[2] + " " + startArray[3] + " " + startArray[4]
        let endArray = endDateString.componentsSeparatedByString(" ")
        let endTime = endArray[0] + " " + endArray[1]
        let endDay = endArray[2] + " " + endArray[3] + " " + endArray[4]
        
        startDate.text = startDay
        lblStartTime.text = startTime
        endDate.text = endDay
        lblEndTime.text = endTime
    }
    
    func setStyle () {
       
    }
    
    @IBAction func unwindToDetail(segue: UIStoryboardSegue) {
        
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "showEdit" {
        var nextView = segue.destinationViewController as! EditEventViewController
        nextView.oldEvent = detailEvent
        } else if segue.identifier == "showReminder" {
            var next = segue.destinationViewController as! UINavigationController
            let nextView = next.topViewController as! AddReminderViewController
            nextView.event = detailEvent
        }
    }
    
    
    
    
}

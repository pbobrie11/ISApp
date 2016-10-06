//
//  EventsViewController.swift
//  amazon
//
//  Created by O'Brien, Patrick (Synchrony Financial) on 7/22/16.
//  Copyright © 2016 O'Brien, Patrick (Synchrony Financial). All rights reserved.
//

import UIKit

class EventsViewController: UIViewController {

    @IBOutlet weak var lblEvent: UILabel!
    @IBOutlet weak var lblDetails: UILabel!
    
    var event = [Event]()
    
    var eventTitle : String = ""
    var startDate : Double = 0
    var endDate : Double = 0
    var owner : String = ""
    var details : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for events in event {
            eventTitle = events.event
            startDate = events.startDate
            endDate = events.endDate
            owner = events.leader
            details = events.details
        }
        
        lblEvent.text = "The next \(eventTitle) is going to be on \(startDate)"
        lblDetails.text = details

        // Do any additional setup after loading the view.
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

}

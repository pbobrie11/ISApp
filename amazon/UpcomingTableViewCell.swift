//
//  UpcomingTableViewCell.swift
//  amazon
//
//  Created by O'Brien, Patrick (Synchrony Financial) on 9/19/16.
//  Copyright © 2016 O'Brien, Patrick (Synchrony Financial). All rights reserved.
//

import UIKit

class UpcomingTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lblNumber: UILabel!
    @IBOutlet weak var lblMonth: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        //set text color for all labels
        lblNumber.textColor = UIColor.charcoalGray()
        lblMonth.textColor = UIColor.charcoalGray()
        lblTitle.textColor = UIColor.charcoalGray()
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

//
//  EventTableViewCell.swift
//  amazon
//
//  Created by O'Brien, Patrick (Synchrony Financial) on 7/25/16.
//  Copyright © 2016 O'Brien, Patrick (Synchrony Financial). All rights reserved.
//

import UIKit

class EventTableViewCell: UITableViewCell {

    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblNumber: UILabel!
    @IBOutlet weak var lblMonth: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        var verticalSpaceToCell: NSLayoutConstraint
        
        verticalSpaceToCell = NSLayoutConstraint(item: lblTitle, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1.0, constant: 1.0)
        
        self.addConstraint(verticalSpaceToCell)
        
        lblMonth.textColor = UIColor.synchronyGreen()
        lblNumber.textColor = UIColor.synchronyGreen()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

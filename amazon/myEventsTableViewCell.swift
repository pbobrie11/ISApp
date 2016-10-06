//
//  myEventsTableViewCell.swift
//  amazon
//
//  Created by O'Brien, Patrick (Synchrony Financial) on 9/21/16.
//  Copyright © 2016 O'Brien, Patrick (Synchrony Financial). All rights reserved.
//

import UIKit

class myEventsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lblDateNum: UILabel!
    @IBOutlet weak var lblDateDay: UILabel!
    @IBOutlet weak var lblEventTitle: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        lblDateDay.textColor = UIColor.charcoalGray()
        lblDateNum.textColor = UIColor.charcoalGray()
        lblEventTitle.textColor = UIColor.charcoalGray()
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

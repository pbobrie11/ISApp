//
//  InfoTableViewCell.swift
//  amazon
//
//  Created by O'Brien, Patrick (Synchrony Financial) on 8/29/16.
//  Copyright © 2016 O'Brien, Patrick (Synchrony Financial). All rights reserved.
//

import UIKit

class InfoTableViewCell: UITableViewCell {

    @IBOutlet weak var lblHeader: UILabel!
    @IBOutlet weak var lblBody: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        self.selectionStyle = UITableViewCellSelectionStyle.None
        
        self.lblHeader.numberOfLines = 0
        self.lblHeader.lineBreakMode = NSLineBreakMode.ByWordWrapping
        
        self.lblBody.numberOfLines = 0
        self.lblBody.lineBreakMode = NSLineBreakMode.ByWordWrapping
        
        
        lblHeader.textColor = UIColor.synchronyGreen()
        lblBody.textColor = UIColor.charcoalGray()
        
        lblBody.font = UIFont(name: "Avenir Next", size: 17)

        // Configure the view for the selected state
    }

}

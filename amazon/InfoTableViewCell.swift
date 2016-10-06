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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        self.selectionStyle = UITableViewCellSelectionStyle.None

        // Configure the view for the selected state
    }

}

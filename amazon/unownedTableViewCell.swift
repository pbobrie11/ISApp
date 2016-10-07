//
//  unownedTableViewCell.swift
//  amazon
//
//  Created by O'Brien, Patrick (Synchrony Financial) on 10/3/16.
//  Copyright © 2016 O'Brien, Patrick (Synchrony Financial). All rights reserved.
//

import UIKit

class unownedTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lblDay: UILabel!
    @IBOutlet weak var lblMonth: UILabel!
    @IBOutlet weak var lblEventTitle: UILabel!
    @IBOutlet weak var btnSignUp: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        btnSignUp.tintColor = UIColor.synchronyGreen()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

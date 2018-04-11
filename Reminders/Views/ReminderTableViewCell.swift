//
//  ReminderTableViewCell.swift
//  Reminders
//
//  Created by Roshan on 10/04/18.
//  Copyright © 2018 Roshan. All rights reserved.
//

import UIKit

class ReminderTableViewCell: UITableViewCell {

    var reminder:Reminders?
    {
        didSet
        {
            reminderTextLabel.text = (reminder?.text) ?? ""
            reminderTimeLabel.text = (reminder?.time) ?? ""
        }
    }
    
    @IBOutlet weak var reminderTimeLabel: UILabel!
    @IBOutlet weak var reminderTextLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

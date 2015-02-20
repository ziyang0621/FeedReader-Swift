//
//  FeedTableViewCell.swift
//  RSSReader
//
//  Created by Ziyang Tan on 2/19/15.
//  Copyright (c) 2015 Ziyang Tan. All rights reserved.
//

import UIKit

class FeedTableViewCell: UITableViewCell {

    @IBOutlet weak var itemTitleLabel: UILabel!
    @IBOutlet weak var itemAuthorLabel: UILabel!
    @IBOutlet weak var itemImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

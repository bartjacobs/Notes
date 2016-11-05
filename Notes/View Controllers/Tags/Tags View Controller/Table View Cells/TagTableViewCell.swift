//
//  TagTableViewCell.swift
//  Notes
//
//  Created by Bart Jacobs on 05/11/16.
//  Copyright © 2016 Cocoacasts. All rights reserved.
//

import UIKit

class TagTableViewCell: UITableViewCell {

    // MARK: - Properties

    static let reuseIdentifier = "TagTableViewCell"

    // MARK: -

    @IBOutlet var nameLabel: UILabel!

    // MARK: - Initialization

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}

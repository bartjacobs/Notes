//
//  CategoryTableViewCell.swift
//  Notes
//
//  Created by Bart Jacobs on 03/11/16.
//  Copyright © 2016 Cocoacasts. All rights reserved.
//

import UIKit

class CategoryTableViewCell: UITableViewCell {

    // MARK: - Properties

    static let reuseIdentifier = "CategoryTableViewCell"

    // MARK: -
    
    @IBOutlet var nameLabel: UILabel!

    // MARK: - Initialization

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}

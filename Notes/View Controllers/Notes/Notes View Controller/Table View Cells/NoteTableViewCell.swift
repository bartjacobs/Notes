//
//  NoteTableViewCell.swift
//  Notes
//
//  Created by Bart Jacobs on 02/11/16.
//  Copyright © 2016 Cocoacasts. All rights reserved.
//

import UIKit

class NoteTableViewCell: UITableViewCell {

    // MARK: - Properties

    static let reuseIdentifier = "NoteTableViewCell"

    // MARK: -

    @IBOutlet var tagsLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var contentsLabel: UILabel!
    @IBOutlet var updatedAtLabel: UILabel!
    @IBOutlet var categoryColorView: UIView!

    // MARK: - Initialization

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}

//
//  NotesViewController.swift
//  Notes
//
//  Created by Bart Jacobs on 31/10/16.
//  Copyright © 2016 Cocoacasts. All rights reserved.
//

import UIKit

class NotesViewController: UIViewController {

    // MARK: - Properties

    let segueAddNoteViewController = "SegueAddNoteViewController"

    // MARK: -

    private let coreDataManager = CoreDataManager(modelName: "Notes")

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueAddNoteViewController {
            if let destinationViewController = segue.destination as? AddNoteViewController {
                destinationViewController.managedObjectContext = coreDataManager.managedObjectContext
            }
        }
    }

}

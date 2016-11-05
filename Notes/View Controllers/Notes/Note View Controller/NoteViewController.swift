//
//  NoteViewController.swift
//  Notes
//
//  Created by Bart Jacobs on 02/11/16.
//  Copyright © 2016 Cocoacasts. All rights reserved.
//

import UIKit
import CoreData

class NoteViewController: UIViewController {

    // MARK: - Properties

    let segueTagsViewController = "SegueTagsViewController"
    let segueCategoriesViewController = "SegueCategoriesViewController"

    // MARK: -
    
    @IBOutlet var tagsLabel: UILabel!
    @IBOutlet var categoryLabel: UILabel!
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var contentsTextView: UITextView!

    // MARK: -

    var note: Note?

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Edit Note"

        setupView()

        setupNotificationHandling()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // Update Note
        if let title = titleTextField.text, !title.isEmpty {
            note?.title = title
        }

        note?.updatedAt = NSDate()
        note?.contents = contentsTextView.text
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueCategoriesViewController {
            if let destinationViewController = segue.destination as? CategoriesViewController {
                // Configure View Controller
                destinationViewController.note = note
            }

        } else if segue.identifier == segueTagsViewController {
            if let destinationViewController = segue.destination as? TagsViewController {
                // Configure View Controller
                destinationViewController.note = note
            }
        }
    }

    // MARK: - View Methods

    fileprivate func setupView() {
        setupTagsLabel()
        setupCategoryLabel()
        setupTitleTextField()
        setupContentsTextView()
    }

    // MARK: -

    private func setupTagsLabel() {
        updateTagsLabel()
    }

    private func updateTagsLabel() {
        // Configure Tags Label
        tagsLabel.text = note?.alphabetizedTagsAsString ?? "No Tags"
    }

    private func setupCategoryLabel() {
        updateCategoryLabel()
    }

    private func updateCategoryLabel() {
        // Configure Category Label
        categoryLabel.text = note?.category?.name ?? "No Category"
    }

    private func setupTitleTextField() {
        // Configure Title Text Field
        titleTextField.text = note?.title
    }

    private func setupContentsTextView() {
        // Configure Contents Text View
        contentsTextView.text = note?.contents
    }

    // MARK: - Notification Handling

    func managedObjectContextObjectsDidChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        guard let updates = userInfo[NSUpdatedObjectsKey] as? Set<NSManagedObject> else { return }

        if (updates.filter { return $0 == note }).count > 0 {
            updateTagsLabel()
            updateCategoryLabel()
        }
    }

    // MARK: - Helper Methods

    private func setupNotificationHandling() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(managedObjectContextObjectsDidChange(_:)), name: Notification.Name.NSManagedObjectContextObjectsDidChange, object: note?.managedObjectContext)
    }
    
}

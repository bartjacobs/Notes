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

    let segueCategoriesViewController = "SegueCategoriesViewController"

    // MARK: -
    
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
        guard segue.identifier == segueCategoriesViewController else { return }

        if let destinationViewController = segue.destination as? CategoriesViewController {
            // Configure View Controller
            destinationViewController.note = note
        }
    }

    // MARK: - View Methods

    fileprivate func setupView() {
        setupCategoryLabel()
        setupTitleTextField()
        setupContentsTextView()
    }

    // MARK: -

    private func setupCategoryLabel() {
        updateCategoryLabel()
    }

    private func updateCategoryLabel() {
        // Configure Category Text Field
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
            updateCategoryLabel()
        }
    }

    // MARK: - Helper Methods

    private func setupNotificationHandling() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(managedObjectContextObjectsDidChange(_:)), name: Notification.Name.NSManagedObjectContextObjectsDidChange, object: note?.managedObjectContext)
    }
    
}

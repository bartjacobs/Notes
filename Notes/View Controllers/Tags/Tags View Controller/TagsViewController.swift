//
//  TagsViewController.swift
//  Notes
//
//  Created by Bart Jacobs on 05/11/16.
//  Copyright © 2016 Cocoacasts. All rights reserved.
//

import UIKit
import CoreData

class TagsViewController: UIViewController {

    // MARK: - Properties

    private let segueTagViewController = "SegueTagViewController"
    private let segueAddTagViewController = "SegueAddTagViewController"

    // MARK: -

    @IBOutlet var messageLabel: UILabel!
    @IBOutlet var tableView: UITableView!

    // MARK: -

    var note: Note?

    // MARK: -

    fileprivate lazy var fetchedResultsController: NSFetchedResultsController<Tag> = {
        guard let managedObjectContext = self.note?.managedObjectContext else {
            fatalError("No Managed Object Context Found")
        }

        // Create Fetch Request
        let fetchRequest: NSFetchRequest<Tag> = Tag.fetchRequest()

        // Configure Fetch Request
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Tag.name), ascending: true)]

        // Create Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)

        // Configure Fetched Results Controller
        fetchedResultsController.delegate = self

        return fetchedResultsController
    }()

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Tags"

        setupView()

        do {
            try fetchedResultsController.performFetch()
        } catch {
            let fetchError = error as NSError
            print("Unable to Perform Fetch Request")
            print("\(fetchError), \(fetchError.localizedDescription)")
        }

        updateView()
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueAddTagViewController {
            if let destinationViewController = segue.destination as? AddTagViewController {
                // Configure View Controller
                destinationViewController.managedObjectContext = note?.managedObjectContext
            }

        } else if segue.identifier == segueTagViewController {
            if let destinationViewController = segue.destination as? TagViewController {
                guard let cell = sender as? TagTableViewCell else { return }
                guard let indexPath = tableView.indexPath(for: cell) else { return }

                // Fetch Tag
                let tag = fetchedResultsController.object(at: indexPath)

                // Configure View Controller
                destinationViewController.tag = tag
            }
        }
    }

    // MARK: - View Methods

    fileprivate func setupView() {
        setupMessageLabel()
        setupBarButtonItems()
    }

    fileprivate func updateView() {
        var hasTags = false

        if let fetchedObjects = fetchedResultsController.fetchedObjects {
            hasTags = fetchedObjects.count > 0
        }

        tableView.isHidden = !hasTags
        messageLabel.isHidden = hasTags
    }

    // MARK: -

    private func setupMessageLabel() {
        // Configure Message Label
        messageLabel.text = "You don't have any tags yet."
    }

    // MARK: -

    private func setupBarButtonItems() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(add(sender:)))
    }

    // MARK: - Actions

    func add(sender: UIBarButtonItem) {
        performSegue(withIdentifier: segueAddTagViewController, sender: self)
    }

}

extension TagsViewController: NSFetchedResultsControllerDelegate {

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()

        updateView()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch (type) {
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .fade)
            }
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        case .update:
            if let indexPath = indexPath, let cell = tableView.cellForRow(at: indexPath) as? TagTableViewCell {
                configure(cell, at: indexPath)
            }
        case .move:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }

            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .fade)
            }
        }
    }

}

extension TagsViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        guard let sections = fetchedResultsController.sections else { return 0 }
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = fetchedResultsController.sections?[section] else { return 0 }
        return section.numberOfObjects
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeue Reusable Cell
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TagTableViewCell.reuseIdentifier, for: indexPath) as? TagTableViewCell else {
            fatalError("Unexpected Index Path")
        }

        // Configure Cell
        configure(cell, at: indexPath)

        return cell
    }

    func configure(_ cell: TagTableViewCell, at indexPath: IndexPath) {
        // Fetch Tag
        let tag = fetchedResultsController.object(at: indexPath)

        // Configure Cell
        cell.nameLabel.text = tag.name

        if let containsTag = note?.tags?.contains(tag), containsTag == true {
            cell.nameLabel.textColor = .bitterSweet()
        } else {
            cell.nameLabel.textColor = .black
        }
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }

        // Fetch Tag
        let tag = fetchedResultsController.object(at: indexPath)

        // Delete Tag
        note?.managedObjectContext?.delete(tag)
    }

}

extension TagsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Fetch Tag
        let tag = fetchedResultsController.object(at: indexPath)

        if let containsTag = note?.tags?.contains(tag), containsTag == true {
            note?.removeFromTags(tag)
        } else {
            note?.addToTags(tag)
        }
    }
    
}

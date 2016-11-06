//
//  NotesViewController.swift
//  Notes
//
//  Created by Bart Jacobs on 31/10/16.
//  Copyright © 2016 Cocoacasts. All rights reserved.
//

import UIKit
import CoreData

class NotesViewController: UIViewController {

    // MARK: - Properties

    let segueNoteViewController = "SegueNoteViewController"
    let segueAddNoteViewController = "SegueAddNoteViewController"

    // MARK: -

    @IBOutlet var notesView: UIView!
    @IBOutlet var messageLabel: UILabel!
    @IBOutlet var tableView: UITableView!

    // MARK: -

    private let estimatedRowHeight = CGFloat(44.0)

    fileprivate let coreDataManager = CoreDataManager(modelName: "Notes")

    // MARK: -

    fileprivate lazy var fetchedResultsController: NSFetchedResultsController<Note> = {
        // Create Fetch Request
        let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()

        // Configure Fetch Request
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Note.updatedAt), ascending: false)]

        // Create Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.coreDataManager.mainManagedObjectContext, sectionNameKeyPath: nil, cacheName: nil)

        // Configure Fetched Results Controller
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()

    fileprivate var hasNotes: Bool {
        guard let fetchedObjects = fetchedResultsController.fetchedObjects else { return false }
        return fetchedObjects.count > 0
    }

    fileprivate lazy var updatedAtDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, HH:mm"
        return dateFormatter
    }()

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Notes"

        setupView()
        fetchNotes()

        updateView()
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueAddNoteViewController {
            if let destinationViewController = segue.destination as? AddNoteViewController {
                destinationViewController.managedObjectContext = coreDataManager.mainManagedObjectContext
            }

        } else if segue.identifier == segueNoteViewController {
            if let destinationViewController = segue.destination as? NoteViewController, let indexPath = tableView.indexPathForSelectedRow {
                // Fetch Note
                let note = fetchedResultsController.object(at: indexPath)

                // Configure View Controller
                destinationViewController.note = note
            }
        }
    }

    // MARK: - View Methods

    fileprivate func setupView() {
        setupMessageLabel()
        setupTableView()
    }

    fileprivate func updateView() {
        tableView.isHidden = !hasNotes
        messageLabel.isHidden = hasNotes
    }

    // MARK: -

    private func setupMessageLabel() {
        messageLabel.text = "You don't have any notes yet."
    }

    // MARK: -

    private func setupTableView() {
        tableView.isHidden = true
        tableView.separatorInset = .zero
        tableView.estimatedRowHeight = estimatedRowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
    }

    // MARK: - Helper Methods

    private func fetchNotes() {
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            print("Unable to Perform Fetch Request")
            print("\(error), \(error.localizedDescription)")
        }
    }

}

extension NotesViewController: NSFetchedResultsControllerDelegate {

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
            if let indexPath = indexPath, let cell = tableView.cellForRow(at: indexPath) as? NoteTableViewCell {
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

extension NotesViewController: UITableViewDataSource {

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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NoteTableViewCell.reuseIdentifier, for: indexPath) as? NoteTableViewCell else {
            fatalError("Unexpected Index Path")
        }

        // Configure Cell
        configure(cell, at: indexPath)

        return cell
    }

    func configure(_ cell: NoteTableViewCell, at indexPath: IndexPath) {
        // Fetch Note
        let note = fetchedResultsController.object(at: indexPath)

        // Configure Cell
        cell.titleLabel.text = note.title
        cell.contentsLabel.text = note.contents
        cell.tagsLabel.text = note.alphabetizedTagsAsString ?? "No Tags"
        cell.updatedAtLabel.text = updatedAtDateFormatter.string(from: note.updatedAtAsDate)

        if let color = note.category?.color {
            cell.categoryColorView.backgroundColor = color
        } else {
            cell.categoryColorView.backgroundColor = .white
        }
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }

        // Fetch Note
        let note = fetchedResultsController.object(at: indexPath)

        // Delete Note
        coreDataManager.mainManagedObjectContext.delete(note)
    }

}

extension NotesViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

}

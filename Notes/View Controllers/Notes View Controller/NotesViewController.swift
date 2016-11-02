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

    private let coreDataManager = CoreDataManager(modelName: "Notes")

    // MARK: -

    fileprivate var notes: [Note]? {
        didSet {
            updateView()
        }
    }

    fileprivate var hasNotes: Bool {
        guard let notes = notes else { return false }
        return notes.count > 0
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
        setupNotificationHandling()
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueAddNoteViewController {
            if let destinationViewController = segue.destination as? AddNoteViewController {
                destinationViewController.managedObjectContext = coreDataManager.managedObjectContext
            }

        } else if segue.identifier == segueNoteViewController {
            if let destinationViewController = segue.destination as? NoteViewController {
                if let indexPath = tableView.indexPathForSelectedRow, let note = notes?[indexPath.row] {
                    // Configure View Controller
                    destinationViewController.note = note
                }
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
        tableView.estimatedRowHeight = estimatedRowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
    }

    // MARK: - Notification Handling

    func managedObjectContextObjectsDidChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }

        // Helpers
        var notesDidChange = false

        if let inserts = userInfo[NSInsertedObjectsKey] as? Set<NSManagedObject> {
            for insert in inserts {
                if let note = insert as? Note {
                    notes?.append(note)
                    notesDidChange = true
                }
            }
        }

        if let updates = userInfo[NSUpdatedObjectsKey] as? Set<NSManagedObject> {
            for update in updates {
                if let _ = update as? Note {
                    notesDidChange = true
                }
            }
        }

        if let deletes = userInfo[NSDeletedObjectsKey] as? Set<NSManagedObject> {
            for delete in deletes {
                if let note = delete as? Note {
                    if let index = notes?.index(of: note) {
                        notes?.remove(at: index)
                        notesDidChange = true
                    }
                }
            }
        }

        if notesDidChange {
            // Sort Notes
            notes?.sort(by: { $0.updatedAtAsDate > $1.updatedAtAsDate })

            // Update Table View
            tableView.reloadData()

            // Update View
            updateView()
        }
    }
    
    // MARK: - Helper Methods

    private func fetchNotes() {
        // Create Fetch Request
        let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()

        // Configure Fetch Request
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Note.updatedAt), ascending: false)]

        // Perform Fetch Request
        coreDataManager.managedObjectContext.performAndWait {
            do {
                // Execute Fetch Request
                let notes = try fetchRequest.execute()

                // Update Notes
                self.notes = notes

                // Reload Table View
                self.tableView.reloadData()

            } catch {
                let fetchError = error as NSError
                print("Unable to Execute Fetch Request")
                print("\(fetchError), \(fetchError.localizedDescription)")
            }
        }
    }

    // MARK: -

    private func setupNotificationHandling() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(managedObjectContextObjectsDidChange(_:)), name: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: coreDataManager.managedObjectContext)
    }

}

extension NotesViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return hasNotes ? 1 : 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let notes = notes else { return 0 }
        return notes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Fetch Note
        guard let note = notes?[indexPath.row] else { fatalError("Unexpected Index Path") }

        // Dequeue Reusable Cell
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NoteTableViewCell", for: indexPath) as? NoteTableViewCell else { fatalError("Unexpected Index Path") }

        // Configure Cell
        cell.titleLabel.text = note.title
        cell.contentsLabel.text = note.contents
        cell.updatedAtLabel.text = updatedAtDateFormatter.string(from: note.updatedAtAsDate)

        return cell
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {

    }

}

extension NotesViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

}

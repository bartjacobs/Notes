//
//  NoteViewController.swift
//  Notes
//
//  Created by Bart Jacobs on 02/11/16.
//  Copyright © 2016 Cocoacasts. All rights reserved.
//

import UIKit

class NoteViewController: UIViewController {

    // MARK: - Properties

    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var contentsTextView: UITextView!

    // MARK: -

    var note: Note?

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Edit Note"

        setupView()
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

    }

    // MARK: - View Methods

    fileprivate func setupView() {
        setupTitleTextField()
        setupContentsTextView()
    }

    // MARK: -

    private func setupTitleTextField() {
        // Configure Title Text Field
        titleTextField.text = note?.title
    }

    private func setupContentsTextView() {
        // Configure Contents Text View
        contentsTextView.text = note?.contents
    }
    
}

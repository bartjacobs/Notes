//
//  CategoryViewController.swift
//  Notes
//
//  Created by Bart Jacobs on 03/11/16.
//  Copyright © 2016 Cocoacasts. All rights reserved.
//

import UIKit

class CategoryViewController: UIViewController {

    // MARK: - Properties

    let segueColorViewController = "SegueColorViewController"

    // MARK: -

    @IBOutlet var colorView: UIView!
    @IBOutlet var nameTextField: UITextField!

    // MARK: -

    var category: Category?

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Edit Category"

        setupView()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // Update Category
        if let name = nameTextField.text, !name.isEmpty {
            category?.name = name
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == segueColorViewController else { return }

        if let destinationViewController = segue.destination as? ColorViewController {
            // Configure Destination View Controller
            destinationViewController.delegate = self
            destinationViewController.color = category?.color ?? .white
        }
    }

    // MARK: - View Methods

    fileprivate func setupView() {
        setupColorView()
        setupNameTextField()
    }

    // MARK: -

    private func setupColorView() {
        // Configure Layer Color View
        colorView.layer.cornerRadius = CGFloat(colorView.frame.width / 2.0)

        updateColorView()
    }

    fileprivate func updateColorView() {
        // Configure Color View
        colorView.backgroundColor = category?.color
    }

    // MARK: -

    private func setupNameTextField() {
        // Configure Name Text Field
        nameTextField.text = category?.name
    }

}

extension CategoryViewController: ColorViewControllerDelegate {

    func controller(_ controller: ColorViewController, didPick color: UIColor) {
        // Update Category
        category?.color = color

        // Update View
        updateColorView()
    }

}

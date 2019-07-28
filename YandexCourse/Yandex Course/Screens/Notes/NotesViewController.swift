//
//  NotesViewController.swift
//  Yandex Course
//
//  Created by Vitaliy Pyatnikov on 28.07.2019.
//  Copyright © 2019 Vitaliy Pyatnikov. All rights reserved.
//

import UIKit

// MARK: - NotesViewController

final class NotesViewController: UIViewController {

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
    }

    // MARK: - Private

    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                            target: self,
                                                            action: #selector(addNewNote))
    }
    @objc private func addNewNote() {
        performSegue(withIdentifier: "EditNoteSegue", sender: self)
    }

}

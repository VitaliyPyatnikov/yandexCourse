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

    // MARK: - IBOutlets

    @IBOutlet weak var tableVIew: UITableView!

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupTableView()
    }

    // MARK: - Private

    private let fileNotebook: FileNotebookHandler = FileNotebook()
    private let editBarButton = UIBarButtonItem(barButtonSystemItem: .edit,
                                                target: self,
                                                action: #selector(editMode))
    private let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done,
                                                target: self,
                                                action: #selector(editMode))

    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = editBarButton
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                            target: self,
                                                            action: #selector(addNewNote))
    }
    @objc private func addNewNote() {
        performSegue(withIdentifier: "EditNoteSegue", sender: self)
    }
    @objc private func editMode() {
        tableVIew.isEditing.toggle()
        if tableVIew.isEditing {
            navigationItem.leftBarButtonItem = doneBarButton
        } else {
            navigationItem.leftBarButtonItem = editBarButton
        }
    }
    private func setupTableView() {
        tableVIew.delegate = self
        tableVIew.dataSource = self
        tableVIew.rowHeight = UITableView.automaticDimension
        tableVIew.estimatedRowHeight = 100
        let nib = UINib(nibName: "NoteTableViewCell", bundle: nil)
        tableVIew.register(nib, forCellReuseIdentifier: "NoteCell")
    }

}

// MARK: - UITableViewDataSource

extension NotesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fileNotebook.notes.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableVIew.dequeueReusableCell(withIdentifier: "NoteCell", for: indexPath) as? NoteTableViewCell else {
            return UITableViewCell()
        }
        let model = fileNotebook.notes[indexPath.row]
        let cellModel = NoteCellModel(title: model.title,
                                      description: model.content,
                                      color: model.color)
        cell.setup(with: cellModel)

        return cell
    }
}

// MARK: - UITableViewDelegate

extension NotesViewController: UITableViewDelegate {

}
